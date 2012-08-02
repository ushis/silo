class InitSilo < ActiveRecord::Migration
  def up
    create_table :users do |t|
      t.string    :username,        null: false
      t.string    :email,           null: false
      t.string    :password_digest, null: false
      t.string    :login_hash,      null: true
      t.string    :name,            null: false
      t.string    :prename,         null: false
      t.timestamp :created_at,      null: false
    end

    add_index :users, :username,   unique: true
    add_index :users, :email,      unqiue: true
    add_index :users, :login_hash, unqiue: true

    create_table :privileges do |t|
      t.integer :user_id,    null: false
      t.boolean :admin,      null: false, default: false
      t.boolean :experts,    null: false, default: false
      t.boolean :partners,   null: false, default: false
      t.boolean :references, null: false, default: false
    end

    add_index :privileges, :user_id
  end

  def down
    drop_table :users
    drop_table :privileges
  end
end
