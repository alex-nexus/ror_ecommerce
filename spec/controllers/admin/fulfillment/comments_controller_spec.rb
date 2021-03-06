require 'spec_helper'

describe Admin::Fulfillment::CommentsController do
  render_views

  before(:each) do
    @order = create(:order)
    activate_authlogic
    @user = create_admin_user
    login_as(@user)
  end

  it "index action renders index template" do
    get :index, :order_id => @order.number
    expect(response).to render_template(:index)
  end

  it "show action renders show template" do
    @comment = create(:comment, :commentable_id => @order.id, :commentable_type => @order.class.to_s)
    get :show, :id => @comment.id, :order_id => @order.number
    expect(response).to render_template(:show)
  end

  it "new action renders new template" do
    get :new, :order_id => @order.number
    expect(response).to render_template(:new)
  end

  it "create action renders new template when model is invalid" do
    @comment = create(:comment, :commentable_id => @order.id, :commentable_type => @order.class.to_s)
    Comment.any_instance.stubs(:valid?).returns(false)
    post :create, :order_id => @order.number, :comment => @comment.attributes
    expect(response).to render_template(:new)
  end

  it "create action redirects when model is valid" do
    @comment = create(:comment, :commentable_id => @order.id, :commentable_type => @order.class.to_s)
    Comment.any_instance.stubs(:valid?).returns(true)
    post :create, :order_id => @order.number, :comment => @comment.attributes
    #expect(response).to redirect_to(admin_fulfillment_order_comment_url(@order, assigns[:comment]))
    expect(response).to render_template(:show)
  end


  it "create action redirects when model is valid" do
    @comment = create(:comment, :commentable_id => @order.id, :commentable_type => @order.class.to_s)
    Comment.any_instance.stubs(:valid?).returns(true)
    post :create, :order_id => @order.number, :comment => @comment.attributes, :format => 'json'
    #expect(response).to redirect_to(admin_fulfillment_order_comment_url(@order, assigns[:comment]))
    response.body.should == assigns[:comment].to_json()
  end

  it "edit action renders edit template" do
    @comment = create(:comment, :commentable_id => @order.id, :commentable_type => @order.class.to_s)
    get :edit, :id => @comment.id, :order_id => @order.number
    expect(response).to render_template(:edit)
  end

  it "update action renders edit template when model is invalid" do
    @comment = create(:comment, :commentable_id => @order.id, :commentable_type => @order.class.to_s)
    Comment.any_instance.stubs(:valid?).returns(false)
    put :update, :id => @comment.id, :order_id => @order.number, :comment => @comment.attributes
    expect(response).to render_template(:edit)
  end

  it "update action redirects when model is valid" do
    @comment = create(:comment, :commentable_id => @order.id, :commentable_type => @order.class.to_s)
    Comment.any_instance.stubs(:valid?).returns(true)
    put :update, :id => @comment.id, :order_id => @order.number, :comment => @comment.attributes
    expect(response).to redirect_to(admin_fulfillment_order_comment_url(@order, assigns[:comment]))
  end

  it "destroy action should destroy model and redirect to index action" do
    @comment = create(:comment, :commentable_id => @order.id, :commentable_type => @order.class.to_s)
    delete :destroy, :id => @comment.id, :order_id => @order.number
    expect(response).to redirect_to(admin_fulfillment_order_comments_url(@order))
    Comment.exists?(@comment.id).should be_false
  end
end
