class AddCoachToUsers < ActiveRecord::Migration[5.1]
  def change
    add_reference :users, :coach, foreign_key: true
  end
end
