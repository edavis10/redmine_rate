require File.dirname(__FILE__) + '/../test_helper'

class RateTest < ActiveSupport::TestCase
  def rate_valid_attributes
    { 
      :user => User.generate!,
      :project => Project.generate!,
      :date_in_effect => Date.new(Date.today.year, 1, 1),
      :amount => 100.50
    }
  end

  should_belong_to :project
  should_belong_to :user
  should_have_many :time_entries
  
  should_validate_presence_of :user_id
  should_validate_presence_of :date_in_effect
  should_validate_numericality_of :amount

  
  context '#locked?' do
    should 'should be true if a Time Entry is associated' do
      rate = Rate.new
      rate.time_entries << TimeEntry.generate!
      assert rate.locked?
    end
    
    should 'should be false if no Time Entries are associated' do
      rate = Rate.new
      assert ! rate.locked?
    end
  end
  
    
  context '#unlocked?' do
    should 'should be false if a Time Entry is associated' do
      rate = Rate.new
      rate.time_entries << TimeEntry.generate!
      assert ! rate.unlocked?
    end
    
    should 'should be true if no Time Entries are associated' do
      rate = Rate.new
      assert rate.unlocked?
    end
    
  end

  context '#save' do

    should 'should save if a Rate is unlocked' do
      rate = Rate.new(rate_valid_attributes)
      assert rate.save
    end

    should 'should not save if a Rate is locked' do
      rate = Rate.new(rate_valid_attributes)
      rate.time_entries << TimeEntry.generate!
      assert !rate.save
    end
  end
  



  context '#destroy' do

    should 'should destroy the Rate if should is unlocked' do
      rate = Rate.create(rate_valid_attributes)
      assert_difference('Rate.count', -1) do
        rate.destroy
      end

    end

    should 'should not destroy the Rate if should is locked' do
      rate = Rate.create(rate_valid_attributes)
      rate.time_entries << TimeEntry.generate!

      assert_difference('Rate.count', 0) do
        rate.destroy
      end
    end
  end

  context "after save" do
    should "recalculate all of the cached cost of all Time Entries for the user" do
      @user = User.generate!
      @project = Project.generate!
      @date = Date.today.to_s
      @past_date = 1.month.ago.strftime('%Y-%m-%d')
      @rate = Rate.generate!(:user => @user, :project => @project, :date_in_effect => @date, :amount => 200.0)
      @time_entry1 = TimeEntry.generate!({:user => @user, :project => @project, :spent_on => @date, :hours => 10.0, :activity => TimeEntryActivity.generate!})
      @time_entry2 = TimeEntry.generate!({:user => @user, :project => @project, :spent_on => @past_date, :hours => 20.0, :activity => TimeEntryActivity.generate!})


      assert_equal 2000.00, @time_entry1.cost
      assert_equal 0, @time_entry2.cost

      @old_rate = Rate.generate!(:user => @user, :project => @project, :date_in_effect => 2.months.ago.strftime('%Y-%m-%d'), :amount => 10.0)

      assert_equal 2000.00, TimeEntry.find(@time_entry1.id).cost
      assert_equal 200.00, TimeEntry.find(@time_entry2.id).cost
    end
    
  end
  
  context "after destroy" do
    should "recalculate all of the cached cost of all Time Entries for the user" do
      @user = User.generate!
      @project = Project.generate!
      @date = Date.today.to_s
      @past_date = 1.month.ago.strftime('%Y-%m-%d')
      @rate = Rate.generate!(:user => @user, :project => @project, :date_in_effect => @date, :amount => 200.0)
      @old_rate = Rate.generate!(:user => @user, :project => @project, :date_in_effect => 2.months.ago.strftime('%Y-%m-%d'), :amount => 10.0)

      @time_entry1 = TimeEntry.generate!({:user => @user, :project => @project, :spent_on => @date, :hours => 10.0, :activity => TimeEntryActivity.generate!})
      @time_entry2 = TimeEntry.generate!({:user => @user, :project => @project, :spent_on => @past_date, :hours => 20.0, :activity => TimeEntryActivity.generate!})


      assert_equal 2000.00, @time_entry1.cost
      assert_equal 2000.00, @time_entry1.read_attribute(:cost)
      assert_equal 200.0, @time_entry2.cost
      assert_equal 200.0, @time_entry2.read_attribute(:cost)

      @old_rate.destroy

      assert_equal 2000.0, TimeEntry.find(@time_entry1.id).cost
      assert_equal 0, TimeEntry.find(@time_entry2.id).cost
    end
    
  end

  context '#for' do
    setup do
      @user = User.generate!
      @project = Project.generate!
      @date = '2009-01-01'
      @date = Date.new(Date.today.year, 1, 1).to_s
      @default_rate = Rate.generate!(:amount => 100.10, :date_in_effect => @date, :project => nil, :user => @user)
      @rate = Rate.generate!(:amount => 50.50, :date_in_effect => @date, :project => @project, :user => @user)
    end
    
    context 'parameters' do
      should 'should be passed user' do
        assert_raises ArgumentError do
          Rate.for
        end
      end

      should 'can be passed an optional project' do
        assert_nothing_raised do
          Rate.for(@user)
        end

        assert_nothing_raised do
          Rate.for(@user, @project)
        end
      end
      
      should 'can be passed an optional date string' do
        assert_nothing_raised do
          Rate.for(@user)
        end

        assert_nothing_raised do
          Rate.for(@user, nil, @date)
        end
      end
      
    end

    context 'returns' do
      should 'a Rate object when there is a rate' do
        assert_equal @rate, Rate.for(@user, @project, @date)
      end

      should 'a nil when there is no rate' do
        assert @rate.destroy
        assert @default_rate.destroy
        
        assert_equal nil, Rate.for(@user, @project, @date)
      end
    end
    
    context 'with a user, project, and date' do
      should 'should find the rate for a user on the project before the date' do
        assert_equal @rate, Rate.for(@user, @project, @date)
      end

      should 'should return the most recent rate found' do
        assert_equal @rate, Rate.for(@user, @project, @date)
      end
      
      should 'should check for a default rate if no rate is found' do
        assert @rate.destroy
        
        assert_equal @default_rate, Rate.for(@user, @project, @date)
      end
      
      should 'should return nil if no set or default rate is found' do
        assert @rate.destroy
        assert @default_rate.destroy
        
        assert_equal nil, Rate.for(@user, @project, @date)
      end
    end

    context 'with a user and project' do
      should 'should find the rate for a user on the project before today' do
        assert_equal @rate, Rate.for(@user, @project)
      end

      should 'should return the most recent rate found' do
        assert_equal @rate, Rate.for(@user, @project)
      end

      should 'should return nil if no set or default rate is found' do
        assert @rate.destroy
        assert @default_rate.destroy

        assert_equal nil, Rate.for(@user, @project)
      end
    end

    context 'with a user' do
      should 'should find the rate without a project for a user on the project before today' do
        assert_equal @default_rate, Rate.for(@user)
      end

      should 'should return the most recent rate found' do
        assert_equal @default_rate, Rate.for(@user)
      end

      should 'should return nil if no set or default rate is found' do
        assert @rate.destroy
        assert @default_rate.destroy

        assert_equal nil, Rate.for(@user)
      end
    end
    
    should 'with an invalid user should raise an InvalidParameterException' do
      object = Object.new
      assert_raises Rate::InvalidParameterException do
        Rate.for(object)
      end
    end
    
    should 'with an invalid project should raise an InvalidParameterException' do
      object = Object.new
      assert_raises Rate::InvalidParameterException do
        Rate.for(@user, object)
      end
    end
    
    should 'with an invalid object for date should raise an InvalidParameterException' do
      object = Object.new
      assert_raises Rate::InvalidParameterException do
        Rate.for(@user, @project, object)
      end
    end

    should 'with an invalid date string should raise an InvalidParameterException' do
      assert_raises Rate::InvalidParameterException do
        Rate.for(@user, @project, '2000-13-40')
      end
    end

  end

  context "#update_all_time_entries_with_missing_cost" do
    setup do
      @user = User.generate!
      @project = Project.generate!
      @date = Date.today.to_s
      @rate = Rate.generate!(:user => @user, :project => @project, :date_in_effect => @date, :amount => 200.0)
      @time_entry1 = TimeEntry.generate!({:user => @user, :project => @project, :spent_on => @date, :hours => 10.0, :activity => TimeEntryActivity.generate!})
      @time_entry2 = TimeEntry.generate!({:user => @user, :project => @project, :spent_on => @date, :hours => 20.0, :activity => TimeEntryActivity.generate!})
    end
    
    should "update the caches of all Time Entries" do
      TimeEntry.update_all('cost = null')

      # Check that cost is NULL in the database, which skips the caching
      assert_equal 2, ActiveRecord::Base.connection.select_all('select count(*) as count from time_entries where cost IS NULL').first["count"].to_i

      Rate.update_all_time_entries_with_missing_cost

      assert_equal 0, ActiveRecord::Base.connection.select_all('select count(*) as count from time_entries where cost IS NULL').first["count"].to_i

    end
    
    should "timestamp a successful run" do
      assert_equal nil, Setting.plugin_redmine_rate['last_caching_run']

      Rate.update_all_time_entries_with_missing_cost

      assert Setting.plugin_redmine_rate['last_caching_run'], "Last run not timestamped"
      assert Time.parse(Setting.plugin_redmine_rate['last_caching_run']), "Last run timestamp not parseable"
    end
  end

  context "#update_all_time_entries_to_refresh_cache" do
    setup do
      @user = User.generate!
      @project = Project.generate!
      @date = Date.today.to_s
      @rate = Rate.generate!(:user => @user, :project => @project, :date_in_effect => @date, :amount => 200.0)
      @time_entry1 = TimeEntry.generate!({:user => @user, :project => @project, :spent_on => @date, :hours => 10.0, :activity => TimeEntryActivity.generate!})
      @time_entry2 = TimeEntry.generate!({:user => @user, :project => @project, :spent_on => @date, :hours => 20.0, :activity => TimeEntryActivity.generate!})
    end
    
    should "update the caches of all Time Entries" do
      assert_equal 0, ActiveRecord::Base.connection.select_all('select count(*) as count from time_entries where cost IS NULL').first["count"].to_i

      Rate.update_all_time_entries_to_refresh_cache

      assert_equal 0, ActiveRecord::Base.connection.select_all('select count(*) as count from time_entries where cost IS NULL').first["count"].to_i

    end
    
    should "timestamp a successful run" do
      assert_equal nil, Setting.plugin_redmine_rate['last_cache_clearing_run']

      Rate.update_all_time_entries_to_refresh_cache

      assert Setting.plugin_redmine_rate['last_cache_clearing_run'], "Last run not timestamped"
      assert Time.parse(Setting.plugin_redmine_rate['last_cache_clearing_run']), "Last run timestamp not parseable"
    end
  end
end
