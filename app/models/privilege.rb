#
# *Scheme*
#
# - *user_id* integer
# - *amdin* boolean
# - *experts* boolean
# - *partners* boolean
# - *references* boolean
#
class Privilege < ActiveRecord::Base
  belongs_to :user

  # A list of all sections.
  SECTIONS = [:experts, :partners, :references]

  # Returns a list of all sections.
  #
  #   Privilege.sections
  #   #=> [:experts, :partners, :references]
  def self.sections
    SECTIONS
  end

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
      SECTIONS.inject({}) { |p, section| p[section] = send(section); p }
    end
  end
end
