class ApplicationController < ActionController::API

  def authenticate_user!
    token = request.headers['Authorization']&.split(' ')&.last

    if token.present?
      response = HTTParty.get(
        "http://users-service:3000/validate",
        headers: { "Authorization" => "Bearer #{token}" }
      )
      if response.code == 200
        @current_user_id = response.parsed_response["user_id"]
      else
        render json: { error: "Unauthorized" }, status: :unauthorized
      end
    else
      render json: { error: "Missing token" }, status: :unauthorized
    end
  end
end
