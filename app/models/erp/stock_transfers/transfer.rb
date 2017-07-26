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
    
    # Filters
    def self.filter(query, params)
      params = params.to_unsafe_hash
      
      # join with users table for search creator
      query = query.joins(:creator)
      
      # join with users table for search source_warehouse/destination_warehouse
      query = query.joins(:source_warehouse)
      query = query.joins(:destination_warehouse)
      
      and_conds = []
      
      #filters
      if params["filters"].present?
        params["filters"].each do |ft|
          or_conds = []
          ft[1].each do |cond|
            or_conds << "#{cond[1]["name"]} = '#{cond[1]["value"]}'"
          end
          and_conds << '('+or_conds.join(' OR ')+')' if !or_conds.empty?
        end
      end
      
      #keywords
      if params["keywords"].present?
        params["keywords"].each do |kw|
          or_conds = []
          kw[1].each do |cond|
            or_conds << "LOWER(#{cond[1]["name"]}) LIKE '%#{cond[1]["value"].downcase.strip}%'"
          end
          and_conds << '('+or_conds.join(' OR ')+')'
        end
      end
      
      # add conditions to query
      query = query.where(and_conds.join(' AND ')) if !and_conds.empty?
      
      # search by a received at
      if params[:date].present?
				date = params[:date].to_date
				query = query.where("received_at >= ? AND received_at <= ?", date.beginning_of_day, date.end_of_day)
			end
      
      return query
    end
    
    def self.search(params)
      query = self.order("created_at DESC")
      query = self.filter(query, params)
      
      return query
    end
    
    def total_quantity
			return transfer_details.sum('quantity')
		end
    
  end
end
