#
#
#
class ProjectMember < ActiveRecord::Base
  attr_accessible :role

  belongs_to :project
  belongs_to :expert

  validates :role, presence: true

  #
  def name
    expert.try(:to_s)
  end

  #
  def to_s
    "#{name} (#{role})"
  end
end
