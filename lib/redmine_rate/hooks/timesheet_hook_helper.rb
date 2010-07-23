module TimesheetHookHelper
  # Returns the cost of a time entry, checking user permissions
  def cost_item(time_entry)
    if User.current.logged? && (User.current.allowed_to?(:view_rate, time_entry.project) || User.current.admin?)
      return time_entry.cost
    else
      return nil
    end
  end

  def td_cell(html)
    return content_tag(:td, html, :align => 'right', :class => 'cost')
  end
end
