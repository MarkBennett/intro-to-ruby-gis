class CreateVenues < ActiveRecord::Migration
  def change
    create_table :venues do |t|
      t.string :name
      t.point :location, :geographic => true

      t.timestamps
    end

    change_table :venues do |t|
        t.index :location, :spatial => true
    end
  end
end
