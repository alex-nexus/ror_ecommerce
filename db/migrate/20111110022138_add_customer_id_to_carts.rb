class AddCustomerIdToCarts < ActiveRecord::Migration
  def change
    # This column is specifically for the admin cart
    add_column :carts, :customer_id, :integer
    add_index :carts, :customer_id
  end
end
