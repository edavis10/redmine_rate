namespace :rate_plugin do
  desc "Export both the Budget and Billing plugin data to a file"
  task :pre_install_export => ['budget:pre_install_export', 'billing:pre_install_export']

  desc "Check the export against the migrated Rate data"
  task :post_install_check => ['budget:post_install_check', 'billing:post_install_check']

  namespace :budget do
    desc "Export the values of the Budget plugin to a file before installing the rate plugin"
    task :pre_install_export => :environment do
      
      unless Redmine::Plugin.registered_plugins[:budget_plugin].version == "0.1.0"
        puts "ERROR: This task is only needed when upgrading Budget from version 0.1.0 to version 0.2.0"
        return false
      end
      
      rates = ''
      # Rate for members
      Member.find(:all, :conditions => ['rate IS NOT NULL']).each do |member|
        
        rates << {
          :user_id => member.user_id,
          :project_id => member.project_id,
          :rate => member.rate
        }.to_yaml

      end

      File.open(RateConversion::MemberRateDataFile, 'w') do |file|
        file.puts rates
      end
      
      # HourlyDeliverable.spent and FixedDeliverable.spent
      deliverables = ''
      Deliverable.find(:all).each do |deliverable|
        deliverables << { 
          :id => deliverable.id,
          :spent => deliverable.spent
        }.to_yaml
      end

      File.open(RateConversion::DeliverableDataFile, 'w') do |file|
        file.puts deliverables
      end
    end
    
    desc "Check the values of the export"
    task :post_install_check => :environment do

      unless Redmine::Plugin.registered_plugins[:budget_plugin].version == "0.2.0"
        puts "ERROR: Please upgrade the budget_plugin to 0.2.0 now"
        return false
      end
      
      counter = 0
      # Member Rates
      File.open(RateConversion::MemberRateDataFile) do |file|
        YAML::load_documents(file) { |member_export|
          user_id = member_export[:user_id]
          project_id = member_export[:project_id]
          rate = Rate.find_by_user_id_and_project_id(user_id, project_id)

          if rate.nil?
            puts "ERROR: No Rate found for User: #{user_id}, Project: #{project_id}"
            counter += 1
          else
            counter += 1 unless RateConversion.compare_values(member_export[:rate], rate.amount, "Rate #{rate.id}'s amount is off")
          end
        }
      end

      # Deliverables
      File.open(RateConversion::DeliverableDataFile) do |file|
        YAML::load_documents(file) { |deliverable_export|
          id = deliverable_export[:id]
          spent = deliverable_export[:spent]
          deliverable = Deliverable.find(id)
          
          counter += 1 unless RateConversion.compare_values(spent, deliverable.spent, "Deliverable #{id}'s spent is off")
        }
      end

      if counter > 0
        puts "#{counter} errors found." 
      else
        puts "No Budget conversation errors found, congrats."
      end
    end
  end

  namespace :billing do
    desc "Export the values of the Billing plugin to a file before installing the rate plugin"
    task :pre_install_export => :environment do
      
      unless Redmine::Plugin.registered_plugins[:redmine_billing].version == "0.0.1"
        puts "ERROR: This task is only needed when upgrading Billing from version 0.0.1 to version 0.3.0"
        return false
      end
      
      invoices = ''
      
      FixedVendorInvoice.find(:all).each do |invoice|
        invoices << { 
          :id => invoice.id,
          :number => invoice.number,
          :amount => invoice.amount,
          :project_id => invoice.project_id,
          :type => 'FixedVendorInvoice'
        }.to_yaml
      end

      HourlyVendorInvoice.find(:all).each do |invoice|
        invoices << { 
          :id => invoice.id,
          :number => invoice.number,
          :amount => invoice.amount_for_user,
          :project_id => invoice.project_id,
          :type => 'HourlyVendorInvoice'
        }.to_yaml
      end

      File.open(RateConversion::VendorInvoiceDataFile, 'w') do |file|
        file.puts invoices
      end
    end
    
    desc "Check the values of the export"
    task :post_install_check => :environment do

      unless Redmine::Plugin.registered_plugins[:redmine_billing].version == "0.3.0"
        puts "ERROR: Please upgrade the billing_plugin to 0.3.0 now"
        return false
      end
      
      counter = 0

      File.open(RateConversion::VendorInvoiceDataFile) do |file|
        YAML::load_documents(file) { |invoice_export|
          invoice = VendorInvoice.find_by_id(invoice_export[:id])

          if invoice.nil?
            puts "ERROR: No VendorInvoice found with the ID of #{invoice_export[:id]}"
            counter += 1
          else
            if invoice.type.to_s == "FixedVendorInvoice"
              counter += 1 unless RateConversion.compare_values(invoice_export[:amount], invoice.amount, "VendorInvoice #{invoice.id}'s amount is off")
            else
              counter += 1 unless RateConversion.compare_values(invoice_export[:amount], invoice.amount_for_user, "VendorInvoice #{invoice.id}'s amount is off")
            end
            
          end
        }
      end

      if counter > 0
        puts "#{counter} errors found." 
      else
        puts "No Billing conversation errors found, congrats."
      end
    end
  end

end
