class AddKindToItem < ActiveRecord::Migration[7.1]
  def change
    add_column :items, :kind, :integer, default: 1, null: false
  end
end
