require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "unauthorized", :shared => true do
  it 'should not be successful' do
    do_action
    response.should_not be_success
  end
  
  it 'should return a 403 status code' do
    do_action
    response.code.should eql("403")
  end
  
  it 'should display the standard unauthorized page' do
    do_action
    response.should render_template('common/403')
  end
  
  describe "with mime type of xml" do
  
    it "should return a 403 error" do
      request.env["HTTP_ACCEPT"] = "application/xml"
      do_action
      response.response_code.should eql(403)
    end
  end

end

describe RatesController, "as regular user" do
  integrate_views

  def mock_rate(stubs={})
    @mock_rate ||= mock_model(Rate, stubs)
  end
  
  before(:each) do
    @user = mock_model(User, :logged? => true, :admin? => false, :anonymous? => false, :name => "Normal User", :memberships => [])
    User.stub!(:current).and_return(@user)
  end
  
  describe "responding to GET index" do

    def do_action
      get :index
    end
    
    it_should_behave_like "unauthorized"

  end

  describe "responding to GET show" do

    def do_action
      get :show, :id => "37"
    end
    
    it_should_behave_like "unauthorized"

  end

  describe "responding to GET new" do
  
    def do_action
      get :new
    end
    
    it_should_behave_like "unauthorized"

  end

  describe "responding to GET edit" do
  
    def do_action
      get :edit, :id => "37"
    end
    
    it_should_behave_like "unauthorized"
    
  end

  describe "responding to POST create" do
      
    def do_action
      post :create, :rate => {:these => 'params'}
    end
    
    it_should_behave_like "unauthorized"

  end

  describe "responding to PUT udpate" do

    def do_action
      put :update, :id => "37", :rate => {:these => 'params'}
    end
    
    it_should_behave_like "unauthorized"

  end

  describe "responding to DELETE destroy" do

    def do_action
      delete :destroy, :id => "37"
    end
    
    it_should_behave_like "unauthorized"

  end
end


describe RatesController, "as an administrator" do
  integrate_views

  def mock_rate(stubs={})
    project = mock_model(Project)
    stubs = {
      :date_in_effect => Date.today,
      :project => project,
      :project_id => project.id,
      :amount => 100.0,
      :user => @user,
      :user_id => @user.id,
      :unlocked? => true
    }.merge(stubs)
    @mock_rate ||= mock_model(Rate, stubs)
  end

  before(:each) do
    @user = mock_model(User, :logged? => true, :admin? => true, :anonymous? => false, :name => "Admin User", :memberships => [])
    User.stub!(:current).and_return(@user)
  end
  
  describe "responding to GET index" do

    it "should redirect to the homepage" do
      get :index
      response.should redirect_to(home_url)
    end
    
    it "should display an error flash message" do
      get :index
      flash[:error].should_not be_nil
    end

    describe "with mime type of xml" do
  
      it "should return a 404 error" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        get :index
        response.response_code.should eql(404)
      end
    
    end

  end

  describe "responding to GET index with user" do
    before(:each) do
      User.stub!(:find).with(@user.id.to_s).and_return(@user)
    end

    it "should expose all historic rates for the user as @rates" do
      Rate.should_receive(:history_for_user).with(@user).and_return([mock_rate])
      get :index, :user_id => @user.id
      assigns[:rates].should == [mock_rate]
    end

    describe "with mime type of xml" do
  
      it "should render all rates as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        Rate.should_receive(:history_for_user).with(@user).and_return(rates = mock("Array of Rates"))
        rates.should_receive(:to_xml).and_return("generated XML")
        get :index, :user_id => @user.id
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
