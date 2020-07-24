module DenormalizeField
  if defined?(ActiveModel::Validations::ClassMethods::VALID_OPTIONS_FOR_VALIDATE)
    VALID_OPTIONS_FOR_VALIDATE = ActiveModel::Validations::ClassMethods::VALID_OPTIONS_FOR_VALIDATE
  else
    VALID_OPTIONS_FOR_VALIDATE = [:on, :if, :unless, :prepend].freeze
  end

  def self.included(mod)
    mod.extend(DenormalizeField::ClassMethods)
  end

  module ClassMethods
    def denormalize_field(association, field, options={})
      denormalize(association, field, options)
    end

    def denormalize_associations(*destinations)
      options = destinations.last.is_a?(Hash) ? destinations.pop.dup : {}
      source = options.delete(:from)

      if !source
        raise "denormalize_association must take a from (source) option"
      end

      destinations.each do |dest|
        denormalize(source, dest, {
          :target_field => dest,
          :is_association => true
        }.merge(options))
      end
    end

    alias_method :denormalize_association, :denormalize_associations

    def denormalize(association, field, options={})
      association = association.to_sym
      field = field.to_sym

      validation_method = options[:method] || :before_validation
      validation_method_params = options.slice(*VALID_OPTIONS_FOR_VALIDATE)

      source_field_code = options[:source_field] || :"#{association}.#{field}"
      target_field_code = options[:target_field] || :"#{association}_#{field}"
      is_association = options[:is_association]
      reflect_updates = options.has_key?(:reflect_updates) ? options[:reflect_updates] : true

      denormalize_on_validation(association, field, validation_method, source_field_code, target_field_code, validation_method_params)
      denormalize_on_update(association, field, is_association, target_field_code) if reflect_updates
    end

  private

    def denormalize_on_update(association_name, field, is_association, target_field_code)
      if is_association
        field = :"#{field}_id"
        target_field_code = :"#{target_field_code}_id"
      end

      association_name = association_name.to_sym

      association_klass = self.reflect_on_all_associations.detect { |association| association.name.to_sym == association_name.to_sym }
      raise "Couldn't find association: #{association_klass}" if !association_klass
      klass = association_klass.klass

      collection_name = self.table_name
      self_class = self
      reverse_denormalization_method_name = "_denormalize__#{collection_name}__#{association_name}__#{field}".gsub(/[^A-Za-z0-9_]/, '_')

      klass.class_eval(<<-CODE, __FILE__, __LINE__+1)
        after_update :#{reverse_denormalization_method_name}

        def #{reverse_denormalization_method_name}
          return true unless self.respond_to?(:#{field}) && self.respond_to?(:#{field}_changed?)

          if self.saved_change_to_#{field}?
            new_value = self.#{field}

            find_query = {
              :#{association_name}_id => self.id,
            }
            update_query = {
              :#{target_field_code} => new_value,
            }

            #{self_class.name}.where(find_query).update_all(update_query)
          end

          true
        end

        private :#{reverse_denormalization_method_name}
      CODE
    end

    def denormalize_on_validation(association, field, validation_method, source_field_code, target_field_code, validation_method_params={})
      validation_method_name = :"denormalize_#{association}_#{field}"

      # denormalize the field
      self.class_eval(<<-CODE, __FILE__, __LINE__+1)
        #{validation_method} :#{validation_method_name}, #{validation_method_params.inspect}

        def #{validation_method_name}
          if self.#{association}
            self.#{target_field_code} = #{source_field_code}
          end

          true
        end

        private :#{validation_method_name}
      CODE
    end
  end
end
