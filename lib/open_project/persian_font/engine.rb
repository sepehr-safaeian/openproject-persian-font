# frozen_string_literal: true

require "rails/engine"

# Prevent load-order problems in case openproject-plugins is listed after a plugin
begin
  require "open_project/plugins"
rescue LoadError
  # Running in standalone test environment or non-OpenProject Rails app
end

module OpenProject::PersianFont
  class Engine < ::Rails::Engine
    engine_name :openproject_persian_font

    if defined?(OpenProject::Plugins::ActsAsOpEngine)
      include OpenProject::Plugins::ActsAsOpEngine

      register "openproject-persian-font",
               author_url: "https://github.com/Sepehr-Safaeian/openproject-persian-font",
               requires_openproject: ">= 12.0.0"

      assets %w(openproject_persian_font/vazirmatn.css)
    end

    initializer "openproject_persian_font.assets" do |app|
      app.config.assets.paths << root.join("app", "assets", "stylesheets").to_s
      app.config.assets.paths << root.join("app", "assets", "fonts").to_s
      if app.config.respond_to?(:assets) && app.config.assets.respond_to?(:precompile)
        app.config.assets.precompile += %w(openproject_persian_font/vazirmatn.css)
      end
    end

    initializer "openproject_persian_font.register_hooks" do
      config.to_prepare do
        require "open_project/persian_font/hooks"
      end
    end
  end
end
