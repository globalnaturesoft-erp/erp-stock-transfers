module Erp::StockTransfers
  class Transfer < ApplicationRecord
    belongs_to :creator, class_name: "Erp::User"
    if Erp::Core.available?("warehouses")
			belongs_to :source_warehouse, class_name: "Erp::Warehouses::Warehouse", foreign_key: :source_warehouse_id
			belongs_to :destination_warehouse, class_name: "Erp::Warehouses::Warehouse", foreign_key: :destination_warehouse_id
			
			# display warehouse name
			def source_warehouse_name
        source_warehouse.present? ? source_warehouse.name : ''
      end
			
			def destination_warehouse_name
        destination_warehouse.present? ? destination_warehouse.name : ''
      end
		end
    has_many :transfer_details, inverse_of: :transfer, dependent: :destroy
    accepts_nested_attributes_for :transfer_details, :reject_if => lambda { |a| a[:product_id].blank? || a[:quantity].blank? || a[:quantity].to_i <= 0 }
    
    def self.search(params)
      query = self.order("created_at DESC")
      query = self.all
      
      return query
    end
    
    def total_quantity
			return transfer_details.sum('quantity')
		end
    
  end
end
