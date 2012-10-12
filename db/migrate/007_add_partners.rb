class AddPartners < ActiveRecord::Migration
  def up
    create_table :businesses do |t|
      t.string :business, null: false
    end

    add_index :businesses, :business, unique: true

    create_table :partners do |t|
      t.integer    :user_id,    null: false
      t.integer    :country_id, null: true
      t.string     :company,    null: false
      t.string     :street,     null: true
      t.string     :city,       null: true
      t.string     :zip,        null: true
      t.string     :region,     null: true
      t.timestamps
    end

    add_index :partners, :company, unique: true

    [:user_id, :country_id, :street, :city, :zip, :region].each do |col|
      add_index :partners, col
    end

    create_table :businesses_partners, id: false do |t|
      t.integer :business_id, null: false
      t.integer :partner_id, null: false
    end

    add_index :businesses_partners, [:business_id, :partner_id], unique: true

    create_table :partners_users, id: false do |t|
      t.integer :partner_id, null: false
      t.integer :user_id,    null: false
    end

    add_index :partners_users, [:partner_id, :user_id], unique: true

    create_table :employees do |t|
      t.integer    :partner_id, null: false
      t.string     :name,       null: false
      t.string     :gender,     null: true
      t.string     :job,        null: true
      t.timestamps
    end

    add_index :employees, :partner_id
  end

  def down
    drop_table :employees
    drop_table :partners_users
    drop_table :businesses_partners
    drop_table :partners
    drop_table :businesses
  end
end
