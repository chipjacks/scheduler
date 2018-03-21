class CreateAppointments < ActiveRecord::Migration[5.1]
  def change
    create_table :appointments do |t|
      t.datetime :time
      t.references :user, foreign_key: true
      t.references :coach, foreign_key: true

      t.timestamps
    end
  end
end
