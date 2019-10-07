class StoresController < ApplicationController

  def index
    @stores = Store.all()
    render :index
  end

  def new
    @store = Store.new
    render :new
  end

  def create
    @store = Store.create(store_params)
    if @store.save
      redirect_to stores_path
    else
      render :new
    end
  end

  def edit
    @store = Store.find(params[:id])
    render :edit
  end

  def show
    @store = Store.find(params[:id])
    @todays_sales = ActiveRecord::Base.connection.execute("SELECT SUM(price) FROM products JOIN orders ON (orders.product_id = products.id) WHERE store_id =(#{@store.id});").values[0][0]
    @todays_labor = ActiveRecord::Base.connection.execute("SELECT SUM(wage*hours) FROM employees JOIN timecards ON(timecards.employee_id = employees.id) WHERE employees.store_id =(#{@store.id});").values[0][0]
    @todays_cogs = ActiveRecord::Base.connection.execute("SELECT SUM(cost) FROM products JOIN orders ON (orders.product_id = products.id) WHERE store_id =(#{@store.id});").values[0][0]
    @todays_grossmargin = ActiveRecord::Base.connection.execute("SELECT (SELECT SUM(price) FROM products JOIN orders ON (orders.product_id = products.id)) -( (SELECT SUM(wage*hours) FROM employees JOIN timecards ON(timecards.employee_id = employees.id)) + (SELECT SUM(cost) FROM products JOIN orders ON (orders.product_id = products.id) ))").values[0][0]
    render :show
  end

  def update
    @store = Store.find(params[:id])
    if @store.update(store_params)
      redirect_to stores_path
    else
      render :edit
    end
  end

  def destroy
    @store = Store.find(params[:id])
    @store.destroy
    redirect_to stores_path
  end

  def import
    Store.import(params[:file])
    redirect_to'/'
  end


  private
  def store_params
    params.require(:store).permit(:name, :id)
  end
end
