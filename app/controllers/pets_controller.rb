class PetsController < ApplicationController
  def create
    @pet = Pet.new(params[:pet])
    if @pet.save
      # fixme: redirect appropriately
      redirect_to users_path
    else
      render :action => 'new'
    end
  end
end
