ActionController::Routing::Routes.draw do |map|
  map.resources :rates
  map.connect 'rate_caches', :conditions => {:method => :put}, :controller => 'rate_caches', :action => 'update'
  map.connect 'rate_caches', :controller => 'rate_caches', :action => 'index'
end
