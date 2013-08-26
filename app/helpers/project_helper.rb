# Provides project specific helpers.
module ProjectHelper

  # Returns a string containing links to the CV downloads.
  def list_infos(project, html_options = {})
    project.infos.inject('') do |html, info|
      html << link_to(info.language, project_path(info), html_options)
    end.html_safe
  end
end
