class AddCountColumnToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, "count", :bigint, default: 0, null: false
  end
end
