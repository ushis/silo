# Provides project specific helpers.
module ProjectHelper

  # Returns a string containing links to the CV downloads.
  def list_infos(project, html_options = {})
    project.infos.inject('') do |html, info|
      html << link_to(info.language, project_path(project, info.language), html_options)
    end.html_safe
  end

  # Returns a select tag with all available languages of the project.
  def project_info_selector(info, html_options = {})
    html_options = html_options.merge({
      'data-selector' => project_path(info.project, ':lang')
    })
    options = options_from_collection_for_select(info.project.infos, :language, :human_language, info.language)
    select_tag(:lang, options, html_options)
  end

  # Returns a select tag with project languages.
  def project_form_selector(info, html_options = {})
    path = info.project.try(:id) ? edit_project_path(info.project, ':lang') : new_project_path(':lang')
    html_options = html_options.merge({'data-selector' => path})
    options = options_for_select(ProjectInfo.language_values, info.language)
    select_tag(:lang, options, html_options)
  end

  #
  def project_form_action_path(project, info)
    if project.persisted?
      project_path(project, info.language)
    else
      projects_path
    end
  end
end
