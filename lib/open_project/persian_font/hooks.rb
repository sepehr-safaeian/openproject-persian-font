# frozen_string_literal: true

module OpenProject
  module PersianFont
    class Hooks < (defined?(OpenProject::Hook::ViewListener) ? OpenProject::Hook::ViewListener : Object)
      if defined?(OpenProject::Hook::ViewListener)
        render_on :view_layouts_base_html_head, partial: "hooks/openproject_persian_font/head"
      end

      def self.hook_name
        :view_layouts_base_html_head
      end
    end
  end
end
