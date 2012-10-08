class RemoveLangs < ActiveRecord::Migration
  def up
    create_table :experts_languages, id: false do |t|
      t.integer :expert_id,   null: false
      t.integer :language_id, null: false
    end

    add_index :experts_languages, :expert_id
    add_index :experts_languages, :language_id

    execute <<-SQL
      INSERT INTO experts_languages (expert_id, language_id)
        SELECT langs.langable_id, langs.language_id
        FROM langs
    SQL

    drop_table :langs
  end

  def down
    create_table :langs do |t|
      t.integer    :language_id, null: false
      t.references :langable,    polymorphic: true
    end

    add_index :langs, :language_id
    add_index :langs, [:langable_id, :langable_type]

    execute <<-SQL
      INSERT INTO langs (langable_id, language_id)
        SELECT experts_languages.expert_id, experts_languages.language_id
        FROM experts_languages
    SQL

    execute 'UPDATE langs SET langable_type = \'Expert\''

    drop_table :experts_languages
  end
end
