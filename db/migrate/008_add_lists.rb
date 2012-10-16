class AddLists < ActiveRecord::Migration

  def up
    create_table :lists do |t|
      t.integer  :user_id, null: false
      t.string   :title,   null: false
      t.boolean  :private, null: false, default: false
      t.timestamps
    end

    add_index :lists, :user_id
    add_index :lists, :title,   unique: true

    create_table :experts_lists, id: false do |t|
      t.integer :expert_id, null: false
      t.integer :list_id,   null: false
    end

    add_index :experts_lists, [:expert_id, :list_id], unqiue: true

    create_table :lists_partners, id: false do |t|
      t.integer :list_id,    null: false
      t.integer :partner_id, null: false
    end

    add_index :lists_partners, [:list_id, :partner_id], unique: true

    add_column :users, :current_list_id, :integer, null: true
  end

  def down
    remove_column :users, :current_list_id
    drop_table :experts_lists
    drop_table :lists_partners
    drop_table :lists
  end
end
