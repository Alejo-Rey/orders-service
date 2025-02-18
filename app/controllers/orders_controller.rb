class OrdersController < ApplicationController
  before_action :authenticate_user!, only: [ :index, :create ]


  def index
    orders = Order.where(user_id: @current_user_id)

    render json: {
      total: orders.size,
      orders: orders.as_json(methods: :total_units, include: :order_items)
    }, status: :ok
  end

  def create
    service = OrdersClientService.new(@current_user_id, order_items_params).call

    if service[:success]
      render json: service[:order], include: :order_items, status: :created
    else
      render json: { errors: service[:errors] }, status: :unprocessable_entity
    end
  end

  private

  def order_items_params
    params.require(:order).permit(order_items_attributes: [ :product_id, :quantity ])
  end
end
