class RateConversion
  MemberRateDataFile = "#{RAILS_ROOT}/tmp/budget_member_rate_data.yml"
  DeliverableDataFile = "#{RAILS_ROOT}/tmp/budget_deliverable_data.yml"
  
  def self.compare_values(pre, post, message)
    puts "ERROR: #{message} (pre: #{pre}, post: #{post})" unless pre == post
    return pre == post
  end
end
