def compare_values(pre, post, message)
  puts "ERROR: #{message} (pre: #{pre}, post: #{post})" unless pre == post
  return pre == post
end

namespace :rate_plugin do
  namespace :budget do
    desc "Export the values of the Budget plugin to a file"
    task :pre => :environment do
      # TODO: make sure the user is on v 0.1.0 of Budget
      rates = ''
      # Rate for members
      Member.find(:all, :conditions => ['rate IS NOT NULL']).each do |member|
        
        rates << {
          :user_id => member.user_id,
          :project_id => member.project_id,
          :rate => member.rate
        }.to_yaml

      end

      File.open("#{RAILS_ROOT}/tmp/budget_member_rate_data.yml", 'w') do |file|
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

      File.open("#{RAILS_ROOT}/tmp/budget_deliverable_data.yml", 'w') do |file|
        file.puts deliverables
      end
    end
    
    desc "Check the values of the export"
    task :post => :environment do
      # TODO: make sure the user is on v 0.2.0 of Budget
      # TODO: make sure the rate migrations are done

      counter = 0
      # Member Rates
      File.open("#{RAILS_ROOT}/tmp/budget_member_rate_data.yml") do |file|
        YAML::load_documents(file) { |member_export|
          user_id = member_export[:user_id]
          project_id = member_export[:project_id]
          rate = Rate.find_by_user_id_and_project_id(user_id, project_id)

          if rate.nil?
            puts "ERROR: No Rate found for User: #{user_id}, Project: #{project_id}"
            counter += 1
          else
            counter += 1 unless compare_values(member_export[:rate], rate.amount, "Rate #{rate.id}'s amount is off")
          end
        }
      end

      # Deliverables
      File.open("#{RAILS_ROOT}/tmp/budget_deliverable_data.yml") do |file|
        YAML::load_documents(file) { |deliverable_export|
          id = deliverable_export[:id]
          spent = deliverable_export[:spent]
          deliverable = Deliverable.find(id)
          
          counter += 1 unless compare_values(spent, deliverable.spent, "Deliverable #{id}'s spent is off")
        }
      end

      if counter > 0
        puts "#{counter} errors found." 
      else
        puts "No conversation errors found, congrats."
      end
    end
  end
end
