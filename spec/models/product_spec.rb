require 'spec_helper'

describe Product, ".instance methods with images" do
  before(:each) do
    @product = create(:product_with_image)
  end

  context "featured_image" do
    pending "test for featured_image"
    #it 'returns an image url' do
      # @your_model.should_receive(:save_attached_files).and_return(true)
      # Image.new :photo => File.new(Rails.root + 'spec/fixtures/images/rails.png')
    #  @product.featured_image.should_not be_nil
    #end

  end
end

describe Product, ".tax_rate" do

  before(:each) do
    tr = TaxRate.new()
    tr.send(:expire_cache)
  end

  # use case tax rate end date is nil and the start_date < now
  it 'returns the tax rate' do
    Settings.tax_per_state_id = true
    tax_rate    = create(:tax_rate,
                          :state_id => 1,
                          :start_date => (Time.zone.now - 1.year),
                          :end_date => nil)
    product  = create(:product)
    product.tax_rate(1, Time.zone.now).should == tax_rate
  end
  # use case tax rate end date is next month and the start_date < now
  it 'returns the tax rate' do
    tax_rate    = create(:tax_rate,
                          :state_id => 1,
                          :start_date => (Time.zone.now - 1.year),
                          :end_date => (Time.zone.now + 1.month))
    product  = create(:product)
    product.tax_rate(1, Time.zone.now).should == tax_rate
  end
  # use case tax rate end date is one month ago and the start_date < now but the time was 2 months ago
  it 'returns the tax rate' do
    tax_rate    = create(:tax_rate,
                          :state_id => 1,
                          :start_date => (Time.zone.now - 1.year),
                          :end_date => (Time.zone.now - 1.month))
    Rails.cache.delete("TaxRate-active_at_ids-#{(Time.zone.now - 2.month).to_date}")
    product  = create(:product)
    product.tax_rate(1, (Time.zone.now - 2.month)).should == tax_rate
  end
  # there are no tax rates
  it 'does not return the tax rate' do
    product  = create(:product)
    product.tax_rate(1, (Time.zone.now - 2.month)).should be_nil
  end
  # the tax rate starts next month
  it 'does not return any tax rates' do
    tax_rate    = create(:tax_rate,
                          :state_id   => 1,
                          :start_date => (Time.zone.now - 1.month),
                          :end_date   => nil)
    product  = create(:product)
    product.tax_rate(1, (Time.zone.now - 2.month)).should be_nil
  end
  # the tax rate changes next month but is 5% now and next month will be 10%
  it 'returns any tax rates of 5%' do
    Settings.tax_per_state_id = true
    tax_rate    = create(:tax_rate,
                          :percentage => 5.0,
                          :state_id   => 1,
                          :start_date => (Time.zone.now - 1.year),
                          :end_date   => (Time.zone.now + 1.month))

    tax_rate2    = create(:tax_rate,
                          :percentage => 10.0,
                          :state_id   => 1,
                          :start_date => (Time.zone.now + 1.month),
                          :end_date   => (Time.zone.now + 1.year))
    product  = create(:product)
    product.tax_rate(1).should == tax_rate
  end

  it 'tax the countries tax rate' do
    Settings.tax_per_state_id = false
    tax_rate    = create(:tax_rate,
                          :percentage => 5.0,
                          :country_id   => 1,
                          :start_date => (Time.zone.now - 1.year),
                          :end_date   => (Time.zone.now + 1.month))
    product  = create(:product)
    product.tax_rate(1).should == tax_rate
    Settings.tax_per_state_id = true
  end

end

describe Product, ".instance methods" do
  before(:each) do
    product  = create(:product)
    @previous_master = create(:variant, :product => product, :master => true, :price => 15.05, :deleted_at => (Time.zone.now - 1.day ))
    create(:variant, :product => product, :master => true, :price => 15.01)
    create(:variant, :product => product, :master => false, :price => 10.00)
    @product  = Product.find(product.id)
  end

  context "featured_image" do

    it 'returns no_image url' do
      @product.featured_image.should        == 'no_image_small.jpg'
      @product.featured_image(:mini).should == 'no_image_mini.jpg'
    end

  end

  context ".price" do
    it 'returns the lowest price' do
      @product.price.should == 10.00
    end
  end

  context ".set_keywords=(value)" do
    it 'set keywords' do
      @product.set_keywords             =  'hi, my, name, is, Dave'
      @product.product_keywords.should  == ['hi', 'my', 'name', 'is', 'Dave']
      @product.set_keywords.should      == 'hi, my, name, is, Dave'
    end
  end

  context ".display_price_range(j = ' to ')" do
    it 'returns the price range' do
      @product.display_price_range.should == '10.0 to 15.01'
    end
  end

  context ".price_range" do
    it 'returns the price range' do
      @product.price_range.should == [10.0, 15.01]
    end
  end

  context ".price_range?" do
    it 'returns the price range' do
      @product.price_range?.should be_true
    end
  end
end


describe Product, "class methods" do

  context "#standard_search(args)" do
    it "search products" do
      product1  = create(:product, :meta_keywords => 'no blah', :name => 'blah')
      product2  = create(:product, :meta_keywords => 'tester blah')
      product1.activate!
      product2.activate!
      args = 'tester'
      products = Product.standard_search(args)
      products.include?(product1).should be_false
      products.include?(product2).should be_true
    end
  end

  context "#featured" do
    pending "test for featured"
  end

  context "#admin_grid(params = {}, active_state = nil)" do

    it "returns Products " do
      product1 = FactoryGirl.create(:product)
      product2 = FactoryGirl.create(:product)
      product1.activate!
      product2.activate!
      admin_grid = Product.admin_grid({}, true)
      admin_grid.size.should == 2
      admin_grid.include?(product1).should be_true
      admin_grid.include?(product2).should be_true
    end
    it "returns deleted Products " do
      product1 = FactoryGirl.create(:product)
      product2 = FactoryGirl.create(:product) 
      admin_grid = Product.admin_grid({}, nil)
      
      admin_grid.size.should == 2

      admin_grid.include?(product1).should be_true
      admin_grid.include?(product2).should be_true
    end
  end
end
