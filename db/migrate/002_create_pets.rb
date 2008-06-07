class CreatePets < ActiveRecord::Migration
  def self.up
    create_table :pets do |t|
      t.string  :name
      t.string  :type
      t.integer :user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :pets
  end
end
