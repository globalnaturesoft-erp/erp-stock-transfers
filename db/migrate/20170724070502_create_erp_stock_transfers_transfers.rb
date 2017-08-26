class CreateErpStockTransfersTransfers < ActiveRecord::Migration[5.1]
  def change
    create_table :erp_stock_transfers_transfers do |t|
      t.string :code
      t.datetime :received_at
      t.references :source_warehouse, index: true, references: :erp_warehouses_warehouses
      t.references :destination_warehouse, index: true, references: :erp_warehouses_warehouses
      t.references :creator, index: true, references: :erp_users
      t.text :note
      t.string :status
      t.integer :cache_products_count

      t.timestamps
    end
  end
end
