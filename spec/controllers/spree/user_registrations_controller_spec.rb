RSpec.describe Spree::UserRegistrationsController, type: :controller do

  before { @request.env['devise.mapping'] = Devise.mappings[:spree_user] }

  context '#create' do
    it 'redirects to after_sign_up_path_for' do
      spree_post :create, { spree_user: { email: 'foobar@example.com', password: 'foobar123', password_confirmation: 'foobar123' } }
      expect(response).to redirect_to spree.root_path
    end
  end
end
