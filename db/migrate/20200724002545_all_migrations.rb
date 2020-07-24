class AllMigrations < ActiveRecord::Migration[6.0]
  def change
    create_table :regions do |t|
      t.string :region
      t.timestamps
    end

    create_table :users do |t|
      t.belongs_to :region

      t.string :first_name
      t.string :last_name
      t.boolean :admin
      t.datetime :registered_at
      t.timestamps
    end

    create_table :posts do |t|
      t.belongs_to :user
      t.belongs_to :region

      t.string :user_first_name
      t.boolean :user_admin
      t.datetime :user_registered_at
      t.timestamps
    end

    create_table :comments do |t|
      t.belongs_to :post
      t.belongs_to :user
      t.belongs_to :post_user

      t.string :user_first_name
      t.timestamps
    end

    create_table :favorites do |t|
      t.belongs_to :comment
      t.belongs_to :user
      t.belongs_to :post

      t.timestamps
    end

    create_table :namespaces_comments do |t|
      t.belongs_to :user
      t.belongs_to :post

      t.string :user_first_name
      t.timestamps
    end
  end
end
