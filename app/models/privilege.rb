# The Privilege model is used to hold User permissions.
#
# Database Scheme:
#
# - *user_id* integer
# - *amdin* boolean
# - *experts* boolean
# - *partners* boolean
# - *references* boolean
#
# This is not very fancy.
class Privilege < ActiveRecord::Base
  belongs_to :user

  # A list of all sections.
  SECTIONS = [:experts, :partners, :references]

  # Returns the privileges hash.
  #
  #   privilege.privileges
  #   #=> { experts: true, partners: false, references: true }
  #
  # If the admin attribute is _true_, the hash contains the single key
  # _admin_ with the value _true_.
  def privileges
    if admin
      { admin: true }
    else
      Hash[SECTIONS.collect { |s| [s, send(s)] }]
    end
  end
end
