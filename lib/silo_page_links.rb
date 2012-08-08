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

    def page_number(nr)
      content_tag :li do
        nr == current_page ? content_tag(:span, nr) : link_to(nr, url(nr))
      end
    end

    def previous_page
      if current_page > 1
        content_tag :li, class: 'back' do
          link_to t('action.back'), url(current_page - 1)
        end
      end
    end

    def next_page
      if current_page < total_pages
        content_tag :li, class: 'next' do
          link_to t('action.next'), url(current_page + 1)
        end
      end
    end

    def gap
      content_tag :li, content_tag(:span, '...', class: 'gap')
    end
  end
end
