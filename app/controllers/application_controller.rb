class ApplicationController < ActionController::API
  def authenticate_user!
    token = request.headers["Authorization"]&.split(" ")&.last

    if token.present?
      response = Faraday.get("http://users-service:3000/validate") do |req|
        req.headers["Authorization"] = "Bearer #{token}"
      end

      if response.status == 200
        data = JSON.parse(response.body)
        @current_user_id = data["user_id"]
      else
        render json: { error: "Unauthorized", response: response }, status: :unauthorized
      end
    else
      render json: { error: "Missing token 1" }, status: :unauthorized
    end
  end
end
