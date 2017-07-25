puts "---------- Stock Transfers Engine ------------"
user = Erp::User.first

puts "Create sample contact"
Erp::Contacts::Contact.where(name: "Ortho-K Viet Nam").destroy_all
owner = Erp::Contacts::Contact.create(
  contact_type: Erp::Contacts::Contact::TYPE_COMPANY,
  name: "Ortho-K Viet Nam",
  code: "#OTK-01C",
  address: "535 An Duong Vuong, Ward 8, Dist.5, HCMC",
  creator_id: user.id
)
puts owner.errors.to_json if !owner.errors.empty?

puts "Create sample warehouse"
Erp::Warehouses::Warehouse.where(name: "Warehouse 1st").destroy_all
warehouse1 = Erp::Warehouses::Warehouse.create(
  name: "Warehouse 1st",
  short_name: "WH-1ST",
  creator_id: user.id,
  contact_id: owner.id
)
puts warehouse1.errors.to_json if !warehouse1.errors.empty?

Erp::Warehouses::Warehouse.where(name: "Warehouse 2nd").destroy_all
warehouse2 = Erp::Warehouses::Warehouse.create(
  name: "Warehouse 2nd",
  short_name: "WH-2ND",
  creator_id: user.id,
  contact_id: owner.id
)
puts warehouse2.errors.to_json if !warehouse2.errors.empty?

puts "Create sample transfer"
Erp::StockTransfers::Transfer.where(code: "ST001").destroy_all
transfer = Erp::StockTransfers::Transfer.create(
  code: "ST001",
  received_at: Time.now,
  source_warehouse_id: warehouse1.id,
  destination_warehouse_id: warehouse2.id,
  creator_id: user.id
)
puts transfer.errors.to_json if !transfer.errors.empty?

puts "Create sample transfer detail"
transfer_detail_1 = Erp::StockTransfers::TransferDetail.create(
  product_id: Erp::Products::Product.first.id,
  transfer_id: transfer.id,
  quantity: 2
)
puts transfer_detail_1.errors.to_json if !transfer_detail_1.errors.empty?

transfer_detail_2 = Erp::StockTransfers::TransferDetail.create(
  product_id: Erp::Products::Product.last.id,
  transfer_id: transfer.id,
  quantity: 1
)
puts transfer_detail_2.errors.to_json if !transfer_detail_2.errors.empty?