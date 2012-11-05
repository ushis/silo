# The Business model provides the possibility to add several industry sectors
# to the partner companies. It is like tagging the partners. See the ActsAsTag
# module for further description.
#
# Database schema:
#
# - *id:*        integer
# - *business:*  string
#
# The business attribute is unique.
class Business < ActiveRecord::Base
  acts_as_tag :business

  has_and_belongs_to_many :partners, uniq: true
end
