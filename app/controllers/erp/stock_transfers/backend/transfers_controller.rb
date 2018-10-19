module Erp
  module StockTransfers
    module Backend
      class TransfersController < Erp::Backend::BackendController
        before_action :set_transfer, only: [:show_list, :pdf, :show, :edit, :update, :transfer_details,
                                            :set_draft, :set_activate, :set_delivery, :set_remove]
        before_action :set_transfers, only: [:set_activate_all, :set_delivery_all, :set_remove_all]

        # GET /transfers
        def index
          if Erp::Core.available?("ortho_k")
            authorize! :inventory_stock_transfers_transfers_index, nil
          end
        end

        # POST /transfers/list
        def list
          if Erp::Core.available?("ortho_k")
            authorize! :inventory_stock_transfers_transfers_index, nil
          end
          
          @transfers = Transfer.search(params).paginate(:page => params[:page], :per_page => 10)

          render layout: nil
        end

        # GET /transfer details
        def transfer_details
          render layout: nil
        end

        # GET /transfers/1
        def show
          authorize! :printable, @transfer
          
          respond_to do |format|
            format.html
            format.pdf do
              render pdf: "show_list",
                layout: 'erp/backend/pdf'
            end
          end
        end

        # GET /orders/1
        def pdf
          authorize! :printable, @transfer

          respond_to do |format|
            format.html
            format.pdf do
              if @transfer.transfer_details.count < 8
                render pdf: "#{@transfer.code}",
                  title: "#{@transfer.code}",
                  layout: 'erp/backend/pdf',
                  page_size: 'A5',
                  orientation: 'Landscape',
                  margin: {
                    top: 7,                     # default 10 (mm)
                    bottom: 7,
                    left: 7,
                    right: 7
                  }
              else
                render pdf: "#{@transfer.code}",
                  title: "#{@transfer.code}",
                  layout: 'erp/backend/pdf',
                  page_size: 'A4',
                  margin: {
                    top: 7,                     # default 10 (mm)
                    bottom: 7,
                    left: 7,
                    right: 7
                  }
              end
            end
          end
        end

        # GET /transfers/new
        def new
          @transfer = Transfer.new
          
          authorize! :creatable, @transfer
          
          @transfer.received_at = Time.current

          # Import details list from stocking stransfering page
          if params[:products].present?
            params.to_unsafe_hash[:products].each do |row|
              product = Erp::Products::Product.find(row[0])

              @transfer.source_warehouse_id = params[:from_warehouse_id]
              @transfer.destination_warehouse_id = params[:to_warehouse_id]

              @transfer.transfer_details.build(
                quantity: row[1],
                product_id: product.id,
                state_id: params[:state_id]
              )
            end
          end

          if request.xhr?
            render '_form', layout: nil, locals: {transfer: @transfer}
          end
        end

        # GET /transfers/new
        def new_import
          @transfer = Transfer.new
          
          authorize! :creatable, @transfer
          
          @transfer.received_at = Time.current

          # Import details list from stocking stransfering page
          if params[:products].present?
            params.to_unsafe_hash[:products].each do |row|
              product = Erp::Products::Product.find(row[0])

              @transfer.source_warehouse_id = params[:from_warehouse_id]
              @transfer.destination_warehouse_id = params[:to_warehouse_id]

              @transfer.transfer_details.build(
                quantity: row[1],
                product_id: product.id,
                state_id: params[:state_id]
              )
            end
          end

          render 'new'
        end

        # GET /transfers/1/edit
        def edit
          authorize! :updatable, @transfer
        end

        # POST /transfers
        def create
          @transfer = Transfer.new(transfer_params)
          
          authorize! :creatable, @transfer
          
          @transfer.creator = current_user
          @transfer.set_draft
          @transfer.status = Erp::StockTransfers::Transfer::STATUS_DELIVERED

          if @transfer.save
            if request.xhr?
              render json: {
                status: 'success',
                text: @transfer.code,
                value: @transfer.id
              }
            else
              redirect_to erp_stock_transfers.backend_transfers_path, notice: t('.success')
            end
          else
            if request.xhr?
              render '_form', layout: nil, locals: {transfer: @transfer}
            else
              render :new
            end
          end
        end

        # PATCH/PUT /transfers/1
        def update
          authorize! :updatable, @transfer
          
          if @transfer.update(transfer_params)
            @transfer.set_draft
            if request.xhr?
              render json: {
                status: 'success',
                text: @transfer.code,
                value: @transfer.id
              }
            else
              redirect_to erp_stock_transfers.backend_transfers_path, notice: t('.success')
            end
          else
            render :edit
          end
        end

        # Activate /transfers/status?id=1
        def set_activate
          authorize! :activatable, @transfer
          
          @transfer.set_activate

          respond_to do |format|
          format.json {
            render json: {
            'message': t('.success'),
            'type': 'success'
            }
          }
          end
        end

        # Delivery /transfers/status?id=1
        def set_delivery
          authorize! :deliverable, @transfer
          
          @transfer.set_delivery

          respond_to do |format|
          format.json {
            render json: {
            'message': t('.success'),
            'type': 'success'
            }
          }
          end
        end

        # Remove /transfers/status?id=1
        def set_remove
          authorize! :cancelable, @transfer
          
          @transfer.set_remove

          respond_to do |format|
          format.json {
            render json: {
            'message': t('.success'),
            'type': 'success'
            }
          }
          end
        end

        # ACTIVATE ALL /transfers/status?ids=1,2,3
        def set_activate_all
          authorize! :activatablexxxxxxxxxxxxxxxx, @transfer
          
          @transfers.set_activate_all

          respond_to do |format|
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end

        # DELIVERY ALL /transfers/status?ids=1,2,3
        def set_delivery_all
          authorize! :deliverablexxxxxxxxxxxxxxxx, @transfer
          
          @transfers.set_delivery_all

          respond_to do |format|
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end

        # REMOVE ALL /transfers/status?ids=1,2,3
        def set_remove_all
          authorize! :cancelablexxxxxxxxxxxxxxxx, @transfer
          
          @transfers.set_remove_all

          respond_to do |format|
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end

        private
          # Use callbacks to share common setup or constraints between actions.
          def set_transfer
            @transfer = Transfer.find(params[:id])
          end

          def set_transfers
            @transfers = Transfer.where(id: params[:ids])
          end

          # Only allow a trusted parameter "white list" through.
          def transfer_params
            params.fetch(:transfer, {}).permit(:code, :received_at, :source_warehouse_id, :destination_warehouse_id, :note,
                                               :transfer_details_attributes => [ :id, :product_id, :transfer_id, :quantity, :state_id, :_destroy ])
          end
      end
    end
  end
end
