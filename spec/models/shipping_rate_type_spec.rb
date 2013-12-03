require 'spec_helper'

describe ShippingRateType do
  context "Valid ShippingRateType" do
    ShippingRateType.all.each do |rate|
      it "is valid" do 
        rate.should be_valid
      end
    end
  end#end of context
end