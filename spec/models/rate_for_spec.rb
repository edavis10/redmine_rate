require File.dirname(__FILE__) + '/../spec_helper'

describe Rate, 'calculated for' do
  before(:each) do
    @user = User.new(:mail => 'metest@example.com', :lastname => 'Test', :firstname => 'Mr')
    @user.login = 'mr-test'
    @user.save!
  end
  
  after(:each) do
    User.destroy_all
  end
  
  describe 'a user with no Rates' do
    it 'should return nil' do
      Rate.for(@user).should be_nil
    end
  end
  
  describe 'a user with one default Rate' do
    it 'should return the Rate if the Rate is effective today' do
      rate = Rate.create!({ :user_id => @user.id, :amount => 100.0, :date_in_effect => Date.today})
      Rate.for(@user).should eql(rate.amount)
    end

    it 'should return nil if the Rate is not effective yet' do
      Rate.for(@user).should be_nil
    end
    
    it 'should return the same default Rate on all projects' do
      project = mock_model(Project)
      rate = Rate.create!({ :user_id => @user.id, :amount => 100.0, :date_in_effect => Date.today})
      Rate.for(@user, project).should eql(rate.amount)
    end
  end
  
  describe 'a user with two default Rates' do
    it 'should return the newest Rate before the todays date' do
      rate = Rate.create!({ :user_id => @user.id, :amount => 100.0, :date_in_effect => Date.yesterday})
      rate2 = Rate.create!({ :user_id => @user.id, :amount => 300.0, :date_in_effect => Date.today})
      Rate.for(@user).should eql(rate2.amount)
    end
  end
  
  describe 'a user with a default Rate and Rate on a project' do
    it 'should return the project Rate if its effective today' do
      project = mock_model(Project)
      rate = Rate.create!({ :user_id => @user.id, :project => project, :amount => 100.0, :date_in_effect => Date.yesterday})
      rate2 = Rate.create!({ :user_id => @user.id, :amount => 300.0, :date_in_effect => Date.today})
      Rate.for(@user, project).should eql(rate.amount)
    end

    it 'should return the default Rate if the project Rate isnt effective yet but the default Rate is' do
      project = mock_model(Project)
      rate = Rate.create!({ :user_id => @user.id, :project => project, :amount => 100.0, :date_in_effect => Date.tomorrow})
      rate2 = Rate.create!({ :user_id => @user.id, :amount => 300.0, :date_in_effect => Date.today})
      Rate.for(@user, project).should eql(rate2.amount)
    end

    it 'should return nil if neither Rate is effective yet' do
      project = mock_model(Project)
      rate = Rate.create!({ :user_id => @user.id, :project => project, :amount => 100.0, :date_in_effect => Date.tomorrow})
      rate2 = Rate.create!({ :user_id => @user.id, :amount => 300.0, :date_in_effect => Date.tomorrow})
      Rate.for(@user, project).should be_nil
    end
  end
  
  describe 'a user with two Rates on a project' do
    it 'should return the newest Rate before the todays date' do
      project = mock_model(Project)
      rate = Rate.create!({ :user_id => @user.id, :project => project, :amount => 100.0, :date_in_effect => Date.yesterday})
      rate2 = Rate.create!({ :user_id => @user.id, :project => project, :amount => 300.0, :date_in_effect => Date.today})
      Rate.for(@user, project).should eql(rate2.amount)
    end
  end
end
