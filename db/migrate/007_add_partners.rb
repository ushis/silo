class AddPartners < ActiveRecord::Migration
  def up
    create_table :businesses do |t|
      t.string :business, null: false
    end

    add_index :businesses, :business, unique: true

    create_table :advisers do |t|
      t.string :adviser, null: false
    end

    add_index :advisers, :adviser, unique: true

    create_table :partners do |t|
      t.integer    :user_id,    null: false
      t.integer    :country_id, null: true
      t.string     :company,    null: false
      t.string     :street,     null: true
      t.string     :city,       null: true
      t.string     :zip,        null: true
      t.string     :region,     null: true
      t.string     :website,    null: true
      t.string     :email,      null: true
      t.string     :phone,      null: true
      t.timestamps
    end

    [:company, :user_id, :country_id, :street, :city, :zip, :region].each do |col|
      add_index :partners, col
    end

    create_table :businesses_partners, id: false do |t|
      t.integer :business_id, null: false
      t.integer :partner_id, null: false
    end

    add_index :businesses_partners, [:business_id, :partner_id], unique: true

    create_table :advisers_partners, id: false do |t|
      t.integer :adviser_id, null: false
      t.integer :partner_id, null: false
    end

    add_index :advisers_partners, [:adviser_id, :partner_id], unique: true

    create_table :descriptions do |t|
      t.integer    :partner_id,  null: false
      t.text       :description, null: false
      t.timestamps
    end

    add_index :descriptions, :partner_id

    execute('ALTER TABLE descriptions ENGINE = MyISAM')
    execute('CREATE FULLTEXT INDEX fulltext_description ON descriptions (description)')

    create_table :employees do |t|
      t.integer    :partner_id, null: false
      t.string     :name,       null: false
      t.string     :prename,    null: true
      t.string     :gender,     null: true
      t.string     :title,      null: true
      t.string     :job,        null: true
      t.timestamps
    end

    add_index :employees, :partner_id
    add_index :employees, :name
    add_index :employees, :prename
  end

  def down
    drop_table :employees
    drop_table :descriptions
    drop_table :advisers_partners
    drop_table :businesses_partners
    drop_table :partners
    drop_table :advisers
    drop_table :businesses
  end
end
