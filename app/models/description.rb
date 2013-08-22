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
#
# See ActsAsComment for more info.
class Description < ActiveRecord::Base
  acts_as_comment :description, for: :describable, polymorphic: true
end
