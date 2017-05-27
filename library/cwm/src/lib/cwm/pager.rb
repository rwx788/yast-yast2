require "abstract_method"
require "yast"

require "cwm/widget"

module CWM
  # A {Pager} contains several {Page}s and makes only one visible at a time.
  #
  # {TreePager} is a {Pager}.
  #
  # {Tabs} is a {Pager} and a {Tab} is its {Page}.
  #
  # @see examples/object_api_tabs.rb
  class Pager < CustomWidget
    # @param [Array<CWM::Page>] pages to be shown
    def initialize(*pages)
      @pages = pages
      @current_page = nil
      self.handle_all_events = true
    end

    # initializes pages, show page which is initial
    def init
      mark_page(initial_page)
      @current_page = initial_page
    end

    def handle(event)
      new_id = event["ID"]
      page = page_for_id(new_id)

      return nil unless page

      return nil if @current_page.widget_id == new_id

      unless replace_point.validate
        mark_page(@current_page)
        return nil
      end

      replace_point.store

      switch_page(page)

      nil
    end

  protected

    # gets visual order of pages
    # This default implementation returns same order as passed to constructor
    def page_order
      @pages.map(&:widget_id)
    end

    # stores page with given id
    def store_page
      replace_point.store
    end

    # switch to target page
    def switch_page(page)
      mark_page(page)
      @current_page = page
      replace_point.replace(page)
    end

    # Mark the currently active page in the selector.
    # This is needed in case the user has switched to a different page
    # but we need to switch back because the current one failed validation.
    # @param page [Page]
    # @return [void]
    abstract_method :mark_page

    # The contents will probably include a *selector*, such as {Tabs}
    # or {Tree} and a {replace_point} where {Page}s will appear.
    # @return [WidgetTerm]
    abstract_method :contents

    # gets initial page
    # This default page which return true for method initial otherwise first page passed
    # to constructor
    def initial_page
      initial = @pages.find(&:initial)

      initial || @pages.first
    end

    # gets id of initial page
    def initial_page_id
      initial_page.widget_id
    end

    def page_for_id(id)
      @pages.find { |t| t.widget_id == id }
    end

    def replace_point
      @replace_point = CWM::ReplacePoint.new(id: "_cwm_page_contents_rp", widget: initial_page)
    end
  end
end
