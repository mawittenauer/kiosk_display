class CreateKioskConfigs < ActiveRecord::Migration[7.2]
  def change
    create_table :kiosk_configs do |t|
      t.string :zipcode
      t.integer :refresh_interval
      t.text :modules_enabled

      t.timestamps
    end
  end
end
