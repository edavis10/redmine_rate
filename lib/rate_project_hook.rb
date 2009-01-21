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
  
  # Renders an AJAX from to update the member's billing rate
  #
  # Context:
  # * :project => Current project
  # * :member => Current Member record
  #
  def view_projects_settings_members_table_row(context = { })
    member = context[:member]
    project = context[:project]
    rate = Rate.for(member.user, project)

    url = {
      :controller => 'rates',
      :action => 'create',
      :method => :post,
      :protocol => Setting.protocol,
      :host => Setting.host_name
    }
    # Build a form_remote_tag by hand since this isn't in the scope of a controller
    # and url_rewriter doesn't like that fact.
    form = form_tag(url, :onsubmit => remote_function(:url => url,
                                                      :host => Setting.host_name,
                                                      :protocol => Setting.protocol,
                                                      :form => true,
                                                      :method => 'post',
                                                      :return => 'false' )+ '; return false;')
    
    form << text_field(:rate, :amount)
    form << hidden_field(:rate,:date_in_effect, :value => Date.today.to_s)
    form << hidden_field(:rate, :project_id, :value => project.id)
    form << hidden_field(:rate, :user_id, :value => member.user.id) 
    form << hidden_field_tag("back_url", url_for(:controller => 'projects', :action => 'settings', :id => project, :tab => 'members', :protocol => Setting.protocol, :host => Setting.host_name))

    form << submit_tag(l(:rate_label_set_rate), :class => "small")
    
    return content_tag(:td, form, :align => 'left', :id => "rate_#{project.id}_#{member.user.id}" )
  end
end

