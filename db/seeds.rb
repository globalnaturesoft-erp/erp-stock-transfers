user = Erp::User.first
status = [Erp::StockTransfers::Transfer::STATUS_DRAFT,
          Erp::StockTransfers::Transfer::STATUS_ACTIVE,
          Erp::StockTransfers::Transfer::STATUS_DELIVERED,
          Erp::StockTransfers::Transfer::STATUS_DELETED]

# Stock Transfers
Erp::StockTransfers::Transfer.all.destroy_all
(1..50).each do |num|
  ws = Erp::Warehouses::Warehouse.where(id: Erp::Warehouses::Warehouse.pluck(:id).sample(2))
  transfer = Erp::StockTransfers::Transfer.create(
    code: 'ST'+ num.to_s.rjust(3, '0'),
    received_at: Time.now,
    source_warehouse_id: ws.first.id,
    destination_warehouse_id: ws.second.id,
    status: status[rand(status.count)],
    creator_id: user.id
  )
  Erp::Products::Product.where(id: Erp::Products::Product.pluck(:id).sample(rand(90..200))).each do |product|
    dd = Erp::StockTransfers::TransferDetail.create(
      product_id: product.id,
      transfer_id: transfer.id,
      quantity: rand(1..3),
      state_id: Erp::Products::State.order("RANDOM()").first.id
    )
  end
  puts '==== Stock transfer ' +num.ordinalize+ ' complete ('+transfer.code+') ===='
end
