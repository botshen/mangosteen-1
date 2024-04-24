class UsersController < ApplicationController
  def create
    user = User.new name: 'frank',email: params[:email]
    if user.save
      render json: user
    else
      render json: user.errors
    end
  end

  def show
       render json: {
        name: "sssss",
        email: "我爱夏天"
      }
    
  end
end
