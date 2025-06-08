class KioskConfig < ApplicationRecord
  validates :zipcode, presence: true, format: { with: /\A\d{5}\z/, message: "must be 5 digits" }
  validates :refresh_interval, presence: true, numericality: { greater_than: 0 }
    
  def self.first_or_create(attributes = {})
    first || create(attributes)
  end
end
