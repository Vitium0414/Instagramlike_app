module SessionsHelper
	def log_in(user)
		session[:user_id] = user.id
	end
	
	def current_user
		@current_user ||= User.find_by(id: session[:user_id])
	end
	
	def current_user?(user)
		user == current_user
	end
	
	def logged_in?
		!current_user.nil?
	end
	
	  # 永続的セッションを破棄する
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end
	
	def log_out
		forget(current_user)
		session.delete(:user_id)
		@current_user = nil
	end
	
	def remember(user)
		user.remember # => DB: remember_digest
		cookies.permanent.signed[:user_id] = user.id
		cookies.permanent[:remember_token] = user.remember_token
	end
	
  # 記憶したURL (もしくはデフォルト値) にリダイレクト
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
	end
	
	  # アクセスしようとしたURLを覚えておく
  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end
end