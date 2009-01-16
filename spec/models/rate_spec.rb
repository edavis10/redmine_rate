require File.dirname(__FILE__) + '/../spec_helper'

module RateSpecHelper
  def rate_valid_attributes
    { 
      :user => mock_model(User),
      :project => mock_model(Project),
      :date_in_effect => Date.new(Date.today.year, 1, 1),
      :amount => 100.50
    }
  end
end

describe Rate do
  include RateSpecHelper
  
  it 'should be valid with a user' do
    rate = Rate.new(rate_valid_attributes)
    rate.should be_valid
  end

  it 'should be valid with a project' do
    rate = Rate.new(rate_valid_attributes)
    rate.should be_valid
  end
  
  it 'should be valid without a project' do
    rate = Rate.new(rate_valid_attributes.except(:project))
    rate.should be_valid
  end

  it 'should not be valid without a user' do
    rate = Rate.new(rate_valid_attributes.except(:user))
    rate.should_not be_valid
    rate.should have(1).error_on(:user_id)
  end
  
  it 'should not be valid without a date_in_effect' do
    rate = Rate.new(rate_valid_attributes.except(:date_in_effect))
    rate.should_not be_valid
    rate.should have(1).error_on(:date_in_effect)
  end
end

describe Rate, 'associations' do
  it 'should have many time entries' do
    Rate.should have_association(:time_entries, :has_many)
  end

  it 'should belong to a single user' do
    Rate.should have_association(:user, :belongs_to)
  end

  it 'should belong to a single project' do
    Rate.should have_association(:project, :belongs_to)
  end

end

describe Rate, 'locked?' do
  it 'should be true if a Time Entry is associated' do
    rate = Rate.new
    rate.time_entries << mock_model(TimeEntry)
    rate.locked?.should be_true
  end
  
  it 'should be false if no Time Entries are associated' do
    rate = Rate.new
    rate.locked?.should be_false
  end
  
end

describe Rate, 'locked?' do
  it 'should be false if a Time Entry is associated' do
    rate = Rate.new
    rate.time_entries << mock_model(TimeEntry)
    rate.unlocked?.should be_false
  end
  
  it 'should be true if no Time Entries are associated' do
    rate = Rate.new
    rate.unlocked?.should be_true
  end
  
end

describe Rate, 'save' do
  include RateSpecHelper

  it 'should save normally if a Rate is not locked' do
    rate = Rate.new(rate_valid_attributes)
    rate.stub!(:locked?).and_return(false)
    rate.save.should eql(true)
  end

  it 'should not save if a Rate is locked' do
    rate = Rate.new(rate_valid_attributes)
    rate.stub!(:locked?).and_return(true)
    rate.save.should eql(false)
  end
end

describe Rate, 'destroy' do
  include RateSpecHelper

  it 'should destroy the Rate if it is not locked' do
    rate = Rate.create(rate_valid_attributes)
    rate.stub!(:locked?).and_return(false)
    proc {
      rate.destroy
    }.should change(Rate, :count).by(-1)

  end

  it 'should not delete the Rate if it is locked' do
    rate = Rate.create(rate_valid_attributes)
    rate.stub!(:locked?).and_return(true)
    proc {
      rate.destroy
    }.should_not change(Rate, :count)
  end
end
