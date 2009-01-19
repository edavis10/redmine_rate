class RatesController < ApplicationController
  # GET /rates
  # GET /rates.xml
  def index
    @rates = Rate.find(:all)

    respond_to do |format|
      format.html # index.html.erb
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

  # GET /rates/new
  # GET /rates/new.xml
  def new
    @rate = Rate.new

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
        format.html { redirect_to(@rate) }
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
      if @rate.update_attributes(params[:rate])
        flash[:notice] = 'Rate was successfully updated.'
        format.html { redirect_to(@rate) }
        format.xml  { head :ok }
      else
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
end
