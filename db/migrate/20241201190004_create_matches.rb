class CreateMatches < ActiveRecord::Migration[8.0]
  def change
    create_table :matches do |t|
      t.integer :maximum_number_of_games, null: false
      t.integer :status, null: false, default: 0

      t.timestamps
    end
  end
end
