require File.dirname(__FILE__) + '/../spec_helper'

describe TimeEntry, 'cost' do
  before(:each) do
    @user = mock_model(User)
    @project = mock_model(Project)
    @date = Date.today.to_s
    @time_entry = TimeEntry.new({:user => @user, :project => @project, :spent_on => @date, :hours => 10.0})
  end
  
  it 'should return 0.0 if there are no rates for the user' do
    Rate.should_receive(:amount_for).with(@user, @project, @date).and_return(nil)
    @time_entry.cost.should eql(0.0)
  end

  describe 'should return the product of hours by' do
    it 'the results of Rate.amount_for' do
      Rate.should_receive(:amount_for).with(@user, @project, @date).and_return(200.0)
      @time_entry.cost.should eql(200.0 * @time_entry.hours)
    end

    it 'the assigned rate' do
      rate = mock_model(Rate, :amount => 100.0)
      @time_entry.should_receive(:rate).at_least(:twice).and_return(rate)
      @time_entry.cost.should eql(rate.amount * @time_entry.hours)
    end

  end
end
