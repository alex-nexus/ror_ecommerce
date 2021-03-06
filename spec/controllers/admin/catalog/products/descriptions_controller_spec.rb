require 'spec_helper'

describe Admin::Catalog::Products::DescriptionsController do
  render_views

  before(:each) do
    activate_authlogic

    @user = create_admin_user
    login_as(@user)
  end

  it "edit action renders edit template" do
    @product = create(:product, :deleted_at => (Time.zone.now - 1.day), :description_markup => nil, :description => nil)
    get :edit, :id => @product.id
    expect(response).to render_template(:edit)
  end

  it "update action renders edit template when model is invalid" do
    @product = create(:product)
    Product.any_instance.stubs(:valid?).returns(false)
    put :update, :id => @product.id, :product => {:name => 'test', :description_markup => 'mark it up'}
    expect(response).to render_template(:edit)
  end

  it "update action redirects when model is valid" do
    @product = create(:product, :deleted_at => (Time.zone.now - 1.day), :description_markup => nil, :description => nil)
    Product.any_instance.stubs(:valid?).returns(true)
    put :update, :id => @product.id, :product => {:description_markup => '**Hi Everybody**'}
    @product.reload
    @product.description.should_not be_nil
    expect(response).to redirect_to(admin_catalog_product_url(@product))
  end
end
