class CreateCoaches < ActiveRecord::Migration[5.1]
  def change
    create_table :coaches do |t|
      t.string :name
      t.string :email

      t.timestamps
    end
  end
end
