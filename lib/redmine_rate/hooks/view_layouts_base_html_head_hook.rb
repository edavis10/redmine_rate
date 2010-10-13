module RedmineRate
  module Hooks
    class ViewLayoutsBaseHtmlHeadHook < Redmine::Hook::ViewListener
      def view_layouts_base_html_head(context={})
        return content_tag(:style, "#admin-menu a.rate-caches { background-image: url('#{image_path('database_refresh.png', :plugin => 'redmine_rate')}'); }", :type => 'text/css')
      end
    end
  end
end
