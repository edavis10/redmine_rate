require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RatesController do

  def mock_rate(stubs={})
    @mock_rate ||= mock_model(Rate, stubs)
  end
  
  describe "responding to GET index" do

    it "should expose all rates as @rates" do
      Rate.should_receive(:find).with(:all).and_return([mock_rate])
      get :index
      assigns[:rates].should == [mock_rate]
    end

    describe "with mime type of xml" do
  
      it "should render all rates as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        Rate.should_receive(:find).with(:all).and_return(rates = mock("Array of Rates"))
        rates.should_receive(:to_xml).and_return("generated XML")
        get :index
        response.body.should == "generated XML"
      end
    
    end

  end

  describe "responding to GET show" do

    it "should expose the requested rate as @rate" do
      Rate.should_receive(:find).with("37").and_return(mock_rate)
      get :show, :id => "37"
      assigns[:rate].should equal(mock_rate)
    end
    
    describe "with mime type of xml" do

      it "should render the requested rate as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        Rate.should_receive(:find).with("37").and_return(mock_rate)
        mock_rate.should_receive(:to_xml).and_return("generated XML")
        get :show, :id => "37"
        response.body.should == "generated XML"
      end

    end
    
  end

  describe "responding to GET new" do
  
    it "should expose a new rate as @rate" do
      Rate.should_receive(:new).and_return(mock_rate)
      get :new
      assigns[:rate].should equal(mock_rate)
    end

  end

  describe "responding to GET edit" do
  
    it "should expose the requested rate as @rate" do
      Rate.should_receive(:find).with("37").and_return(mock_rate)
      get :edit, :id => "37"
      assigns[:rate].should equal(mock_rate)
    end

  end

  describe "responding to POST create" do

    describe "with valid params" do
      
      it "should expose a newly created rate as @rate" do
        Rate.should_receive(:new).with({'these' => 'params'}).and_return(mock_rate(:save => true))
        post :create, :rate => {:these => 'params'}
        assigns(:rate).should equal(mock_rate)
      end

      it "should redirect to the created rate" do
        Rate.stub!(:new).and_return(mock_rate(:save => true))
        post :create, :rate => {}
        response.should redirect_to(rate_url(mock_rate))
      end
      
    end
    
    describe "with invalid params" do

      it "should expose a newly created but unsaved rate as @rate" do
        Rate.stub!(:new).with({'these' => 'params'}).and_return(mock_rate(:save => false))
        post :create, :rate => {:these => 'params'}
        assigns(:rate).should equal(mock_rate)
      end

      it "should re-render the 'new' template" do
        Rate.stub!(:new).and_return(mock_rate(:save => false))
        post :create, :rate => {}
        response.should render_template('new')
      end
      
    end
    
  end

  describe "responding to PUT udpate" do

    describe "with valid params" do

      it "should update the requested rate" do
        Rate.should_receive(:find).with("37").and_return(mock_rate)
        mock_rate.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :rate => {:these => 'params'}
      end

      it "should expose the requested rate as @rate" do
        Rate.stub!(:find).and_return(mock_rate(:update_attributes => true))
        put :update, :id => "1"
        assigns(:rate).should equal(mock_rate)
      end

      it "should redirect to the rate" do
        Rate.stub!(:find).and_return(mock_rate(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(rate_url(mock_rate))
      end

    end
    
    describe "with invalid params" do

      it "should update the requested rate" do
        Rate.should_receive(:find).with("37").and_return(mock_rate)
        mock_rate.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :rate => {:these => 'params'}
      end

      it "should expose the rate as @rate" do
        Rate.stub!(:find).and_return(mock_rate(:update_attributes => false))
        put :update, :id => "1"
        assigns(:rate).should equal(mock_rate)
      end

      it "should re-render the 'edit' template" do
        Rate.stub!(:find).and_return(mock_rate(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end

    end

  end

  describe "responding to DELETE destroy" do

    it "should destroy the requested rate" do
      Rate.should_receive(:find).with("37").and_return(mock_rate)
      mock_rate.should_receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "should redirect to the rates list" do
      Rate.stub!(:find).and_return(mock_rate(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(rates_url)
    end

  end

end
