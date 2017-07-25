module Erp::StockTransfers
  class TransferDetail < ApplicationRecord
    belongs_to :product, class_name: 'Erp::Products::Product'
    belongs_to :transfer, inverse_of: :transfer_details
    
    def product_code
      product.nil? ? '' : product.code
    end
    
    def product_name
      product.nil? ? '' : product.name
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
