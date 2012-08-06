class AddComments < ActiveRecord::Migration
  def up
    create_table :comments do |t|
      t.references :commentable, polymorphic: true
      t.text       :comment,     null: false
      t.timestamps
    end

    add_index :comments, [:commentable_id, :commentable_type]

    execute('ALTER TABLE comments ENGINE = MyISAM')
    execute('CREATE FULLTEXT INDEX fulltext_comment ON comments (comment)')
  end

  def down
    drop_table :comments
  end
end
