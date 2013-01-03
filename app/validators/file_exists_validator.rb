# Validates the existence of a file.
class FileExistsValidator < ActiveModel::Validator

  # Expects +record.absolute_path+ to return a Pathname object.
  def validate(record)
    unless record.absolute_path.file?
      record.errors.add(:filename, I18n.t('messages.generics.errors.file_not_found'))
    end
  end
end
