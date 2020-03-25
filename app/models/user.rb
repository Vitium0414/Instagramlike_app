class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :lockable, :timeoutable, :omniauthable, omniauth_providers: [:facebook]
         
  has_many :microposts, dependent: :destroy
  has_many :active_relationships,  class_name:  "Relationship",
                                   foreign_key: "follower_id",
                                   #  自分のIDとどのIDを紐づけるか
                                   dependent:   :destroy
                                   # ユーザーが削除されたらユーザーのリレーションシップ
                                   # も削除する必要がある
  has_many :passive_relationships, class_name:  "Relationship",
                                   foreign_key: "followed_id",
                                   dependent:   :destroy
  # 定義したメソッドを使用して新たにショートカットを作成(メソッドチェーン)したい場合に
  # has_many through: を使用する
  # @user.active_relationships.map(&:followed)
  has_many :following, 
    through: :active_relationships,
    source: :followed
  has_many :followers,
    through: :passive_relationships,
    source: :follower
                                  
  attr_accessor :remember_token, :activation_token
  before_save :downcase_email
  #　レコードの更新、作成時に反応
  before_create :create_activation_digest
  # レコードの作成時のみに反応
  
  before_save { self.email = email.downcase }
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
  
  def self.find_for_facebook_oauth(auth)
    user = User.where(provider: auth.provider, uid: auth.uid).first

    unless user
      user = User.create( name:     auth.extra.raw_info.name,
                          provider: auth.provider,
                          uid:      auth.uid,
                          email:    auth.info.email,
                          token:    auth.credentials.token,
                          password: Devise.friendly_token[0,20] )
    end

    return user
  end
  # def self.from_omniauth(auth)
  #   where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
  #   user.email = auth.info.email
  #   user.password = Devise.friendly_token[0, 20]
  #   user.name = auth.info.name
  #   user.image = auth.info.image # 要imageカラム追加
  #   end
  # end
  
  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end
    
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost) 
  end
  
  def User.new_token
    SecureRandom.urlsafe_base64
  end
  
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end
  
  # 渡されたトークンがダイジェストと一致したらtrueを返す
  def authenticated?(remember_token)
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end
  
  def forget
  update_attribute(:remember_digest, nil)
  end
  
  # current_user.feed
  # current_user.id
  # current_user.microposts
  # 自分と自分がフォローしているアカウントの投稿を、feedに表示させたいためSQL文を使用
  def feed
    Micropost.where("user_id IN (?) OR user_id = ?", following_ids, id)
  end
  
  def follow(other_user)
    following << other_user
  end
  
  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user).destroy
  end
  
   # 現在のユーザーがフォローしてたらtrueを返す
  def following?(other_user)
    following.include?(other_user)
  end
  
  private
  
    def downcase_email
      self.email = email.downcase
    end
    
    def create_activation_digest
      self.activation_token = User.new_token
      self.activation_digest = User.digest(activation_token)
      # @user.activation_digest => ハッシュ値
    end
    
    def self.dummy_email(auth)
      "#{auth.uid}-#{auth.provider}@example.com"
    end
end
