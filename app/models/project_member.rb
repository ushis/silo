# Joins experts with projects.
#
# Database schema:
#
# - *id:*          integer
# - *expert_id:*   integer
# - *project_id:*  integer
# - *role:*        string
#
# The fields *expert_id*, *project_id* and *role* are required.
class ProjectMember < ActiveRecord::Base
  attr_accessible :expert_id, :role

  belongs_to :expert
  belongs_to :project, inverse_of: :members

  validates :role,      presence: true
  validates :expert_id, uniqueness: {scope: :project_id}

  #
  def self.ordered
    includes(:expert).order(Expert::DEFAULT_ORDER)
  end

  # Returns the experts name.
  def name
    expert.try(:to_s)
  end

  # Returns the experts name and role.
  def to_s
    "#{name} (#{role})"
  end
end
