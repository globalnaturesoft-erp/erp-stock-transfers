module Erp
  module StockTransfers
    module ApplicationHelper
      
       # Order dropdown actions
      def stock_transfer_dropdown_actions(transfer)
        actions = []
        actions << {
          text: '<i class="fa fa-rotate-left"></i> '+t('.revert_stock_transfer'),
          href: ''
        }
        actions << {
          text: '<i class="fa fa-edit"></i> '+t('.edit'),
          href: erp_stock_transfers.edit_backend_transfer_path(transfer)
        }
        actions << {
          text: '<i class="fa fa-check-square-o"></i> '+t('.activate'),
          url: erp_stock_transfers.set_activate_backend_transfers_path(id: transfer),
          data_method: 'PUT',
          class: 'ajax-link'
        } if can? :activate, transfer
        actions << {
          text: '<i class="fa fa-truck"></i> '+t('.delivery'),
          url: erp_stock_transfers.set_delivery_backend_transfers_path(id: transfer),
          data_method: 'PUT',
          class: 'ajax-link',
          data_confirm: t('.delivery_confirm')
        } if can? :delivery, transfer
        actions << { divider: true } if can? :export_file, transfer
        actions << {
            text: '<i class="fa fa-file-excel-o"></i> '+t('.export_excel'),
            url: '',
            data_method: '',
            class: 'ajax-link'
        } if can? :export_file, transfer
        actions << {
          text: '<i class="fa fa-file-pdf-o"></i> '+t('.export_pdf'),
          url: '',
          data_method: '',
          class: 'ajax-link'
        } if can? :export_file, transfer
        actions << { divider: true } if can? :delete, transfer
        actions << {
          text: '<i class="fa fa-trash"></i> '+t('.delete'),
          url: erp_stock_transfers.set_remove_backend_transfers_path(id: transfer),
          data_method: 'PUT',
          class: 'ajax-link',
          data_confirm: t('.delete_confirm')
        } if can? :delete, transfer
        
        erp_datalist_row_actions(
          actions
        )
      end
    end
  end
end
