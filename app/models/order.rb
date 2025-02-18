class Order < ApplicationRecord
  # Relations
  belongs_to :user, optional: true
  has_many :order_items, dependent: :destroy
  accepts_nested_attributes_for :order_items

  # Validations
  validates :status, inclusion: { in: %w[created pending paid], message: "%{value} is not a valid status" }

  def total_units
    self.order_items.sum(&:quantity)
  end
end
