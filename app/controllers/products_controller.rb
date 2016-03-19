class ProductsController < ApplicationController
    before_filter :authenticate_user!, only: [:new, :create, :edit, :update] 

    def new
        @product = Product.new
    end

    def create
        @product = Product.new(permit_products)
        if @product.save
            flash[:success] = 'New product was created'
            redirect_to product_path(@product)
        else
            flash[:danger] = @product.errors.full_messages.first
            redirect_to root_url
        end
    end

    def show        
        @product = Product.find(params[:id])
        @related = Product.where(type: @product.type)
        @related_id = []
        @related.each do |x|
            @related_id.push(x.id)
        end
        @related_id.delete(@product.id)
        @related_id = @related_id.shuffle.slice(0,4)

    end

    def index   
        
        if params[:type] == nil
            @products = Product.paginate(:page => params[:page], :per_page => 8)   
        else
            @products = Product.where(type: params[:type]).paginate(:page => params[:page], :per_page => 8)
        end             

    end

    def edit
        @product = Product.find(params[:id])        
    end

    def update
        @product = Product.find(params[:id])
        if @product.update_attributes(permit_products)
            flash[:success] = "Product updated"
            redirect_to product_path(@product)
        else
            flash[:danger]  = "Error" 
            redirect_to root_url
        end
    end

    def addtocart        
        @product = Product.find(params[:id])
        if session[:cart] == nil
            session[:cart] = {}
        end

        if session[:cart][@product.id.to_s] == nil 
            session[:cart][@product.id.to_s] = 1

        else
            session[:cart][@product.id.to_s] += 1
        end

        flash[:success] = "Successfully added to your cart."
        redirect_to product_path(@product)
    end

    def cart       
        if session[:cart] == nil
            session[:cart] = {}
        end
        @items = Product.find(session[:cart].keys)
        @quantity = 0
        @total_price = total_price
    end

    def card
        @items = Product.find(session[:cart].keys)
        @quantity = 0
        @total_price = total_price
    end

    def purchase        
        @total_price = total_price 
        token = params[:stripeToken]

        # Create the charge on Stripe's servers - this will charge the user's card
        begin
          charge = Stripe::Charge.create(
            :amount => (@total_price * 100).to_i, # amount in cents, TODO: convert the price to cents
            :currency => "usd",
            :source => token,
            :description => "total"
          )
        rescue Stripe::CardError => e
          flash[:danger] = "Checkout Error"
          redirect_to root_url
        end
        flash[:success] = "Purchased"        
        redirect_to receipt_path
    end

    def receipt
        @items = Product.find(session[:cart].keys)
        @quantity = 0
        @total_price = total_price        
    end

    def reset
        session[:cart] = {}
        redirect_to cart_path
    end

    private

        def permit_products
            params.require(:product).permit(:name,:price,:description,:type,:quantity,:discount,:image)
        end 

        def total_price
            @total = 0
            @items = Product.find(session[:cart].keys)
            @items.each do |x|
                @sub = (x.price * x.discount).round(2) * session[:cart][x.id.to_s]
                @total += @sub
            end
            return @total
        end
end
