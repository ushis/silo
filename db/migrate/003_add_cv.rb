class AddCv < ActiveRecord::Migration
  def up
    create_table :cvs do |t|
      t.integer   :expert_id,  null: false
      t.string    :language,   null: true
      t.text      :cv,         null: true
    end

    add_index :cvs, :expert_id

    execute('ALTER TABLE cvs ENGINE = MyISAM')
    execute('CREATE FULLTEXT INDEX fulltext_cv ON cvs (cv)')

    create_table :attachments do |t|
      t.references :attachable, polymorphic: true
      t.string     :filename,   null: false
      t.timestamp  :created_at
    end

    add_index :attachments, [:attachable_id, :attachable_type]
    add_index :attachments, :filename, unique: true
  end

  def down
    drop_table :cvs
    drop_table :attachments
  end
end
