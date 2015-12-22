class Product < ActiveRecord::Base
    self.inheritance_column = :_type_disabled

    has_attached_file :image, styles: { medium: "500x500>", thumb: "100x100>" }, default_url: "/images/:style/missing.png"
    validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/
    
    validates :name, :type, presence: true    
    validates :price, :discount, presence: true, numericality: { greater_than: 0 }    
    validates :quantity, presence: true, numericality: { greater_than: 0 }
    validates :description, presence: true, length: { minimum: 10 }     
    
end
