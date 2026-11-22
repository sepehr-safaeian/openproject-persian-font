# frozen_string_literal: true

require "open_project/persian_font/version"
require "open_project/persian_font/font_installer"
require "open_project/vazirmatn"

module OpenProject
  module PersianFont
    require "open_project/persian_font/engine" if defined?(Rails)
  end
end
