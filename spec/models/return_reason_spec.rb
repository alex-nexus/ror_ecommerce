require 'spec_helper'

describe ReturnReason do
  describe "Seed data" do
    ReturnReason.all.each do |return_reason|
      it "is valid" do 
        return_reason.should be_valid
      end
    end
  end
end