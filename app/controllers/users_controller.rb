class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update,
                                        :following, :followers]
  before_action :correct_user,   only: [:edit, :update]
  # 上から順番に評価
  
  def index
    @users = User.paginate(page: params[:pages])
  end
  
  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = "登録が完了しました"
      redirect_to @user
      # redirect_to "users/#{@user.id}"
      # redirect_to user_path(@user.id)
      # redirect_to user_path(@user)
      # redirect_to @user
    else
      render "new"
    end
  end
  
  def edit
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "プロフィールを更新しました"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def following
    @title = "Following"
    @user  = User.find(params[:id])
    @users = @user.following.paginate(page: params[:page])
    render 'show_follow'
  end

  def followers
    @title = "Followers"
    @user  = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end
  
  private

    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation)
    end
    
    # ログインされている事が前提
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end
end