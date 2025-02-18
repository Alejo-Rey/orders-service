class OrdersClientService
  def initialize(current_user_id, order_params)
    @current_user_id = current_user_id
    @order_params = order_params
  end

  def call
    order = Order.new(user_id: @current_user_id,
                      status: "created",
                      order_items_attributes: @order_params[:order_items_attributes])

    return { success: false, errors: "Insufficient stock" } unless verify_stock(order.order_items)

    if order.save && update_stock(order)

      { success: true, order: order }
    else

      { success: false, errors: order.errors.full_messages }
    end
  end

  private

  def update_stock(order)
    service = InventoryClientService.update_product_stock({ "products": order.order_items })

    service[:success]
  end

  def verify_stock(order_items)
    order_items.all? do |item|
      stock_info = InventoryClientService.check_product_stock(item.product_id)

      stock_info[:available_stock] && stock_info[:available_stock] >= item.quantity
    end
  end
end
