require File.dirname(__FILE__) + '/../spec_helper'

describe Pet do
  before(:each) do
    @pet = Pet.new
  end

  it "should be valid with a name and type specified" do
    @pet.name = "fido"
    @pet.type = "dog"
    @pet.should be_valid
  end
  
  it "should not be valid if no name specified" do
    @pet.name = ""
    @pet.type = "cat"
    @pet.should_not be_valid
  end
  
  it "should not be valid if no category is specified" do
    @pet.name = "rover"
    @pet.type = ""
    @pet.should_not be_valid
  end
end
