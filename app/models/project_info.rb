#
#
#
class ProjectInfo < ActiveRecord::Base
  attr_accessible :title, :language, :region, :client, :address, :funders, :focus

  discrete_values :language, %w(de en es fr), i18n_scope: :languages

  is_commentable_with :description,     autosave: true, dependent: :destroy, as: :describable
  is_commentable_with :service_details, autosave: true, dependent: :destroy, as: :commentable, class_name: :Comment

  validates :title, presence: true
  validate :language_cannot_be_changed

  belongs_to :project, autosave: true, inverse_of: :infos

  default_scope order(:language).order(:title)

  self.per_page = 50

  #
  def self.languages
    language_values.map(&:last)
  end

  #
  def language_cannot_be_changed
    if ! language_was.nil? && language_changed?
      errors.add(:language, I18n.t('messages.project_info.errors.language_changed'))
    end
  end

  #
  def to_s
    title.to_s
  end
end
