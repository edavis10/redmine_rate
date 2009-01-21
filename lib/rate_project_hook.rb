# Hooks to attach to the Redmine Projects.
class RateProjectHook < Redmine::Hook::ViewListener

  def protect_against_forgery?
    false
  end
  
  # Renders an additional table header to the membership setting
  #
  # Context:
  # * :project => Current project
  #
  def view_projects_settings_members_table_header(context ={ })
    return "<th>#{l(:rate_label_rate)} #{l(:rate_label_currency)}</td>"
  end
  
end

