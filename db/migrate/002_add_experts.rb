class AddExperts < ActiveRecord::Migration
  def up
    create_table :experts do |t|
      t.integer     :user_id,              null: false
      t.string      :name,                 null: false
      t.string      :prename,              null: false
      t.string      :gender,               null: false
      t.datetime    :birthday,             null: true
      t.string      :birthplace,           null: true
      t.string      :citizenship,          null: true
      t.string      :degree,               null: true
      t.boolean     :former_collaboration, null: false, default: false
      t.string      :fee,                  null: true
      t.string      :company,              null: true
      t.string      :job,                  null: true
      t.timestamps
    end

    add_index :experts, :user_id
    add_index :experts, :name
    add_index :experts, :prename

    create_table :contacts do |t|
      t.references :contactable, polymorphic: true
      t.text       :contacts,    null: false
    end

    add_index :contacts, [:contactable_id, :contactable_type]

    create_table :addresses do |t|
      t.references :addressable, polymorphic: true
      t.string     :street,      null: false
      t.string     :city,        null: false
      t.string     :zipcode,     null: true
      t.string     :country,     null: true
      t.string     :more,        null: true
    end

    add_index :addresses, :zipcode
    add_index :addresses, :city
    add_index :addresses, [:addressable_id, :addressable_type]
  end

  def down
    drop_table :experts
    drop_table :contacts
    drop_table :addresses
  end
end
