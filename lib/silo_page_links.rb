require 'will_paginate/view_helpers/action_view'

# Provides a custom LinkRenderer used with WillPaginate.
module SiloPageLinks

  # The applications custom LinkRenderer used with WillPaginate.
  #
  #   will_paginate collection, renderer: SiloPageLinks::Renderer
  class Renderer < WillPaginate::ActionView::LinkRenderer
    include ActionView::Context
    include ActionView::Helpers

    # Returns the page links HTML.
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

    # Returns the link for a single page number.
    def page_number(nr)
      content_tag :li do
        nr == current_page ? content_tag(:span, nr) : link_to(nr, url(nr))
      end
    end

    # Returns the link to the previous page.
    def previous_page
      if current_page > 1
        content_tag :li, class: 'back' do
          link_to t('action.back'), url(current_page - 1)
        end
      end
    end

    # Returns the link to the next page.
    def next_page
      if current_page < total_pages
        content_tag :li, class: 'next' do
          link_to t('action.next'), url(current_page + 1)
        end
      end
    end

    # Returns the gap.
    #
    #   gap
    #   #=> '<li><span class="gap">...</span></li>'
    def gap
      content_tag :li, content_tag(:span, '...', class: 'gap')
    end
  end
end
