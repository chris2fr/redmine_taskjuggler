# encoding: utf-8
##
# Activated is now handled by the activation of the module or not
class ModifyPatchProjectDelTjActivated < ActiveRecord::Migration
  def change
    remove_column :projects, :tj_activated # Add arbitrary data to an issu
  end
end
