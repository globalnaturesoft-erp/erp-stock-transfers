module Erp::StockTransfers
  class TransferDetail < ApplicationRecord
    belongs_to :product, class_name: 'Erp::Products::Product'
    belongs_to :transfer, inverse_of: :transfer_details
    belongs_to :state, class_name: 'Erp::Products::State'
    
    after_save :update_transfer_cache_products_count
    
    # update order cache products count
    def update_transfer_cache_products_count
			if transfer.present?
				transfer.update_cache_products_count
			end
		end
    
    def product_code
      product.nil? ? '' : product.code
    end
    
    def product_name
      product.nil? ? '' : product.name
    end
    
    def state_name
			state.nil? ? '' : state.name
		end
    
    # @todo: hard code for stock_source and stock_destination
    # Available stock at source
    def stock_source
			return 50
		end
    
    # Available stock at destination
    def stock_destination
			return 50
		end
    
  end
end
