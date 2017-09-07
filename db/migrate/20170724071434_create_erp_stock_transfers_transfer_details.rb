class CreateErpStockTransfersTransferDetails < ActiveRecord::Migration[5.1]
  def change
    create_table :erp_stock_transfers_transfer_details do |t|
      t.integer :quantity, default: 1
      t.references :product, index: true, references: :erp_products_products
      t.references :transfer, index: true, references: :erp_stock_transfers_transfers
      t.references :state, index: true, references: :erp_products_states

      t.timestamps
    end
  end
end
