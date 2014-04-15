module Spree
  class User < ActiveRecord::Base
    include Core::UserAddress
    if Spree.version > '2.2.0' && defined?(Core::UserPaymentSource)
      include Core::UserPaymentSource
    end

    devise :database_authenticatable, :registerable, :recoverable,
           :rememberable, :trackable, :encryptable, :encryptor => 'authlogic_sha512'

    has_many :orders

    before_validation :set_login
    before_destroy :check_completed_orders

    before_validation do
      self.uuid ||= UUID.generate if self.respond_to?(:uuid)
    end

    validates :uuid, uniqueness: true
    validates_presence_of   :email, :if => :email_required?
    validates_uniqueness_of :email, :allow_blank => true,  scope: :enrolled, :if => :email_changed?
    validates_format_of     :email, :with  => Devise.email_regexp, :allow_blank => true, :if => :email_changed?

    validates_presence_of     :password, :if => :password_required?
    validates_confirmation_of :password, :if => :password_required?
    validates_length_of       :password, :within => Devise.password_length, :allow_blank => true

    users_table_name = User.table_name
    roles_table_name = Role.table_name

    scope :admin, -> { includes(:spree_roles).where("#{roles_table_name}.name" => "admin") }
    scope :registered, -> { where("#{users_table_name}.email NOT LIKE ?", "%@example.net") }
    scope :not_enrolled, -> { where(enrolled: false) }

    class DestroyWithOrdersError < StandardError; end

    def self.admin_created?
      User.admin.count > 0
    end


    def self.create_unenrolled(opts={})
      salt = generate_token(:password_salt)
      u = new(email: opts[:email], uuid: opts[:uuid], enrolled: false, password_salt: salt)
      u.save
      u
    end

    def admin?
      has_spree_role?('admin')
    end

    protected
    def password_required?
      if self.enrolled
        !persisted? || password.present? || password_confirmation.present?
      else
        false
      end
    end

    def email_required?
      true
    end

    private

    def check_completed_orders
      raise DestroyWithOrdersError if orders.complete.present?
    end

    def set_login
      # for now force login to be same as email, eventually we will make this configurable, etc.
      self.login ||= self.email if self.email
    end
  end
end
