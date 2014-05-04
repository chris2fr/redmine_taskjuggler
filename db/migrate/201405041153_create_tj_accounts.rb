# encoding: utf-8
##
# A migration for workload, I guess preferences. Rails likes objects
# to be tangible.
class CreateTjAccounts < ActiveRecord::Migration
  def change
    create_table :tj_accounts do |t|
      t.string :code
      t.string :name
      t.int :tj_account_id
      t.timestamps
    end
    add_index(:tj_accounts, :tj_account_id)
  end
end