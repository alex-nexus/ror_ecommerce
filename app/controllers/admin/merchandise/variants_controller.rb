class Admin::Merchandise::VariantsController < Admin::BaseController
  add_breadcrumb "Variants", :admin_merchandise_product_variants_path
  helper_method :sort_column, :sort_direction
  respond_to :html, :json
  def index
    @product = Product.find(params[:product_id])
    @variants = @product.variants.admin_grid(@product, params).order(sort_column + " " + sort_direction).
                                              page(pagination_page).per(pagination_rows)
  end

  def show
    @variant = Variant.includes(:product).find(params[:id])
    @product  =  @variant.product
    respond_with(@variant)
  end

  def new
    form_info
    @product = Product.find(params[:product_id])
    @variant = @product.variants.new()
  end

  def create
    @product = Product.find(params[:product_id])
    @variant = @product.variants.new(allowed_params)

    if @variant.save
      redirect_to admin_merchandise_product_variants_url(@product)
    else
      form_info
      flash[:error] = "The variant could not be saved"
      render :action => :new
    end
  end

  def edit
    @variant  = Variant.includes(:properties,:variant_properties, {:product => :properties}).find(params[:id])
    @product  =  @variant.product
    form_info
  end

  def update
    @variant = Variant.includes( :product ).find(params[:id])

    if @variant.update_attributes(allowed_params)
      redirect_to admin_merchandise_product_variants_url(@variant.product)
    else
      form_info
      @product  =  @variant.product
      render :action => :edit
    end
  end

  def destroy
    @variant = Variant.find(params[:id])
    @variant.deleted_at = Time.zone.now
    @variant.save

    redirect_to admin_merchandise_product_variants_url(@variant.product)
  end

  private

  def allowed_params
    params.require(:variant).permit(:sku, :name, :price, :cost, :deleted_at, :master, :inventory_id )
  end

    def form_info

    end

    def sort_column
      Variant.column_names.include?(params[:sort]) ? params[:sort] : "id"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end

end
