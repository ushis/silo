# The Lang model is just a polymorphic join model for the Language model.
#
# Use it like this:
#
#   class Bernd < ActiveRecord::Migration
#     has_many :langs,     as: langable
#     has_many :languages, through: :langs
#   end
class Lang < ActiveRecord::Base
  belongs_to :language
  belongs_to :langable, polymorphic: true
end
