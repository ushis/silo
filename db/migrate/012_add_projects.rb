class AddProjects < ActiveRecord::Migration
  def up
    create_table :projects do |t|
      t.integer :user_id,            null: false
      t.integer :country_id,         null: true
      t.string  :status,             null: false
      t.integer :carried_proportion, null: false, default: 0
      t.string  :start,              null: true
      t.string  :end,                null: true
      t.string  :partners,           null: true
      t.integer :staff_months,       null: true
      t.integer :order_value_us,     null: true
      t.integer :order_value_eur,    null: true
      t.timestamps
    end

    [:country_id, :status, :start, :end, :partners].each do |col|
      add_index :projects, col
    end

    create_table :project_info do |t|
      t.integer :user_id,         null: false
      t.integer :project_id,      null: false
      t.integer :language_id,     null: false
      t.string  :title,           null: false
      t.string  :region,          null: true
      t.string  :client,          null: true
      t.string  :funders,         null: true
      t.text    :focus,           null: true
      t.timestamps
    end

    add_index :project_info, :title
    add_index :project_info, [:project_id, :language_id], unique: true

    create_table :project_members do |t|
      t.integer :expert_id,  null: false
      t.integer :project_id, null: false
      t.string  :role,       null: false
      t.timestamps
    end

    add_index :project_members, [:expert_id, :project_id], unique: true
  end

  def down
    drop_table :projects
    drop_table :project_info
    drop_table :project_members
  end
end
