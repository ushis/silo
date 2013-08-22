class PolymorphicDescriptions < ActiveRecord::Migration
  def up
    remove_index  :descriptions, :partner_id
    add_column    :descriptions, :describable_type, :string, null: false, default: 'Partner'
    rename_column :descriptions, :partner_id, :describable_id
    add_index     :descriptions, [:describable_id, :describable_type]
  end

  def down
    remove_index  :descriptions, column: [:describable_id, :describable_type]
    rename_column :descriptions, :describable_id, :partner_id
    remove_column :descriptions, :describable_type
    add_index     :descriptions, :partner_id
  end
end
