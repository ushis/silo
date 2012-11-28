class AddLists < ActiveRecord::Migration

  def up
    create_table :lists do |t|
      t.integer  :user_id, null: false
      t.string   :title,   null: false
      t.boolean  :private, null: false, default: true
      t.timestamps
    end

    add_index :lists, :user_id
    add_index :lists, :title

    create_table :list_items do |t|
      t.integer  :list_id,   null: false
      t.integer  :item_id,   null: false
      t.string   :item_type, null: false
      t.string   :note,      null: true
      t.timestamps
    end

    add_index :list_items, [:list_id, :item_id, :item_type], unique: true

    add_column :users, :current_list_id, :integer, null: true
    add_index  :users, :current_list_id
  end

  def down
    remove_column :users, :current_list_id
    drop_table :list_items
    drop_table :lists
  end
end
