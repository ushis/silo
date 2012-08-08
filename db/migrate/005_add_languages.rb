class AddLanguages < ActiveRecord::Migration
  def up
    create_table :languages do |t|
      t.string :language, null: false
    end

    add_index :languages, :language, unique: true

    create_table :langs do |t|
      t.integer    :language_id, null: false
      t.references :langable,    polymorphic: true
    end

    add_index :langs, :language_id
    add_index :langs, [:langable_id, :langable_type]
  end

  def down
    drop_table :languages
    drop_table :langs
  end
end
