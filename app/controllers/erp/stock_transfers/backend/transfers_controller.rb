module Erp
  module StockTransfers
    module Backend
      class TransfersController < Erp::Backend::BackendController
        before_action :set_transfer, only: [:show_list, :pdf, :show, :edit, :update, :destroy, :transfer_details,
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
          #authorize! :read, @delivery

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
          @transfer.received_at = Time.current

          if params.to_unsafe_hash[:from_warehouse].present?
            global_filters = params.to_unsafe_hash

            @from_warehouse = global_filters[:from_warehouse].present? ? Erp::Warehouses::Warehouse.find(global_filters[:from_warehouse]) : nil
            @to_warehouse = global_filters[:to_warehouse].present? ? Erp::Warehouses::Warehouse.find(global_filters[:to_warehouse]) : nil
            @state = global_filters[:state].present? ? Erp::Products::State.find(global_filters[:state]) : nil
            @transfer_quantity = global_filters[:transfer_quantity]

            @condition = global_filters[:condition]
            @condition_value = global_filters[:condition_value]

            # get categories
            category_ids = global_filters[:categories].present? ? global_filters[:categories] : nil
            @categories = Erp::Products::Category.where(id: category_ids)

            # get diameters
            diameter_ids = global_filters[:diameters].present? ? global_filters[:diameters] : nil
            @diameters = Erp::Products::PropertiesValue.where(id: diameter_ids)

            # get diameters
            letter_ids = global_filters[:letters].present? ? global_filters[:letters] : nil
            @letters = Erp::Products::PropertiesValue.where(id: letter_ids)

            # get numbers
            number_ids = global_filters[:numbers].present? ? global_filters[:numbers] : nil
            @numbers = Erp::Products::PropertiesValue.where(id: number_ids)

            # query
            @product_query = Erp::Products::Product.joins(:cache_stocks)
            @product_query = @product_query.where(category_id: category_ids) if category_ids.present?
            # filter by diameters
            if diameter_ids.present?
              if !diameter_ids.kind_of?(Array)
                @product_query = @product_query.where("erp_products_products.cache_properties LIKE '%[\"#{diameter_ids}\",%'")
              else
                diameter_ids = (diameter_ids.reject { |c| c.empty? })
                if !diameter_ids.empty?
                  qs = []
                  diameter_ids.each do |x|
                    qs << "(erp_products_products.cache_properties LIKE '%[\"#{x}\",%')"
                  end
                  @product_query = @product_query.where("(#{qs.join(" OR ")})")
                end
              end
            end
            # filter by letters
            if letter_ids.present?
              if !letter_ids.kind_of?(Array)
                @product_query = @product_query.where("erp_products_products.cache_properties LIKE '%[\"#{letter_ids}\",%'")
              else
                letter_ids = (letter_ids.reject { |c| c.empty? })
                if !letter_ids.empty?
                  qs = []
                  letter_ids.each do |x|
                    qs << "(erp_products_products.cache_properties LIKE '%[\"#{x}\",%')"
                  end
                  @product_query = @product_query.where("(#{qs.join(" OR ")})")
                end
              end
            end
            # filter by numbers
            if number_ids.present?
              if !number_ids.kind_of?(Array)
                @product_query = @product_query.where("erp_products_products.cache_properties LIKE '%[\"#{number_ids}\",%'")
              else
                number_ids = (number_ids.reject { |c| c.empty? })
                if !number_ids.empty?
                  qs = []
                  number_ids.each do |x|
                    qs << "(erp_products_products.cache_properties LIKE '%[\"#{x}\",%')"
                  end
                  @product_query = @product_query.where("(#{qs.join(" OR ")})")
                end
              end
            end


            if @to_warehouse.present? and @from_warehouse.present? and @state.present?
              if @condition == 'to_required'
                #ids = Erp::Products::Product.pluck(:id).sample(rand(90..250))
                #@products = Erp::Products::Product.where(id: ids).order(:code)
                @product_query = @product_query.where(erp_products_cache_stocks: {warehouse_id: @to_warehouse.id, state_id: @state.id})
                  .where("stock <= ?", @condition_value)
              elsif @condition == 'from_redundant'
                @product_query = @product_query.where(erp_products_cache_stocks: {warehouse_id: @from_warehouse.id, state_id: @state.id})
                  .where("stock > ?", @condition_value)
              end
            end

            @products = @product_query
            logger.info "###################sssss###################"
            logger.info @products.count

            ##################################################################
            @transfer.source_warehouse_id = @from_warehouse.id
            @transfer.destination_warehouse_id = @to_warehouse.id

            @products.each do |product|
              if @condition == 'from_redundant'
                from = Erp::Products::CacheStock.where(product_id: product.id)
                    .where(warehouse_id: @from_warehouse.id)
                    .where(state_id: @state.id).first.stock
                to = Erp::Products::CacheStock.where(product_id: product.id)
                    .where(warehouse_id: @to_warehouse.id)
                    .where(state_id: @state.id).first.stock
                transfer = from - @condition_value.to_i
              else
                to = Erp::Products::CacheStock.where(product_id: product.id)
                    .where(warehouse_id: @to_warehouse.id)
                    .where(state_id: @state.id).first.stock
                from = Erp::Products::CacheStock.where(product_id: product.id)
                    .where(warehouse_id: @from_warehouse.id)
                    .where(state_id: @state.id).first.stock
                transfer = from > @transfer_quantity.to_i ? @transfer_quantity.to_i : from
              end

              if transfer > 0

                @transfer.transfer_details.build(
                  quantity: transfer,
                  product_id: product.id,
                  state_id: @state.id
                )
              end
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
