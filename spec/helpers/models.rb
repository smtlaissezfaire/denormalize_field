class ApplicationRecord < ActiveRecord::Base
  include DenormalizeField
  self.abstract_class = true
end

class Region < ApplicationRecord
  has_many :users
end

class User < ApplicationRecord
  belongs_to :region
  has_many :posts
end

class Post < ApplicationRecord
  belongs_to :user
  belongs_to :region
  has_many :comments

  denormalize_field :user, :first_name
  denormalize_field :user, :admin
  denormalize_field :user, :registered_at

  # Denormalize this once on create but don't update it later on
  denormalize_association :region, :from => :user, :on => :create, :reflect_updates => false

  attr_accessor :callback_chain_complete

  validate :run_callback_chain_complete

  def run_callback_chain_complete
    @callback_chain_complete = true
  end
end

class Comment < ApplicationRecord
  belongs_to :post
  belongs_to :user
  belongs_to :post_user, :class_name => "User"
  has_many :favorites

  denormalize_association :user, :from => :post, :target_field => :post_user
  denormalize_field :user, :first_name
end

class Favorite < ApplicationRecord
  belongs_to :comment
  belongs_to :user
  belongs_to :post

  denormalize_associations :user, :post, :from => :comment
end

module Namespace; end

# class Namespace::Comment < ApplicationRecord
#   belongs_to :user
#   belongs_to :post
#
#   denormalize_association :user, :from => :post
#   denormalize_field :user, :first_name
# end
