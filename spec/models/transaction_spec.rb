require 'spec_helper'

describe Transaction do
  context " Transaction" do
    before(:each) do
      @transaction = build(:transaction)
    end
    
    it "is valid with minimum attribues" do
      @transaction.should be_valid
    end
    
  end
  
end