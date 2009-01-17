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

  it 'should save if a Rate is unlocked' do
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

  it 'should destroy the Rate if it is unlocked' do
    rate = Rate.create(rate_valid_attributes)
    rate.stub!(:locked?).and_return(false)
    proc {
      rate.destroy
    }.should change(Rate, :count).by(-1)

  end

  it 'should not destroy the Rate if it is locked' do
    rate = Rate.create(rate_valid_attributes)
    rate.stub!(:locked?).and_return(true)
    proc {
      rate.destroy
    }.should_not change(Rate, :count)
  end
end

describe Rate, 'for' do
  before(:each) do
    @user = mock_model(User)
    @project = mock_model(Project)
    @date = '2009-01-01'
  end
    
  describe 'parameters' do
    it 'should be passed user' do
      lambda {Rate.for}.should raise_error(ArgumentError)
    end

    it 'can be passed an optional project' do
      lambda {Rate.for(@user)}.should_not raise_error(ArgumentError)
      lambda {Rate.for(@user, @project)}.should_not raise_error(ArgumentError)
    end
  
    it 'can be passed an optional date string' do
      lambda {Rate.for(@user)}.should_not raise_error(ArgumentError)
      lambda {Rate.for(@user, nil, @date)}.should_not raise_error(ArgumentError)
    end
    
  end

  describe 'returns' do
    it 'a decimal when there is a rate'

    it 'a nil when there is no rate' do
      Rate.for(@user, @project, @date).should be_nil
    end
  end
  
  describe 'with a user, project, and date' do
    it 'should find all the rates for a user on the project before the date' do
      rate1 = mock_model(Rate, :amount => 50.50)
      
      Rate.should_receive(:find).with(:first, {
                                        :conditions => ["user_id IN (?) AND project_id IN (?) AND date_in_effect <= ?",
                                                        @user.id,
                                                        @project.id,
                                                        @date
                                                       ],
                                        :order => 'date_in_effect DESC'
                                      }).and_return(rate1)
      Rate.for(@user, @project, @date)
      
    end

    it 'should return the value of the most recent rate found' do
      rate1 = mock_model(Rate, :amount => 50.50)
      
      Rate.should_receive(:find).with(:first, {
                                        :conditions => ["user_id IN (?) AND project_id IN (?) AND date_in_effect <= ?",
                                                        @user.id,
                                                        @project.id,
                                                        @date
                                                       ],
                                        :order => 'date_in_effect DESC'
                                      }).and_return(rate1)
      Rate.for(@user, @project, @date).should eql(rate1.amount)
      
    end
  end

  describe 'with a user and project' do
    it 'should find all the rates for a user on the project before today' do
      rate1 = mock_model(Rate, :amount => 50.50)
      
      Rate.should_receive(:find).with(:first, {
                                        :conditions => ["user_id IN (?) AND project_id IN (?) AND date_in_effect <= ?",
                                                        @user.id,
                                                        @project.id,
                                                        Date.today.to_s
                                                       ],
                                        :order => 'date_in_effect DESC'
                                      }).and_return(rate1)
      Rate.for(@user, @project)
      
    end

    it 'should return the value of the most recent rate found' do
      rate1 = mock_model(Rate, :amount => 50.50)
      
      Rate.should_receive(:find).with(:first, {
                                        :conditions => ["user_id IN (?) AND project_id IN (?) AND date_in_effect <= ?",
                                                        @user.id,
                                                        @project.id,
                                                        Date.today.to_s
                                                       ],
                                        :order => 'date_in_effect DESC'
                                      }).and_return(rate1)
      Rate.for(@user, @project).should eql(rate1.amount)
      
    end
  end
end

describe Rate, 'for_user_project_and_date (private)' do
  before(:each) do
    @user = mock_model(User)
    @project = mock_model(Project)
    @date = '2009-01-01'
    @rate = mock_model(Rate, :amount => 50.50)
  end

  it 'should find all the rates for a user on the project before the date' do
    Rate.should_receive(:find).with(:first, {
                                      :conditions => ["user_id IN (?) AND project_id IN (?) AND date_in_effect <= ?",
                                                      @user.id,
                                                      @project.id,
                                                      @date
                                                     ],
                                      :order => 'date_in_effect DESC'
                                    }).and_return(@rate)

    Rate.send(:for_user_project_and_date, @user, @project, @date)
  end

  it 'should return the value of the most recent rate found' do
    Rate.should_receive(:find).with(:first, {
                                      :conditions => ["user_id IN (?) AND project_id IN (?) AND date_in_effect <= ?",
                                                      @user.id,
                                                      @project.id,
                                                      @date
                                                     ],
                                      :order => 'date_in_effect DESC'
                                    }).and_return(@rate1)
    Rate.send(:for_user_project_and_date, @user, @project, @date).should eql(@rate1)
  end
end
