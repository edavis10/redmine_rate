require File.dirname(__FILE__) + '/../spec_helper'

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
