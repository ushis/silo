#
#
#
class ProjectInfo < ActiveRecord::Base
  attr_accessible :title, :language, :region, :client, :funders, :focus

  discrete_values :language, %w(de en es fr), i18n_scope: :languages

  validates :title, presence: true

  belongs_to :user
  belongs_to :language
  belongs_to :project, inverse_of: :infos

  default_scope order(:language).order(:title)

  self.per_page = 50

  #
  def self.languages
    language_values.map(&:last)
  end

  #
  def to_s
    title.to_s
  end
end
