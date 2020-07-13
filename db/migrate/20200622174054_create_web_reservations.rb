class CreateWebReservations < ActiveRecord::Migration[6.0]
  def change
    create_table :web_reservations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :item, null: false, foreign_key: true
      t.integer :number, null: false, default: 1
      t.string :reservation_name, null: false, default: ''
      t.date :reservation_date, null: false
      t.date :start_date, null: false
      t.date :end_date, null: false

      t.timestamps
    end
  end
end
