#
#
#
class ProjectInfo < ActiveRecord::Base
  attr_accessible :title, :region, :client, :funders, :focus

  validates :title, presence: true

  belongs_to :user
  belongs_to :project
  belongs_to :language

  #
  def to_s
    title.to_s
  end
end
