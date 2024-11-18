class CreateEnvironmentData < ActiveRecord::Migration[7.2]
  def change
    create_table :environment_data do |t|
      t.float :esp_temperature
      t.float :esp_humidity
      t.float :weather_temperature
      t.float :weather_humidity

      t.timestamps
    end
  end
end
