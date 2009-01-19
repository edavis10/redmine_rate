require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RatesController do
  describe "route generation" do
    it "should map #index" do
      route_for(:controller => "rates", :action => "index").should == "/rates"
    end
  
    it "should map #new" do
      route_for(:controller => "rates", :action => "new").should == "/rates/new"
    end
  
    it "should map #show" do
      route_for(:controller => "rates", :action => "show", :id => 1).should == "/rates/1"
    end
  
    it "should map #edit" do
      route_for(:controller => "rates", :action => "edit", :id => 1).should == "/rates/1/edit"
    end
  
    it "should map #update" do
      route_for(:controller => "rates", :action => "update", :id => 1).should == "/rates/1"
    end
  
    it "should map #destroy" do
      route_for(:controller => "rates", :action => "destroy", :id => 1).should == "/rates/1"
    end
  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/rates").should == {:controller => "rates", :action => "index"}
    end
  
    it "should generate params for #new" do
      params_from(:get, "/rates/new").should == {:controller => "rates", :action => "new"}
    end
  
    it "should generate params for #create" do
      params_from(:post, "/rates").should == {:controller => "rates", :action => "create"}
    end
  
    it "should generate params for #show" do
      params_from(:get, "/rates/1").should == {:controller => "rates", :action => "show", :id => "1"}
    end
  
    it "should generate params for #edit" do
      params_from(:get, "/rates/1/edit").should == {:controller => "rates", :action => "edit", :id => "1"}
    end
  
    it "should generate params for #update" do
      params_from(:put, "/rates/1").should == {:controller => "rates", :action => "update", :id => "1"}
    end
  
    it "should generate params for #destroy" do
      params_from(:delete, "/rates/1").should == {:controller => "rates", :action => "destroy", :id => "1"}
    end
  end
end
