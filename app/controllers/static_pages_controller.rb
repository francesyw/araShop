class StaticPagesController < ApplicationController
  def home
      @products = Product.last(4)
  end
end
