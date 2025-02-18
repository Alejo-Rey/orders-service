class InventoryClientService
  BASE_URL = "http://inventory-service:3001"

  def self.check_product_stock(product_id)
    response = Faraday.get("#{BASE_URL}/products/#{product_id}")

    if response.status == 200
      { available_stock: JSON.parse(response.body)["quantity"] }
    else
      { available_stock: 0 }
    end
  end

  def self.update_product_stock(products)
    response = Faraday.put("#{BASE_URL}/products/bulk_update",
                           products.to_json,
                           { "Content-Type" => "application/json" })

    if response.status == 200
      { success: true }
    else
      { success: false }
    end
  end
end
