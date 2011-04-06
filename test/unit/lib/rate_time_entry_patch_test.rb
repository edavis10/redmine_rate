require File.dirname(__FILE__) + '/../../test_helper'

class RateTimeEntryPatchTest < ActiveSupport::TestCase
  def setup
    @user = User.generate!
    @project = Project.generate!
    @date = Date.today.to_s
    @time_entry = TimeEntry.new({:user => @user, :project => @project, :spent_on => @date, :hours => 10.0, :activity => TimeEntryActivity.generate!})
    @rate = Rate.generate!(:user => @user, :project => @project, :date_in_effect => @date, :amount => 200.0)
  end
  
  should 'should return 0.0 if there are no rates for the user' do
    @rate.destroy
    assert_equal 0.0, @time_entry.cost
  end

  context 'should return the product of hours by' do
    should 'the results of Rate.amount_for' do
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
        @time_entry.update_attribute(:cost, 2000.0)
        @time_entry.reload
      end
      
      should "return the cached cost" do
        assert_equal 2000.0, @time_entry.read_attribute(:cost)
        assert_equal 2000.0, @time_entry.cost
      end
      
    end

  end

  context "before save" do
    should "clear and recalculate the cache" do
      assert_equal nil, @time_entry.read_attribute(:cost)

      assert @time_entry.save

      assert_equal 2000.0, @time_entry.read_attribute(:cost)
    end

    should "clear and recalculate the cache when the attribute is already set but stale" do
      # Set the cost
      assert @time_entry.save
      assert_equal 2000.0, @time_entry.read_attribute(:cost)

      @time_entry.reload
      @time_entry.hours = 20
      assert @time_entry.save

      assert_equal 4000.0, @time_entry.read_attribute(:cost)
      assert_equal 4000.0, @time_entry.reload.cost
    end
    

  end
  

end
