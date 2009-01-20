require File.dirname(__FILE__) + '/../spec_helper'

describe Rate, 'for' do
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
    it 'should return the Rate amount if the Rate is in effect' do
      rate = Rate.create!({ :user_id => @user.id, :amount => 100.0, :date_in_effect => Date.today})
      Rate.for(@user).should eql(rate.amount)
    end

    it 'should return nil if the Rate is not in effect yet' do
      Rate.for(@user).should be_nil
    end
    
    it 'should return the same default Rate on a proejct'
  end
end
