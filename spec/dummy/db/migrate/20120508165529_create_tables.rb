# frozen_string_literal: true

class CreateTables < MIGRATION_CLASS
  def self.up
    create_table :foos do |t|
      t.string :name
      t.integer :value, :null => false
      t.timestamps null: false
    end
    create_table :doos do |t|
      t.string :name
      t.integer :value, :null => false
      t.timestamps null: false
    end
  end

  def self.down
    drop_table :foos
    drop_table :doos
  end
end
