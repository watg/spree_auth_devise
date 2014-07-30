class Spree::UserSessionsController < Devise::SessionsController
  helper 'spree/base', 'spree/store'
  if Spree::Auth::Engine.dash_available?
    helper 'spree/analytics'
  end

  include Spree::Core::ControllerHelpers::Auth
  include Spree::Core::ControllerHelpers::Common
  include Spree::Core::ControllerHelpers::Order
  include Spree::Core::ControllerHelpers::SSL
  include Spree::Core::ControllerHelpers::Analytics

  ssl_required :new, :create, :destroy, :update
  ssl_allowed :login_bar

  def create
    Rails.logger.info "0"
    authenticate_spree_user!
    Rails.logger.info "1"
    set_tracking_cookie(spree_current_user)
    Rails.logger.info "2"

    if spree_user_signed_in?
      Rails.logger.info "3"
      respond_to do |format|
        format.html {
          Rails.logger.info "4"
          flash[:success] = Spree.t(:logged_in_succesfully)
          redirect_back_or_default(after_sign_in_path_for(spree_current_user))
        }
        format.js {
          Rails.logger.info "5"
          render :json => {:user => spree_current_user,
                           :ship_address => spree_current_user.ship_address,
                           :bill_address => spree_current_user.bill_address}.to_json
        }
      end
    else
      respond_to do |format|
        format.html {
          Rails.logger.info "6"
          flash.now[:error] = t('devise.failure.invalid')
          render :new
        }
        format.js {
          Rails.logger.info "7"
          render :json => { error: t('devise.failure.invalid') }, status: :unprocessable_entity
        }
      end
    end
  end

  def nav_bar
    render :partial => 'spree/shared/nav_bar'
  end

  def destroy
    delete_tracking_cookie
    super
  end

  private
    def accurate_title
      Spree.t(:login)
    end

    def redirect_back_or_default(default)
      redirect_to(session["spree_user_return_to"] || default)
      session["spree_user_return_to"] = nil
    end
end
