require_dependency 'sort_helper'

module RateSortHelperPatch
  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)
  end
  
  module InstanceMethods
    # Allows more parameters than the standard sort_header_tag
    def rate_sort_header_tag(column, options = {})
      caption = options.delete(:caption) || titleize(Inflector::humanize(column))
      default_order = options.delete(:default_order) || 'asc'
      options[:title]= l(:label_sort_by, "\"#{caption}\"") unless options[:title]
      content_tag('th',
                  rate_sort_link(column,
                                 caption,
                                 default_order,
                                 { :method => options[:method], :update => options[:update], :user_id => options[:user_id] }),
                  options)
    end

    # Allows more parameters than the standard sort_link and is hard coded to use
    # the RatesController
    def rate_sort_link(column, caption, default_order, options = { })
      key, order = session[@sort_name][:key], session[@sort_name][:order]
      if key == column
        if order.downcase == 'asc'
          icon = 'sort_asc.png'
          order = 'desc'
        else
          icon = 'sort_desc.png'
          order = 'asc'
        end
      else
        icon = nil
        order = default_order
      end
      caption = titleize(Inflector::humanize(column)) unless caption
      
      sort_options = { :sort_key => column, :sort_order => order}
      # don't reuse params if filters are present
      url_options = params.has_key?(:set_filter) ? sort_options : params.merge(sort_options)

      # Hard code url to the Rates index
      url_options[:controller] = 'rates'
      url_options[:action] = 'index'
      url_options[:user_id] ||= options[:user_id]
      
      link_to_remote(caption,
                     {
                       :update => options[:update] || "content",
                       :url => url_options,
                       :method => options[:method] || :post
                     },
                     {:href => url_for(url_options)}) +
        (icon ? nbsp(2) + image_tag(icon) : '')
    end
    
  end
end

SortHelper.send(:include, RateSortHelperPatch)

