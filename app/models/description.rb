# The Description model provides the ability to equip the Partner model
# with searchable description.
#
# Database scheme:
#
# - *id:*           integer
# - *partner_id:*   integer
# - *description:*  text
# - *created_at:*   datetime
# - *updated_at:*   datetime
#
# There is a MySQL fulltext index on the description column.
class Description < ActiveRecord::Base
  attr_accessible :description

  after_initialize :init_description

  belongs_to :partner

  # Initializes the desciption with an empty string.
  def init_description
    self.description ||= ''
  end

  # Returns the description.
  def to_s
    description
  end
end
