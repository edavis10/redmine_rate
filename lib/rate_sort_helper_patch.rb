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
    # the RatesController and to have an :method and :update options
    def rate_sort_link(column, caption, default_order, options = { })
      # 0.8.x compatibility
      if SortHelper.const_defined? 'SortCriteria'
        rate_sort_link_trunk_version(column, caption, default_order, options)
      else
        rate_sort_link_08_version(column, caption, default_order, options)
      end
    end

    private
    # Trunk version of sort_link.  Was modified in r2571 of Redmine
    def rate_sort_link_trunk_version(column, caption, default_order, options = { })
      css, order = nil, default_order
    
      if column.to_s == @sort_criteria.first_key
        if @sort_criteria.first_asc?
          css = 'sort asc'
          order = 'desc'
        else
          css = 'sort desc'
          order = 'asc'
        end
      end
      caption = column.to_s.humanize unless caption

      sort_options = { :sort => @sort_criteria.add(column.to_s, order).to_param }
      # don't reuse params if filters are present
      url_options = params.has_key?(:set_filter) ? sort_options : params.merge(sort_options)
    
      # Add project_id to url_options
      url_options = url_options.merge(:project_id => params[:project_id]) if params.has_key?(:project_id)

      ##### Hard code url to the Rates index
      url_options[:controller] = 'rates'
      url_options[:action] = 'index'
      url_options[:user_id] ||= options[:user_id]
      #####

      
      link_to_remote(caption,
                     {:update => options[:update] || "content", :url => url_options, :method => options[:method] || :post},
                     {:href => url_for(url_options),
                       :class => css})
    end

    private
    # 0.8.x branch of sort_link.
    def rate_sort_link_08_version(column, caption, default_order, options = { })
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
      
      sort_options = { :sort_key => column, :sort_order => order }
      # don't reuse params if filters are present
      url_options = params.has_key?(:set_filter) ? sort_options : params.merge(sort_options)
      
      ##### Hard code url to the Rates index
      url_options[:controller] = 'rates'
      url_options[:action] = 'index'
      url_options[:user_id] ||= options[:user_id]
      #####

      link_to_remote(caption,
                     {:update => options[:update] || "content", :url => url_options, :method => options[:method] || :post},
                     {:href => url_for(url_options)}) +
        (icon ? nbsp(2) + image_tag(icon) : '')
    end
    
  end
end

SortHelper.send(:include, RateSortHelperPatch)

