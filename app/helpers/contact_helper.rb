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

  # Returns a delete contact link.
  #
  #   delete_contact_link('x', contact_url(contact), :emails, 'alf@aol.com')
  def contact_delete_link(txt, url, field, contact, html_options = {})
    options = {
      method: :delete,
      'data-field' => field,
      'data-contact' => contact
    }

    link_to txt, url, options.merge(html_options)
  end
end
