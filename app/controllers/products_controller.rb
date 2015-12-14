class ProductsController < ApplicationController
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

    private
        def permit_products
            params.require(:product).permit(:name,:price,:description,:type,:quantity,:discount)
        end 
end
