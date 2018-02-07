Erp::StockTransfers::Engine.routes.draw do
  scope "(:locale)", locale: /en|vi/ do
    namespace :backend, module: "backend", path: "backend/stock_transfers" do
      resources :transfers do
        collection do
          post 'list'
          get 'transfer_details'
          put 'set_activate'
          put 'set_delivery'
          put 'set_remove'
          put 'set_activate_all'
          put 'set_delivery_all'
          put 'set_remove_all'
          post 'show_list'
          get 'pdf'

          post 'new_import'
        end
      end
      resources :transfer_details do
        collection do
          get 'transfer_line_form'
        end
      end
    end
  end
end
