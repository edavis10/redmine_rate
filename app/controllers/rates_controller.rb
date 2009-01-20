class RatesController < ApplicationController
  helper :users
  helper :sort
  include SortHelper

  before_filter :require_admin
  before_filter :require_user_id, :only => [:index, :new]
  before_filter :set_back_url, :only => [:new, :edit]
  
  ValidSortOptions = {'date_in_effect' => "#{Rate.table_name}.date_in_effect", 'project_id' => "#{Project.table_name}.name"}
  
  # GET /rates?user_id=1
  # GET /rates.xml?user_id=1
  def index
    sort_init "#{Rate.table_name}.date_in_effect", "desc"
    sort_update ValidSortOptions

    @rates = Rate.history_for_user(@user, sort_clause)

    respond_to do |format|
      format.html { render :action => 'index', :layout => !request.xhr?}
      format.xml  { render :xml => @rates }
    end
  end

  # GET /rates/1
  # GET /rates/1.xml
  def show
    @rate = Rate.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @rate }
    end
  end

  # GET /rates/new?user_id=1
  # GET /rates/new.xml?user_id=1
  def new
    @rate = Rate.new(:user_id => @user.id)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @rate }
    end
  end

  # GET /rates/1/edit
  def edit
    @rate = Rate.find(params[:id])
  end

  # POST /rates
  # POST /rates.xml
  def create
    @rate = Rate.new(params[:rate])

    respond_to do |format|
      if @rate.save
        flash[:notice] = 'Rate was successfully created.'
        format.html { 
          if params[:back_url] && !params[:back_url].blank?
            redirect_to(params[:back_url])
          else
            redirect_to(rates_url(:user_id => @rate.user_id))
          end
        }
        format.xml  { render :xml => @rate, :status => :created, :location => @rate }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @rate.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /rates/1
  # PUT /rates/1.xml
  def update
    @rate = Rate.find(params[:id])

    respond_to do |format|
      # Locked rates will fail saving here.
      if @rate.update_attributes(params[:rate])
        flash[:notice] = 'Rate was successfully updated.'
        format.html { 
          if params[:back_url] && !params[:back_url].blank?
            redirect_to(params[:back_url])
          else
            redirect_to(rates_url(:user_id => @rate.user_id))
          end
        }
        format.xml  { head :ok }
      else
        if @rate.locked?
          flash[:error] = "Rate is locked and cannot be edited"
          @rate.reload # Removes attribute changes
        end
        format.html { render :action => "edit" }
        format.xml  { render :xml => @rate.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /rates/1
  # DELETE /rates/1.xml
  def destroy
    @rate = Rate.find(params[:id])
    @rate.destroy

    respond_to do |format|
      format.html { redirect_to(rates_url) }
      format.xml  { head :ok }
    end
  end
  
  private
  
  def require_user_id
    begin
      @user = User.find(params[:user_id])
    rescue ActiveRecord::RecordNotFound
      respond_to do |format|
        flash[:error] = l(:rate_error_user_not_found)
        format.html { redirect_to(home_url) }
        format.xml  { render :xml => "User not found", :status => :not_found }
      end
    end
  end
  
  def set_back_url
    @back_url = params[:back_url]
  end
end
