require_dependency 'spree/checkout_controller'
Spree::CheckoutController.class_eval do
  before_filter :check_authorization
  before_filter :check_registration, :except => [:registration, :update_registration]

  helper 'spree/users'

  def registration
    @user = Spree::User.new
  end

  def update_registration
    fire_event("spree.user.signup", :order => current_order)
    # hack - temporarily change the state to something other than cart so we can validate the order email address
    current_order.state = current_order.checkout_steps.first
    @user = find_or_create_user(params[:order][:email])
    if current_order.update_attributes(order_params)
      redirect_to checkout_path
    else
      render 'registration'
    end
  end

  private
  def find_or_create_user(email)
    _user  = Spree::User.find_by_email(email)
    if _user.blank?
      _user = Spree::User.create_unenrolled(email: email, uuid: tracking_cookie)
    end
    _user
  end

    def order_params
      if params[:order]
        params.require(:order).permit(:email).merge(user_id: @user.id, created_by_id: @user.id)
      else
        {}
      end
    end

    def skip_state_validation?
      %w(registration update_registration).include?(params[:action])
    end

    def check_authorization
      authorize!(:edit, current_order, session[:access_token])
    end

    # Introduces a registration step whenever the +registration_step+ preference is true.
    def check_registration
      return unless Spree::Auth::Config[:registration_step]
      return if spree_current_user or current_order.email
      store_location
      redirect_to spree.checkout_registration_path
    end

    # Overrides the equivalent method defined in Spree::Core.  This variation of the method will ensure that users
    # are redirected to the tokenized order url unless authenticated as a registered user.
    def completion_route
      return order_path(@order) if spree_current_user
      spree.token_order_path(@order, @order.token)
    end
end
