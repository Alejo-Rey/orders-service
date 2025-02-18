class OrdersClientService
  def initialize(current_user, order_params)
    @current_user = current_user
    @order_params = order_params
  end

  def call
    order = Order.new(user_id: @current_user["id"],
                      status: "created",
                      order_items_attributes: @order_params[:order_items_attributes])

    return { success: false, errors: "Insufficient stock" } unless verify_stock(order.order_items)

    if order.save && update_stock(order)

      send_notification(@current_user["email"], order.id)
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

  def send_notification(user_email, order_id)
    Faraday.post("http://notifications-service:3003/notifications",
                 { email: user_email, order_id: order_id, message: "Your order ##{order_id} has been created" }.to_json,
                 { "Content-Type" => "application/json" })
  end
end
