class User
  include Mongoid::Document


  module Defines
    ROLES = {
    	"dep_head" => "Начальник отдела", "deputy_head" => "Зам. начальника отдела",
    	"group_head" => "Начальник группы", "engineer" => "Инженер",
    	"secretary" => "Секретарь", "admin" => "Администратор"
    }

    STATUSES = {
      "not_activated" => "Не активирован",
      "enabled" => "Активен", "disabled" => "Заблокирован",
      "deleted" => "Удален"
    }
  end

  scope :admins, ->  { where(:role => "admin").order_by(:name => 1) }
  scope :simple_users, -> { where(:role.ne => "admin").order_by(:name => 1) }
  scope :enabled, -> { where(:status => "enabled").order_by(:name => 1) }
  scope :exists, -> { where(:status.ne => "deleted").order_by(:name => 1) }
  scope :deleted, -> { where(:status => "deleted").order_by(:name => 1) }

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable
  # devise :database_authenticatable, :registerable,
  #        :recoverable, :rememberable, :trackable, :validatable

  ## Database authenticatable
  field :email,              :type => String, :default => ""
  field :encrypted_password, :type => String, :default => ""

  ## Recoverable
  field :reset_password_token,   :type => String
  field :reset_password_sent_at, :type => Time

  ## Rememberable
  field :remember_created_at, :type => Time

  ## Trackable
  field :sign_in_count,      :type => Integer, :default => 0
  field :current_sign_in_at, :type => Time
  field :last_sign_in_at,    :type => Time
  field :current_sign_in_ip, :type => String
  field :last_sign_in_ip,    :type => String

  ## Confirmable
  # field :confirmation_token,   :type => String
  # field :confirmed_at,         :type => Time
  # field :confirmation_sent_at, :type => Time
  # field :unconfirmed_email,    :type => String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, :type => Integer, :default => 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    :type => String # Only if unlock strategy is :email or :both
  # field :locked_at,       :type => Time

  ## Token authenticatable
  # field :authentication_token, :type => String

  field :name, type: String
  # field :post, type: String
  field :role, type: String
  field :status, type: String, default: "not_activated"
  has_many :docs
  has_many :message_notifications

  validates_presence_of :name
  validates_uniqueness_of :name, case_sensitive: false

  def admin?
    role == "admin"
  end

  def enabled?
    status == "enabled"
  end

  # def human_post
  # 	# POSTS[post] || "UNDEFINED"
  # 	"POSTS UNDEFINED"
  # end

  def human_role
    Defines::ROLES[role] || "Роль #{role} неопределена!"
  end

  def human_status
  	Defines::STATUSES[status] || "Статус #{status} неопределен!"
  end
end
