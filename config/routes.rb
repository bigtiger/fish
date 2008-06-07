ActionController::Routing::Routes.draw do |map|
  map.resource :session
  map.resources :users do |user|
    user.resources :pets
  end
  
  map.root :controller => 'users'
end
