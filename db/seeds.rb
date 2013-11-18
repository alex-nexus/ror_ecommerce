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

puts "SEEDING GEO"
Country.create_all
State.create_all

puts "SEEDING USERS"
Role.create_all

@admin = FactoryGirl.create(:super_admin_user, :with_address, 
  first_name: 'Foundry', last_name: 'Fair', email: "foundry@fair.com")


puts  "SEEDING CATALOG"
AddressType.create_all
PhoneType.create_all
ItemType.create_all
DealType.create_all
Account.create_all
ShippingCategory.create_all
ShippingMethod.create_all
ShippingRateType.create_all
ShippingZone.create_all
TransactionAccount.create_all
ReturnReason.create_all
ReturnCondition.create_all
ReferralBonus.create_all
ReferralProgram.create_all

puts  "SEEDING PRODUCTS"
FactoryGirl.create_list(:property, 5)

@products = FactoryGirl.create_list(:product, 10, :with_properties)
@products.each do |p|
  p.activate!
  FactoryGirl.create(:variant, product: p)
end

puts  "SEEDING ORDERS"

letters = Newsletter.count
puts "Newsletters"
Newsletter::AUTOSUBSCRIBED.each do |name|
  unless Newsletter.where(:name => name).first
    Newsletter.create(:name => name, :autosubscribe => true)
  end
end

if letters == 0
  # Subscribe everyone the first time around
  newsletter_ids = Newsletter.pluck(:id)
  User.find_each do |u|
    u.newsletter_ids = newsletter_ids
    u.save
  end
end

Newsletter::MANUALLY_SUBSCRIBE.each do |name|
  unless Newsletter.where(:name => name).first
    Newsletter.create(:name => name, :autosubscribe => false)
  end
end