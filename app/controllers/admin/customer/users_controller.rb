class Admin::Customer::UsersController < Admin::BaseController
  add_breadcrumb "Users", :admin_customer_users_path
  
  def index
    authorize! :view_users, current_user
    @q = User.search(params[:q])
    @users = @q.result(distinct: true).
                order(sort_column + " " + sort_direction).
                page(pagination_page).
                per(pagination_rows)                  
  end

  def show
    @user = User.includes([:shipments, :finished_orders, :return_authorizations]).find(params[:id])    
    @user = UserDecorator.decorate(@user)
  end

  def new
    @user = User.new
    authorize! :create_users, current_user
    form_info
  end

  def create
    @user = User.new(user_params)
    authorize! :create_users, current_user
    if @user.save
      EmailWorker::SendSignUpNotification.perform_async(@user.id)
      flash[:notice] = "Your account has been created. Please check your e-mail for your account activation instructions!"
      redirect_to admin_customer_users_url
    else
      form_info
      render :action => :new
    end
  end

  def edit
    @user = User.includes(:roles).find(params[:id])
    authorize! :create_users, current_user
    form_info
  end

  def update
    params[:user][:role_ids] ||= []
    @user = User.includes(:roles).find(params[:id])
    authorize! :create_users, current_user
    if @user.update_attributes(user_params)
      flash[:notice] = "#{@user.display_name} has been updated."
      redirect_to admin_customer_users_url
    else
      form_info
      render :action => :edit
    end
  end

  def default_sort_column
    'users.first_name'
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation, :first_name, :last_name, :email, :state, :role_ids => [])
  end

  def form_info
    @all_roles = Role.all
    @states    = ['inactive', 'active', 'canceled']
  end  
end