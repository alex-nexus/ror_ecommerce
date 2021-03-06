# ADDRESS DOCUMENTATION
#
# The users table represents...  ADDRESSES!!!
#
# There really isn't anything special about addresses themselves.
# However PLEASE PLEASE PLEASE never ever implement @address.delete or @address.destroy or
#   even @address.update_attributes.  You should only create and inactivate addresses.
#   This means EDIT == create and inactivate the old address.
#
# == Schema Information
#
# Table name: addresses
#
#  id                :integer(4)      not null, primary key
#  address_type      :stirng
#  first_name        :string(255)
#  last_name         :string(255)
#  addressable_type  :string(255)     not null
#  addressable_id    :integer(4)      not null
#  address1          :string(255)     not null
#  address2          :string(255)
#  city              :string(255)     not null
#  state_id          :integer(4)
#  state_name        :string(255)
#  zip_code          :string(255)     not null
#  phone_id          :integer(4)
#  alternative_phone :string(255)
#  default           :boolean(1)      default(FALSE)
#  bill_default   :boolean(1)      default(FALSE)
#  active            :boolean(1)      default(TRUE)
#  created_at        :datetime
#  updated_at        :datetime
#

class Address < ActiveRecord::Base
  belongs_to :state
  belongs_to :country
  belongs_to :addressable, :polymorphic => true
  has_many :phones, :as => :phoneable
  has_many :shipments

  validates :first_name,   :presence => true, :length => { :maximum => 25 }                           
  validates :last_name,    :presence => true, :length => { :maximum => 25 }                           
  validates :address1,     :presence => true, :length => { :maximum => 255 }
  validates :city,         :presence => true, :length => { :maximum => 75 }
  validates :state_id,     :presence => true,  :if => Proc.new { |address| Settings.require_state_in_address}
  validates :country_code,   :presence => true,  :if => Proc.new { |address| !Settings.require_state_in_address}
  validates :zip_code,     :presence => true,       :length => { :minimum => 5, :maximum => 12 }
  validates :phone,        :phone_number => true, :if => Proc.new { |address| address.phone.present? }

  before_validation :sanitize_data

  attr_accessor :replace_address_id # if you are updating an address set this field.
  
  before_create :default_to_active
  before_save :replace_address, if: :replace_address_id
  after_save  :invalidate_old_defaults

  delegate :shipping_zone_id, :to => :state
   
  def name
    [first_name, last_name].compact.join(' ')
  end

  def active?
    self.is_active
  end

  def inactive!
    self.is_active = false
    save!
  end

  # hash of all the address db attributes except created_at, updated_at, id
  #
  # @param none
  # @ return [Hash] address db attributes except created_at, updated_at, id
  def address_attributes
    attributes.delete_if {|key, value| ["id", 'updated_at', 'created_at'].any?{|k| k == key }}
  end

  # hash of all the address attributes to be passed to a creditcard processor
  #
  # @param none
  # @ return [Hash] address attributes for a creditcard processor
  def cc_params
    { :name     => name,
      :address1 => address1,
      :address2 => address2,
      :city     => city,
      :state    => state.abbreviation,
      :country_code  => 'US',
      :zip      => zip_code      
    }
  end

  def full_address_line
    [address1, address2, city_state_zip, "(#{name})"].compact.join(', ')
  end
  # Use this method to represent the full address as an array compacted
  #
  # @param [none]
  # @return [Array] Array has ("name", "address1", "address2"(unless nil), "city state zip")
  def full_address_array
    [name, address1, address2, city_state_zip].compact
  end

  # Use this method to represent the full address as an array compacted
  #
  # @param [Optional String] default is ', '
  # @return [String] address1 and address2 joined together with the string you pass in
  def address_lines(join_chars = ', ')
    address_lines_array.join(join_chars)
  end


  def address_lines_array
    [address1, address2].delete_if{|add| add.blank?}
  end

  # Use this method to represent the state abbreviation
  #  it is possible the state is nil. in that case the abbreviation will be stored in
  #  the state_name column in the DB
  #
  # @param [none]
  # @return [String] state abbreviation
  def state_abbr_name
    state ? state.abbreviation : state_name
  end

  # Use this method to represent the "city, state.abbreviation"
  #
  # @param [none]
  # @return [String] "city, state.abbreviation"
  def city_state_name
    [city, state_abbr_name].join(', ')
  end

  # Use this method to represent the "city, state.abbreviation"
  #
  # @param [none]
  # @return [String] "city, state.abbreviation"
  def state_country_name
    [state_abbr_name, country.try(:name)].compact.join(', ')
  end

  # Use this method to represent the "city, state.abbreviation zip_code"
  #
  # @param [none]
  # @return [String] "city, state.abbreviation zip_code"
  def city_state_zip
    [city_state_name, zip_code].join(' ')
  end

  private
    # This method is called to ensure data is formated without extra white space before_validation
    def sanitize_data
      sanitize_name
      sanitize_city
      sanitize_zip_code
      sanitize_address
    end

    def default_to_active
      self.is_active ||= true
    end

    def sanitize_zip_code
      self.zip_code    = self.zip_code.strip    unless self.zip_code.blank?
    end

    def sanitize_city
      self.city        = self.city.strip        unless self.city.blank?
    end

    def sanitize_name
      sanitize_first_name
      sanitize_last_name
    end

    def sanitize_first_name
      self.first_name  = self.first_name.strip  unless self.first_name.blank?
    end

    def sanitize_last_name
      self.last_name   = self.last_name.strip   unless self.last_name.blank?
    end

    def sanitize_address
      sanitize_address1
      sanitize_address2
    end

    def sanitize_address1
      self.address1    = self.address1.strip    unless self.address1.blank?
    end

    def sanitize_address2
      self.address2    = self.address2.strip    unless self.address2.blank?
    end

    def replace_address
      Address.where(id: replace_address_id).update_all(is_active: false)
    end

    def invalidate_old_defaults
      [:ship_default, :bill_default].each do |attr|
        if self[attr]
          Address.where({
            addressable_type: addressable_type,
            addressable_id: addressable_id
          }).where("id <> ?", self.id).update_all(attr => false)
        end
      end
    end
end
