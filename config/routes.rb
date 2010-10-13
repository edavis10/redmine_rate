ActionController::Routing::Routes.draw do |map|
  map.resources :rates
  map.connect 'rate_caches', :conditions => {:method => :put}, :controller => 'rate_caches', :action => 'update'
end
