class RenameReferences < ActiveRecord::Migration
  def up
    rename_column :privileges, :references, :projects
  end

  def down
    rename_column :privileges, :projects, :references
  end
end
