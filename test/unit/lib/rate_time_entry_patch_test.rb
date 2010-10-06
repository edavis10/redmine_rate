require File.dirname(__FILE__) + '/../../test_helper'

class RateTimeEntryPatchTest < ActiveSupport::TestCase
  def setup
    @user = User.generate!
    @project = Project.generate!
    @date = Date.today.to_s
    @time_entry = TimeEntry.new({:user => @user, :project => @project, :spent_on => @date, :hours => 10.0, :activity => TimeEntryActivity.generate!})
  end
  
  should 'should return 0.0 if there are no rates for the user' do
    assert_equal 0.0, @time_entry.cost
  end

  context 'should return the product of hours by' do
    should 'the results of Rate.amount_for' do
      Rate.generate!(:user => @user, :project => @project, :date_in_effect => @date, :amount => 200.0)
      assert_equal((200.0 * @time_entry.hours), @time_entry.cost)
    end

    should 'the assigned rate' do
      rate = Rate.generate!(:user => @user, :project => @project, :date_in_effect => @date, :amount => 100.0)
      @time_entry.rate = rate
      assert_equal rate.amount * @time_entry.hours, @time_entry.cost
    end

  end

  context "#cost" do
    setup do
      @time_entry.save!
      Rate.generate!(:user => @user, :project => @project, :date_in_effect => @date, :amount => 200.0)
    end
    
    context "without a cache" do
      should "return the calculated cost" do
        @time_entry.update_attribute(:cost, nil)
        assert_equal 2000.0, @time_entry.cost
      end
      
      should "cache the cost to the field" do
        @time_entry.update_attribute(:cost, nil)
        @time_entry.cost

        assert_equal 2000.0, @time_entry.read_attribute(:cost)
        assert_equal 2000.0, @time_entry.reload.read_attribute(:cost)
      end
      
    end

    context "with a cache" do
      setup do
        @time_entry.cache_cost
      end
      
      should "return the cached cost" do
        assert_equal 2000.0, @time_entry.read_attribute(:cost)
        assert_equal 2000.0, @time_entry.cost
      end
      
    end

  end

end
