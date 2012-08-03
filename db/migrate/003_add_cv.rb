class AddCv < ActiveRecord::Migration
  def up
    create_table :cvs do |t|
      t.integer   :expert_id,  null: false
      t.string    :filename,   null: false
      t.string    :language,   null: true
      t.text      :cv,         null: true
      t.timestamp :created_at
    end

    add_index :cvs, :expert_id
    add_index :cvs, :filename

    execute('ALTER TABLE cvs ENGINE = MyISAM')
    execute('CREATE FULLTEXT INDEX fulltext_cv ON cvs (cv)')
  end

  def down
    drop_table :cvs
  end
end
