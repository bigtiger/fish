require File.dirname(__FILE__) + '/../spec_helper'

describe PetsController, "new with a valid pet" do
  before(:each) do
    Pet.stub!(:new).and_return(@pet = mock_model(Pet, :save=>true))
  end
  
  def do_create
    post :create, :pet=>{:name=>"rover", :type =>"dog"}
  end
  
  it "should create the pet" do
    Pet.should_receive(:new).and_return(@pet)
    do_create
  end
  
  it "should save the pet" do
    @pet.should_receive(:save).and_return(true)
    do_create
  end
  
  it "should be redirect" do
    do_create
    response.should be_redirect
  end
  
  it "should assign pet" do
    do_create
    assigns(:pet).should == @pet
  end
  
  it "should redirect to the index path" do
    do_create
    # fixme: redirect appropriately
    response.should redirect_to(users_path)
  end
end
