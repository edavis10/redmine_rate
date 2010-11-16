require File.dirname(__FILE__) + '/../test_helper'

class RatesControllerTest < ActionController::TestCase

  def self.should_be_unauthorized(&block)
    should 'should return a forbidden status code' do
      instance_eval(&block)
      assert_response :forbidden
    end
    
    should 'should display the standard unauthorized page' do
      instance_eval(&block)
      assert_template 'common/error'
    end
    
    context "with mime type of xml" do
      
      should "should return an forbidden error" do
        @request.env["HTTP_ACCEPT"] = "application/xml"
        instance_eval(&block)
        assert_response :forbidden
      end
    end

  end

  def mock_rate(stubs={})
    @project = Project.generate!
    stubs = {
      :date_in_effect => Date.today,
      :project => @project,
      :amount => 100.0,
      :user => @user
    }.merge(stubs)
    @mock_rate = Rate.generate(stubs)
  end

  def mock_locked_rate(stubs={})
    @mock_rate = mock_rate
    @mock_rate.time_entries << TimeEntry.generate!
    @mock_rate
  end

  context "as regular user" do
    setup do
      @user = User.generate!
      @request.session[:user_id] = @user.id
    end
    
    context "responding to GET index" do
      should_be_unauthorized { get :index }
    end

    context "responding to GET show" do
      should_be_unauthorized { get :show, :id => "37" }
    end

    context "responding to GET new" do
      should_be_unauthorized { get :new }
    end

    context "responding to GET edit" do
      should_be_unauthorized { get :edit, :id => "37" }
    end

    context "responding to POST create" do
      should_be_unauthorized { post :create, :rate => {:these => 'params'} }
    end

    context "responding to PUT update" do
      should_be_unauthorized { put :update, :id => "37", :rate => {:these => 'params'} }
    end

    context "responding to DELETE destroy" do
      should_be_unauthorized { delete :destroy, :id => "37" }
    end
  end


  context "as an administrator" do
    
    setup do
      @user = User.generate!(:admin => true)
      @request.session[:user_id] = @user.id
    end
    
    context "responding to GET index" do

      should "should redirect to the homepage" do
        get :index
        assert_redirected_to home_url
      end
      
      should "should display an error flash message" do
        get :index
        assert_match /not found/, flash[:error]
      end

      context "with mime type of xml" do
        
        should "should return a 404 error" do
          @request.env["HTTP_ACCEPT"] = "application/xml"
          get :index
          assert_response :not_found
        end
        
      end

    end

    context "responding to GET index with user" do
      setup do
        mock_rate
      end

      should "should expose all historic rates for the user as @rates" do
        get :index, :user_id => @user.id
        assert_equal assigns(:rates), [@mock_rate]
      end

      context "with mime type of xml" do
        
        should "should render all rates as xml" do
          @request.env["HTTP_ACCEPT"] = "application/xml"
          get :index, :user_id => @user.id

          assert_select 'rates' do
            assert_select 'rate' do
              assert_select 'id', :text => @mock_rate.id
            end
          end
          
        end
        
      end

    end

    context "responding to GET show" do
      setup do
        mock_rate
      end

      should "should expose the @requested rate as @rate" do
        get :show, :id => @mock_rate.id
        assert_equal assigns(:rate), @mock_rate
      end
      
      context "with mime type of xml" do

        should "should render the requested rate as xml" do
          @request.env["HTTP_ACCEPT"] = "application/xml"
          get :show, :id => @mock_rate.id

          assert_select 'rate' do
            assert_select 'id', :text => @mock_rate.id
            assert_select 'amount', :text => /100/
          end

        end

      end
      
    end

    context "responding to GET new" do
      
      should "should redirect to the homepage" do
        get :new
        assert_redirected_to home_url
      end
      
      should "should display an error flash message" do
        get :new
        assert_match /not found/, flash[:error]
      end

      context "with mime type of xml" do
        
        should "should return a 404 error" do
          @request.env["HTTP_ACCEPT"] = "application/xml"
          get :new
          assert_response :not_found
        end
        
      end
    end

    context "responding to GET new with user" do
      should 'should be successful' do
        get :new, :user_id => @user.id
        assert_response :success
      end
      
      should "should expose a new rate as @rate" do
        get :new, :user_id => @user.id
        assert assigns(:rate)
        assert assigns(:rate).new_record?
      end

    end

    context "responding to GET edit" do
      setup do
        mock_rate
      end
      
      should "should expose the requested rate as @rate" do
        get :edit, :id => @mock_rate.id
        assert_equal assigns(:rate), @mock_rate
      end
      
      context "on a locked rate" do
        setup do
          mock_locked_rate
        end
        
        should 'should not have a Update button' do
          get :edit, :id => @mock_rate.id
          assert_select "input[type=submit]", :count => 0
        end

        should 'should show the locked icon' do
          get :edit, :id => @mock_rate.id
          assert_select "img[src*=locked.png]"
        end
      end

    end

    context "responding to POST create" do

      context "with valid params" do
        setup do
          @project = Project.generate!
        end
        
        should "should expose a newly created rate as @rate" do
          post :create, :rate => {:project_id => @project.id, :amount => '50', :date_in_effect => Date.today.to_s, :user_id => @user.id}
          assert assigns(:rate)
        end

        should "should redirect to the rate list" do
          post :create, :rate => {:project_id => @project.id, :amount => '50', :date_in_effect => Date.today.to_s, :user_id => @user.id}

          assert_redirected_to rates_url(:user_id => @user.id)
        end
        
        should 'should redirect to the back_url if set' do
          back_url = '/rates'
          post :create, :rate => {:project_id => @project.id, :amount => '50', :date_in_effect => Date.today.to_s, :user_id => @user.id}, :back_url => back_url

          assert_redirected_to back_url
        end
        
      end
      
      context "with invalid params" do
        should "should expose a newly created but unsaved rate as @rate" do
          post :create, :rate => {}
          assert assigns(:rate).new_record?
        end

        should "should re-render the 'new' template" do
          post :create, :rate => {}
          assert_template 'new'
        end
        
      end
      
    end

    context "responding to PUT udpate" do

      context "with valid params" do
        setup do
          mock_rate
        end

        should "should update the requested rate" do
          put :update, :id => @mock_rate.id, :rate => {:amount => '150'}

          assert_equal 150.0, @mock_rate.reload.amount
        end

        should "should expose the requested rate as @rate" do
          put :update, :id => @mock_rate.id
          
          assert_equal assigns(:rate), @mock_rate
        end

        should "should redirect to the rate list" do
          put :update, :id => "1"

          assert_redirected_to rates_url(:user_id => @user.id)
        end

        should 'should redirect to the back_url if set' do
          back_url = '/rates'
          put :update, :id => "1", :back_url => back_url

          assert_redirected_to back_url
        end

      end
      
      context "with invalid params" do
        setup do
          mock_rate
        end

        should "should not update the requested rate" do
          put :update, :id => @mock_rate.id, :rate => {:amount => 'asdf'}

          assert_equal 100.0, @mock_rate.reload.amount
        end

        should "should expose the rate as @rate" do
          put :update, :id => @mock_rate.id, :rate => {:amount => 'asdf'}
          
          assert_equal assigns(:rate), @mock_rate
        end

        should "should re-render the 'edit' template" do
          put :update, :id => @mock_rate.id, :rate => {:amount => 'asdf'}

          assert_template 'edit'
        end

      end
      
      context "on a locked rate" do
        setup do
          mock_locked_rate
        end
        
        should "should not save the rate" do
          put :update, :id => @mock_rate.id, :rate => {:amount => '150'}

          assert_equal 100, @mock_rate.reload.amount
        end

        should "should set the locked rate as @rate" do
          put :update, :id => @mock_rate.id, :rate => { :amount => 200.0 }

          assert_equal assigns(:rate), @mock_rate
        end
        
        should "should re-render the 'edit' template" do
          put :update, :id => @mock_rate.id

          assert_template 'edit'
        end
        
        should "should render an error message" do
          put :update, :id => @mock_rate.id
          
          assert_match /locked/, flash[:error]
        end
      end

    end

    context "responding to DELETE destroy" do
      setup do
        mock_rate
      end

      should "should destroy the requested rate" do
        assert_difference('Rate.count', -1) do
          delete :destroy, :id => @mock_rate.id
        end
      end
      
      should "should redirect to the user's rates list" do
        delete :destroy, :id => @mock_rate.id
        assert_redirected_to rates_url(:user_id => @user.id)
      end

      should 'should redirect to the back_url if set' do
        back_url = '/rates'
        delete :destroy, :id => "1", :back_url => back_url
        
        assert_redirected_to back_url
      end
      
      context "on a locked rate" do
        setup do
          mock_locked_rate
        end
        
        should "should display an error message" do
          delete :destroy, :id => @mock_rate.id
          assert_match /locked/, flash[:error]
        end
      end

    end

  end
end
