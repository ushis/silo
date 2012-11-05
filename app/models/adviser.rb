# The Adviser model provides the possibility to add internal advisers to the
# partner companies. It is like tagging the partners. See the ActsAsTag
# module for further description.
#
# Database schema:
#
# - *id:*       integer
# - *adviser:*  string
#
# The adviser attribute is unique.
class Adviser < ActiveRecord::Base
  acts_as_tag :adviser

  has_and_belongs_to_many :partners, uniq: true
end
