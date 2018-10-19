module Erp
  module StockTransfers
    module ApplicationHelper
      
       # Order dropdown actions
      def stock_transfer_dropdown_actions(transfer)
        actions = []
        
        actions << {
          text: '<i class="fa fa-print"></i> '+t('.view_print'),
          url: erp_stock_transfers.backend_transfer_path(transfer),
          class: 'modal-link',
        } if can? :printable, transfer
        
        actions << {
          text: '<i class="fa fa-edit"></i> '+t('.edit'),
          url: erp_stock_transfers.edit_backend_transfer_path(transfer)
        } if can? :updatable, transfer
        
        actions << {
          text: '<i class="fa fa-check-square-o"></i> '+t('.activate'),
          url: erp_stock_transfers.set_activate_backend_transfers_path(id: transfer),
          data_method: 'PUT',
          class: 'ajax-link'
        } if can? :activatable, transfer
        
        actions << {
          text: '<i class="fa fa-truck"></i> '+t('.delivery'),
          url: erp_stock_transfers.set_delivery_backend_transfers_path(id: transfer),
          data_method: 'PUT',
          class: 'ajax-link',
          data_confirm: t('.delivery_confirm')
        } if can? :deliverable, transfer
        
        if can? :cancelable, transfer
          if (can? :printable, transfer) or (can? :updatable, transfer) or (can? :activatable, transfer) or (can? :deliverable, transfer)
            actions << { divider: true }
          end
        end
        
        actions << {
          text: '<i class="fa fa-trash"></i> '+t('.delete'),
          url: erp_stock_transfers.set_remove_backend_transfers_path(id: transfer),
          data_method: 'PUT',
          class: 'ajax-link',
          data_confirm: t('.delete_confirm')
        } if can? :cancelable, transfer
        
        erp_datalist_row_actions(
          actions
        )
      end
    end
  end
end
