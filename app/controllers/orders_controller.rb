class OrdersController < ApplicationController
  before_action :authenticate_user!, :only => [:create]


  def index
    orders = Order.all

    render json: orders, status: :ok
  end

  def create
    order = Order.new(user_id: @current_user_id,
                      status: "created",
                      order_items_attributes: order_items_params)

    if verify_stock(order.order_items)
      if order.save
        render json: order, include: :order_items, status: :created
      else
        render json: { errors: order.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: "Insufficient stock" }, status: :unprocessable_entity
    end
  end

  private

  def verify_stock(order_items)
    order_items.all? do |item|
      response = check_product_stock(item.product_id)
      response[:available_stock] && response[:available_stock] >= item.quantity
    end
  end

  def check_product_stock(product_id)
    response = HTTParty.get("http://inventory-service:3001/products/#{product_id}")
    if response.code == 200
      { available_stock: response.parsed_response["quantity"] }
    else
      { available_stock: 0 }
    end
  end

  def order_items_params
    params.require(:order).permit(order_items_attributes: [ :product_id, :quantity ])
  end
end
