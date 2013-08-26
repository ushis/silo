#
#
#
class ProjectInfo < ActiveRecord::Base
  attr_accessible :title, :language, :region, :client, :funders, :focus

  discrete_values :language, %w(de en es fr), i18n_scope: :languages

  is_commentable_with :description,     autosave: true, dependent: :destroy, as: :describable
  is_commentable_with :service_details, autosave: true, dependent: :destroy, as: :commentable, class_name: :Comment

  validates :title, presence: true

  belongs_to :user
  belongs_to :language
  belongs_to :project, inverse_of: :infos

  accepts_nested_attributes_for :project

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
