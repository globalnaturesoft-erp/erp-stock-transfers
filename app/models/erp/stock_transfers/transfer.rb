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
    
    after_save :update_cache_products_count
    before_create :migrate_transfer_code
    
    validates :code, :received_at, :source_warehouse_id, :destination_warehouse_id, presence: true
    
    # class const
    STATUS_DRAFT = 'draft'
    STATUS_ACTIVE = 'active'
    STATUS_DELIVERED = 'delivered'
    STATUS_DELETED = 'deleted'
    
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
      
      # global filters
      global_filter = params[:global_filter]
      
      if global_filter.present?
				
				# filter by transfer from date
				if global_filter[:transfer_from_date].present?
					query = query.where('received_at >= ?', global_filter[:transfer_from_date].to_date.beginning_of_day)
				end
				
				# filter by transfer to date
				if global_filter[:transfer_to_date].present?
					query = query.where('received_at <= ?', global_filter[:transfer_to_date].to_date.end_of_day)
				end
				
				# filter by source warehouse
				if global_filter[:source_warehouse].present?
					query = query.where(source_warehouse_id: global_filter[:source_warehouse])
				end
				
				# filter by destination warehouse
				if global_filter[:destination_warehouse].present?
					query = query.where(destination_warehouse_id: global_filter[:destination_warehouse])
				end
				
			end
      
      return query
    end
    
    def self.search(params)
      query = self.all
      query = self.filter(query, params)
      
      # order
      if params[:sort_by].present?
        order = params[:sort_by]
        order += " #{params[:sort_direction]}" if params[:sort_direction].present?

        query = query.order(order)
      else
				query = query.order('created_at desc')
      end
      
      return query
    end
    
    # Set status for stock transfer
    def set_draft
      update_attributes(status: Erp::StockTransfers::Transfer::STATUS_DRAFT)
    end
    
    def set_activate
      update_attributes(status: Erp::StockTransfers::Transfer::STATUS_ACTIVE)
    end
    
    def set_delivery
      update_attributes(status: Erp::StockTransfers::Transfer::STATUS_DELIVERED)
    end
    
    def set_remove
      update_attributes(status: Erp::StockTransfers::Transfer::STATUS_DELETED)
    end
    
    def self.set_activate_all
      update_all(status: Erp::StockTransfers::Transfer::STATUS_ACTIVE)
    end
    
    def self.set_delivery_all
      update_all(status: Erp::StockTransfers::Transfer::STATUS_DELIVERED)
    end
    
    def self.set_remove_all
      update_all(status: Erp::StockTransfers::Transfer::STATUS_DELETED)
    end
    
    # Check status true?
    def is_draft?
      return self.status == Erp::StockTransfers::Transfer::STATUS_DRAFT
    end
    
    def is_active?
      return self.status == Erp::StockTransfers::Transfer::STATUS_ACTIVE
    end
    
    def is_delivered?
      return self.status == Erp::StockTransfers::Transfer::STATUS_DELIVERED
    end
    
    def is_deleted?
      return self.status == Erp::StockTransfers::Transfer::STATUS_DELETED
    end
    
    # Total item count for transfer details
    def total_quantity
			return transfer_details.sum('quantity')
		end
    
    # Update cache products count
    def update_cache_products_count
			self.update_column(:cache_products_count, self.total_quantity)
		end
    
    # Migrate transfer code
    def migrate_transfer_code
			lastest = Transfer.all.order("id DESC").first
			if !lastest.nil?
				num = lastest.id.to_i + 1
				self.code = "ST" + num.to_s.rjust(3, '0')
			else
				self.code = "ST" + 1.to_s.rjust(3, '0')
			end
		end
    
  end
end
