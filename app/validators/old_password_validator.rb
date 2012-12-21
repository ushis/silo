# Checks the users old password if it has changed.
class OldPasswordValidator < ActiveModel::Validator

  # Performs the validation.
  def validate(record)
    if record.password_digest_changed? &&
      BCrypt::Password.new(record.password_digest_was) != record.password_old
      record.errors.add(:password_old, I18n.t('messages.user.errors.password'))
    end
  end
end
