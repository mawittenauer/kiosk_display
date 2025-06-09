class CreateKioskConfigs < ActiveRecord::Migration[7.2]
  def change
    create_table :kiosk_configs do |t|
      t.string :zipcode, null: false
      t.integer :refresh_interval, default: 300000
      t.text :modules_enabled

      t.timestamps
    end

    add_index :kiosk_configs, :zipcode
  end
end
