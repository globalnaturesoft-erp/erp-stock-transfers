module Erp
  module StockTransfers
    module Backend
      class TransfersController < Erp::Backend::BackendController
        before_action :set_transfer, only: [:show, :edit, :update, :destroy, :transfer_details,
                                            :set_draft, :set_activate, :set_delivery, :set_remove]
        before_action :set_transfers, only: [:set_activate_all, :set_delivery_all, :set_remove_all]

        # GET /transfers
        def index
        end

        # POST /transfers/list
        def list
          @transfers = Transfer.search(params).paginate(:page => params[:page], :per_page => 10)

          render layout: nil
        end

        # GET /transfer details
        def transfer_details
          render layout: nil
        end

        # GET /transfers/1
        def show
        end

        # GET /transfers/new
        def new
          @transfer = Transfer.new
          @transfer.received_at = Time.current

          if params[:from_warehouse].present?
            @from_warehouse = params[:from_warehouse].present? ? Erp::Warehouses::Warehouse.find(params[:from_warehouse]) : nil
            @to_warehouse = params[:to_warehouse].present? ? Erp::Warehouses::Warehouse.find(params[:to_warehouse]) : nil
            @transfer_quantity = params[:transfer_quantity]

            @condition = params[:condition]
            @condition_value = params[:condition_value]

            ids = Erp::Products::Product.pluck(:id).sample(rand(90..250))
            @products = Erp::Products::Product.where(id: ids).order(:code)

            @transfer.source_warehouse_id = @from_warehouse.id
            @transfer.destination_warehouse_id = @to_warehouse.id

            @products.each do |product|
              if @condition == 'from_redundant'
                from = rand(@condition_value.to_i..(@condition_value.to_i+4))
                to = rand(0..2)
                transfer = @transfer_quantity
              else
                to = rand(0..@condition_value.to_i)
                from = rand(1..6)
                transfer = from > @transfer_quantity.to_i ? @transfer_quantity.to_i : from
              end

              @transfer.transfer_details.build(
                quantity: transfer,
                product_id: product.id
              )
            end
          end

          if request.xhr?
            render '_form', layout: nil, locals: {transfer: @transfer}
          end
        end

        # GET /transfers/1/edit
        def edit
          authorize! :update, @transfer
        end

        # POST /transfers
        def create
          @transfer = Transfer.new(transfer_params)
          @transfer.creator = current_user
          @transfer.set_draft

          if @transfer.save
            if request.xhr?
              render json: {
                status: 'success',
                text: @transfer.code,
                value: @transfer.id
              }
            else
              redirect_to erp_stock_transfers.edit_backend_transfer_path(@transfer), notice: t('.success')
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
          if @transfer.update(transfer_params)
            @transfer.set_draft
            if request.xhr?
              render json: {
                status: 'success',
                text: @transfer.code,
                value: @transfer.id
              }
            else
              redirect_to erp_stock_transfers.edit_backend_transfer_path(@transfer), notice: t('.success')
            end
          else
            render :edit
          end
        end

        # DELETE /transfers/1
        def destroy
          @transfer.destroy

          respond_to do |format|
            format.html { redirect_to erp_stock_transfers.backend_transfers_path, notice: t('.success') }
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end

        # Activate /transfers/status?id=1
        def set_activate
          authorize! :activate, @transfer
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
          authorize! :delivery, @transfer
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
          authorize! :delete, @transfer
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
          authorize! :activate, @transfer
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
          authorize! :delivery, @transfer
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
          authorize! :delete, @transfer
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
