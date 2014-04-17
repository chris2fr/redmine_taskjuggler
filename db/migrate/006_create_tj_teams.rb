class CreateTjTeams < ActiveRecord::Migration
  def change
    create_table :tj_teams do |t|
      t.string :name
    end
  end
end
