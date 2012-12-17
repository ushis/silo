class AddFaxToPartners < ActiveRecord::Migration
  def up
    add_column :partners, :fax, :string, null: true
  end

  def down
    remove_column :partners, :fax
  end
end
