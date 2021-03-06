class AddProjects < ActiveRecord::Migration
  def up
    create_table :projects do |t|
      t.integer :user_id,            null: false
      t.integer :country_id,         null: true
      t.string  :title,              null: true
      t.string  :status,             null: false
      t.integer :carried_proportion, null: false, default: 0
      t.date    :start,              null: true
      t.date    :end,                null: true
      t.integer :order_value_us,     null: true
      t.integer :order_value_eur,    null: true
      t.timestamps
    end

    [:country_id, :status, :start, :end].each do |col|
      add_index :projects, col
    end

    create_table :project_infos do |t|
      t.integer :project_id,   null: false
      t.string  :language,     null: false
      t.string  :title,        null: false
      t.string  :region,       null: true
      t.string  :client,       null: true
      t.string  :address,      null: true
      t.string  :funders,      null: true
      t.string  :staff,        null: true
      t.string  :staff_months, null: true
      t.text    :focus,        null: true
      t.timestamps
    end

    add_index :project_infos, :title
    add_index :project_infos, [:project_id, :language], unique: true

    create_table :project_members do |t|
      t.integer :expert_id,  null: false
      t.integer :project_id, null: false
      t.string  :role,       null: false
      t.timestamps
    end

    add_index :project_members, [:expert_id, :project_id], unique: true

    create_table :partners_projects, id: false do |t|
      t.integer :partner_id, null: false
      t.integer :project_id, null: false
    end

    add_index :partners_projects, [:partner_id, :project_id], unique: true
  end

  def down
    drop_table :partners_projects
    drop_table :project_members
    drop_table :project_infos
    drop_table :projects
  end
end
