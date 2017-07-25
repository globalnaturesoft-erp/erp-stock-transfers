Erp::StockTransfers::Engine.routes.draw do
  scope "(:locale)", locale: /en|vi/ do
    namespace :backend, module: "backend", path: "backend/stock_transfers" do
      resources :transfers do
        collection do
          post 'list'
          get 'transfer_details'
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