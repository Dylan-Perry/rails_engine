class Api::V1::ItemsController < ApplicationController

  def index
      render json: ItemSerializer.new(Item.all)
  end

  def show
      render json: ItemSerializer.new(Item.find(params[:id]))
  end

  def create
    # Tries to find a merchant record, if record is found it returns true and if not
    # an ActiveRecord::RecordNotFound exception is rescued
    return unless check_merchant_exists(item_params[:merchant_id])

    item = Item.new(item_params)
    item.save!  # This will raise ActiveRecord::RecordInvalid if the item is invalid
    render json: ItemSerializer.new(item), status: :created
  end

  def update
    # Check to see if a merchant_id has been passed (to preserve partial updates)
    # If so, error out if merchant doesn't exist
    if item_params[:merchant_id]
      return unless check_merchant_exists(item_params[:merchant_id])
    end

    render json: ItemSerializer.new(Item.update!(params[:id], item_params))
  end

  def destroy
    item = Item.find(params[:id].to_i)

    item.invoices.each do |invoice|
      if invoice.invoice_items.count == 1
        invoice.invoice_items.destroy_all  # Destroys associated invoice items first
        invoice.destroy
      end
    end

    item.destroy
    head :no_content # sends a 204 no content response
  end

private

  def item_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id )
  end

  def check_merchant_exists(merchant_id)
    Merchant.find(merchant_id)
  end
end