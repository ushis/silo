class PolymorphicDescriptions < ActiveRecord::Migration
  def up
    add_column :descriptions, :describable_type, :string, null: false, default: 'Partner'
    rename_column :descriptions, :partner_id, :describable_id
    add_index :descriptions, [:describable_id, :describable_type]
  end

  def down
    rename_column :descriptions, :describable_id, :partner_id
    remove_column :descriptions, :describable_type
  end
end
