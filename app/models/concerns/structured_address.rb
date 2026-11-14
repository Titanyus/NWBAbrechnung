module StructuredAddress
  extend ActiveSupport::Concern

  included do
    normalizes :street, :postal_code, :city, with: ->(value) { value.strip }
    validates :street, presence: true, length: { maximum: 500 }
    validates :postal_code, presence: true, length: { maximum: 20 }
    validates :city, presence: true, length: { maximum: 200 }
    validates :street, :postal_code, :city, format: { with: /\A[^\r\n]*\z/, message: "muss einzeilig sein" }
  end

  def address
    [ street, [ postal_code, city ].compact.join(" ") ].compact.join("\n")
  end
end
