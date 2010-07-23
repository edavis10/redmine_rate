require "#{File.dirname(__FILE__)}/../test_helper"

class RoutingTest < ActionController::IntegrationTest
  context "routing rates" do
    should_route :get, "/rates", :controller => "rates", :action => "index"
    should_route :get, "/rates/new", :controller => "rates", :action => "new"
    should_route :get, "/rates/1", :controller => "rates", :action => "show", :id => "1"
    should_route :get, "/rates/1/edit", :controller => "rates", :action => "edit", :id => "1"

    should_route :post, "/rates", :controller => "rates", :action => "create"

    should_route :put, "/rates/1", :controller => "rates", :action => "update", :id => "1"

    should_route :delete, "/rates/1", :controller => "rates", :action => "destroy", :id => "1"
  end
end
