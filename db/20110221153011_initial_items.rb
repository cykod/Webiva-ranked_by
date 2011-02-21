class InitialItems < ActiveRecord::Migration
  def self.up

    create_table :ranked_by_users do |t|
      t.integer :end_user_id
      t.timestamps
    end

    add_index :ranked_by_users, :end_user_id, :name => 'user_index'

    create_table :ranked_by_lists do |t|
      t.integer :ranked_by_user_id
      t.string :permalink
      t.string :name
      t.string :description
      t.description
      t.integer :views, :default => 0
      t.timestamps
    end

    add_index :ranked_by_lists, :ranked_by_user_id, :name => 'ranked_by_user'
    add_index :ranked_by_lists, :views, :name => 'views_index'
    add_index :ranked_by_lists, :created_at, :name => 'created_index'
    add_index :ranked_by_lists, :updated_at, :name => 'updated_index'

    create_table :ranked_by_items do |t|
      t.integer :ranked_by_user_id
      t.integer :ranked_by_list_id
      t.string :name
      t.string :item_type
      t.string :url
      t.text :description
      t.float :ranking, :default => 0
      t.timestamps
    end


    add_index :ranked_by_items, :ranked_by_list_id, :name => 'list_id'

    create_table :ranked_by_item_rankings do |t|
      t.integer :ranked_by_list_id
      t.integer :item_1_id
      t.integer :item_2_id
      t.integer :ranking
    end
  end

  def self.down
    drop_table :ranked_by_users
    drop_table :ranked_by_lists
    drop_table :ranked_by_items
    drop_table :ranked_by_item_rankings
  end
end
