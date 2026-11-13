class AuditEvent < ApplicationRecord
  belongs_to :user
  belongs_to :plant
  validates :action, :occurred_at, presence: true
  before_update { throw :abort }
  before_destroy { throw :abort }
end
