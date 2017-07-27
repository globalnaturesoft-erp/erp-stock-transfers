user = Erp::User.first
warehouses = ["ADV", "TRAINING", "TN"]

# Contacts
Erp::Contacts::Contact.where(name: "Ortho-K Vietnam").destroy_all
owner = Erp::Contacts::Contact.create(
  contact_type: Erp::Contacts::Contact::TYPE_COMPANY,
  name: "Ortho-K Vietnam",
  code: "#OTK-01C",
  address: "535 An Duong Vuong, Ward 8, Dist.5, HCMC",
  creator_id: user.id
)
puts owner.errors.to_json if !owner.errors.empty?

# Warehouses
Erp::Warehouses::Warehouse.all.destroy_all
warehouses.each do |name|
  wh = Erp::Warehouses::Warehouse.create(
    name: name,
    short_name: name,
    creator_id: user.id,
    contact_id: owner.id
  )
end

# Stock Transfers
Erp::StockTransfers::Transfer.all.destroy_all
count = 0
count_b = 0
(1..50).each do |num|
  ws = Erp::Warehouses::Warehouse.where(id: Erp::Warehouses::Warehouse.pluck(:id).sample(2))
  transfer = Erp::StockTransfers::Transfer.create(
    code: 'ST'+ num.to_s.rjust(3, '0'),
    received_at: Time.now,
    source_warehouse_id: ws.first.id,
    destination_warehouse_id: ws.second.id,
    creator_id: user.id
  )
  count_b += 1
  puts "BIG: " + count_b.to_s
  Erp::Products::Product.where(id: Erp::Products::Product.pluck(:id).sample(rand(90..200))).each do |product|
    dd = Erp::StockTransfers::TransferDetail.create(
      product_id: product.id,
      transfer_id: transfer.id,
      quantity: rand(1..3)
    )
    count += 1
    puts "###########################BIG: " + count_b.to_s + " / " + count.to_s
  end
  
end