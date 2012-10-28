# Contains contact specific helper methods.
module ContactHelper

  # Returns the contact value. If field is :emails or :websites, the value
  # is wrapped with <a> tag.
  def contact_value(val, field, html_options = {})
    case field
    when :emails
      mail_to val
    when :websites
      link_to val, (URI.parse(val).scheme.blank? ? "http://#{val}" : val)
    else
      val
    end
  rescue
    val
  end

  # Returns a "delete contact" link.
  #
  #   delete_contact_button(expert, :emails, 'alf@aol.com')
  #
  # The parent argument must be a parent model of the contact.
  def delete_contact_button(parent, field, contact, options = {})
    options = {
      url: [parent, parent.contact],
      'data-field' => field,
      'data-contact' => contact
    }.merge(options)

    delete_button_for(parent.contact, options)
  end
end
