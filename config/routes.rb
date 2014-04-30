#ActionController::Routing::Routes.draw do |map|
#  map.resources :rates
#  map.connect 'rate_caches', :conditions => {:method => :put}, :controller => 'rate_caches', :action => 'update'
#end

#ActionController::Routing::Routes.draw do

RedmineApp::Application.routes.draw do
	resources :rates
	put 'rate_caches', to: 'rate_caches#update'
end
