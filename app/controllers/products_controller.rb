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
    end

    def index
        # reset_session
        @products = Product.all
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
        # binding.pry
        if session[:cart][@product.id.to_s] == nil 
            session[:cart][@product.id.to_s] = 1
            # binding.pry
        else
            session[:cart][@product.id.to_s] += 1
        end
        # (session[:cart] ||= []) << @product.id
        flash[:success] = "Successfully added to your cart."
        redirect_to product_path(@product)
    end

    def cart
        # binding.pry
        if session[:cart] == nil
            session[:cart] = {}
        end
        @items = Product.find(session[:cart].keys)
        @quantity = 0
        @subtotal = 0
        # binding.pry
    end

    def card
        # @product = Product.find(session[:cart])
    end

    def purchase        
        @product = Product.find(params[:id])       
        token = params[:stripeToken]

        # Create the charge on Stripe's servers - this will charge the user's card
        begin
          charge = Stripe::Charge.create(
            :amount => (@product.price * 100).to_i, # amount in cents, TODO: convert the price to cents
            :currency => "usd",
            :source => token,
            :description => @product.name
          )
        rescue Stripe::CardError => e
          flash[:danger] = "Checkout Error"
          redirect_to products_path
        end
        flash[:success] = "Purchased"
        redirect_to root_url
    end

    private
        def permit_products
            params.require(:product).permit(:name,:price,:description,:type,:quantity,:discount,:image)
        end 
end
