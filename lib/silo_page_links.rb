require 'will_paginate/view_helpers/action_view'

module SiloPageLinks
  class Renderer < WillPaginate::ActionView::LinkRenderer
    include ActionView::Context
    include ActionView::Helpers

    def to_html
      content_tag :ul, class: 'pagination' do
        pagination.collect do |page|
          if page.is_a? Fixnum
            page_number(page)
          else
            send(page)
          end
        end.join('').html_safe
      end
    end

    def page_number(page)
      content_tag :li do
        page == current_page ? content_tag(:span, page) : link_to(page, url(page))
      end
    end

    def previous_page
      content_tag(:li, link_to('<', url(current_page - 1))) if current_page > 1
    end

    def next_page
      content_tag(:li, link_to('>', url(current_page + 1))) if current_page < total_pages
    end

    def gap
      content_tag(:li, content_tag(:span, '-', class: 'gap'))
    end
  end
end
