class RateConversion
  RoundTo = 10
  
  MemberRateDataFile = "#{RAILS_ROOT}/tmp/budget_member_rate_data.yml"
  DeliverableDataFile = "#{RAILS_ROOT}/tmp/budget_deliverable_data.yml"
  VendorInvoiceDataFile = "#{RAILS_ROOT}/tmp/billing_vendor_invoice_data.yml"

  
  def self.compare_values(pre, post, message)
    pre = pre.to_f.round(RoundTo)
    post = post.to_f.round(RoundTo)
    
    puts "ERROR: #{message} (pre: #{pre}, post: #{post})" unless pre == post
    return pre == post
  end
end
