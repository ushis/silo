# The Lang model is just a polymorphic join model for the Language model.
#
# Use it like this:
#
#   class Bernd < ActiveRecord::Migration
#     has_many :langs,     as: langable
#     has_many :languages, through: :langs
#   end
#
# Database Scheme:
#
# - *id* integer
# - *language_id* integer
# - *langable_id* integer
# - *langable_type* string
class Lang < ActiveRecord::Base
  belongs_to :language
  belongs_to :langable, polymorphic: true
end
