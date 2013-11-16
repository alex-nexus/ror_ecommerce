Rails.logger.info "Cleaning data"
# truncating all tables
ActiveRecord::Base.establish_connection
ActiveRecord::Base.transaction do
  ActiveRecord::Base.connection.tables.each do |table|
    next if %w{schema_migrations}.include?(table)
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{table} CASCADE;")
  end
end

require 'factory_girl_rails'

puts  "START SEEDING"
Country.create_all
State.create_all
Role.create_all
AddressType.create_all
PhoneType.create_all
ItemType.create_all
DealType.create_all
Account.create_all
ShippingRateType.create_all
ShippingZone.create_all
TransactionAccount.create_all
ReturnReason.create_all
ReturnCondition.create_all
ReferralBonus.create_all
ReferralProgram.create_all

#sample shipping category
['table', 'sofa', 'chair', 'rug'].each do |x| 
	ShippingCategory::find_or_create_by(name: x)
end

puts "SEEDING USERS"
@admin = FactoryGirl.create(:super_admin_user, :with_address, 
  first_name: 'Foundry', last_name: 'Fair', email: "foundry@foundryfair.com")

puts  "SEEDING PRODUCTS"
FactoryGirl.create_list(:property, 5)

@products = FactoryGirl.create_list(:product, 10, :deleted_at => nil)
@products.each do |p|
  p.activate!
  FactoryGirl.create(:variant, product: p)
end

puts  "SEEDING ORDERS"