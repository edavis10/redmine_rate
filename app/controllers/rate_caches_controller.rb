class RateCachesController < ApplicationController
  unloadable

  layout 'admin'
  
  before_filter :require_admin

  def index
  end
end
