# frozen_string_literal: true

require "open_project/persian_font/version"

module OpenProject
  module PersianFont
    require "open_project/persian_font/engine" if defined?(Rails)
  end
end
