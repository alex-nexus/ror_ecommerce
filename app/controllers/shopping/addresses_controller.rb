class Shopping::AddressesController < Shopping::BaseController
  helper_method :countries
  # GET /shopping/addresses
  def index
    @form_address = @shopping_address = Address.new
    if !Settings.require_state_in_address && countries.size == 1
      @shopping_address.country = countries.first
    end
    form_info
  end

  # GET /shopping/addresses/1/edit
  def edit
    form_info
    @form_address = @shopping_address = Address.find(params[:id])
  end

  # POST /shopping/addresses
  def create
    @shopping_address = current_user.addresses.new(allowed_params)
    @shopping_address.default = (current_user.default_shipping_address.nil?)
    @shopping_address.billing_default = (current_user.default_billing_address.nil?)
        
    if @shopping_address.save
      redirect_to(shopping_cart_review_path, :notice => 'Address was successfully created.')
    else
      form_info
      render :action => "index"
    end
  end

  def update
    @shopping_address = current_user.addresses.new(allowed_params)
    @shopping_address.replace_address_id = params[:id] # This makes the address we are updating inactive if we save successfully

    # if we are editing the current default address then this is the default address
    @shopping_address.default = (params[:id].to_i == current_user.default_shipping_address.try(:id))
    @shopping_address.billing_default = (params[:id].to_i == current_user.default_billing_address.try(:id))

    if @shopping_address.save
      redirect_to(shopping_cart_review_path, :notice => 'Address was successfully updated.')
    else
      # the form needs to have an id
      @form_address = current_user.addresses.find(params[:id])
      # the form needs to reflect the attributes to customer entered
      @form_address.attributes = allowed_params
      @states     = State.form_selector
      render :action => "edit"
    end
  end

  def select_address
    address = current_user.addresses.find(params[:id])
    redirect_to shopping_cart_review_path
  end

  def destroy
    @shopping_address = Address.find(params[:id])
    @shopping_address.update_attributes(:active => false)
    redirect_to(shopping_addresses_url)
  end

  private

  def allowed_params
    params.require(:address).permit(:first_name, :last_name, :address1, :address2, :city, :state_id, :state_name, :zip_code, :default, :billing_default, :country_id)
  end

  def form_info
    @shopping_addresses = current_user.shipping_addresses
    @states     = State.form_selector
  end

  def countries
    @countries ||= Country.active
  end
end