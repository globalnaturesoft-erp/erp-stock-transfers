module Erp
  module StockTransfers
    module Backend
      class TransferDetailsController < Erp::Backend::BackendController
        def transfer_line_form
          @transfer_detail = TransferDetail.new
          @transfer_detail.product_id = params[:add_value]
          
          render partial: params[:partial], locals: {
            transfer_detail: @transfer_detail,
            uid: helpers.unique_id()
          }
        end
      end
    end
  end
end
