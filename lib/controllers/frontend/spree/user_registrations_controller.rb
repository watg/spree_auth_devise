class Spree::UserRegistrationsController < Devise::RegistrationsController
  helper 'spree/base', 'spree/store'

  if Spree::Auth::Engine.dash_available?
    helper 'spree/analytics'
  end

  include Spree::Core::ControllerHelpers::Auth
  include Spree::Core::ControllerHelpers::Common
  include Spree::Core::ControllerHelpers::Order
  include Spree::Core::ControllerHelpers::SSL
  include Spree::Core::ControllerHelpers::Store

  ssl_required
  before_filter :check_permissions, :only => [:edit, :update]
  skip_before_filter :require_no_authentication

  # GET /resource/sign_up
  def new
    super
    @user = resource
  end

  # POST /resource/sign_up
  def create
    # We do not want to persist the login_email after the person has signed up
    session[:login_email] = nil

    @user = Spree::User.where(email: params[:spree_user][:email], enrolled: false).first
    if @user
      @user.attributes = spree_user_params
    else
      @user = build_resource(spree_user_params)
    end
    if @user.save
      @user.update_column(:enrolled, true)
      sign_in(:spree_user, @user)
      session[:spree_user_signup] = true
      associate_user

      respond_to do |format|
        format.html {
          set_flash_message(:notice, :signed_up)
          sign_in_and_redirect(:spree_user, @user)
        }
        format.js {
          render :json => {:user => spree_current_user}
        }
      end

    else
      @user = build_resource(spree_user_params)
      @user.valid?
      clean_up_passwords(@user)
      respond_to do |format|
        format.html {
          render :new
        }
        format.js {
          render :json => { error: @user.errors }
        }
      end
    end
  end

  # GET /resource/edit
  def edit
    super
  end

  # PUT /resource
  def update
    super
  end

  # DELETE /resource
  def destroy
    super
  end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  def cancel
    super
  end

  protected
    def check_permissions
      authorize!(:create, resource)
    end

  private
    def spree_user_params
      # if the user is subscribed to the newsletter, don't unsubscribe them
      params[:spree_user].delete(:subscribed) if params[:spree_user][:subscribed] == "0"
      params.require(:spree_user).permit(Spree::PermittedAttributes.user_attributes)
    end
end
