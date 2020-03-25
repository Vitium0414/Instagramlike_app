class SessionsController < ApplicationController

  # GET /login
  def new
    # @session = Session.new
  end
  
  # POST /login
  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      log_in user
      params[:session][:remember_me] == '1' ? remember(user) : forget(user) #SessionHelper
      redirect_back_or user
    else
      flash.now[:danger] = "メールアドレスとパスワードが異なります。"
      render 'new'
    end
  end

# DELETE /logout
  def destroy
    log_out 
    flash[:success] = "ログアウトしました"
    redirect_to root_url
  end
end