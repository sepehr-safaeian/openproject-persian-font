# frozen_string_literal: true

require "open_project/persian_font/font_installer"

namespace :openproject_persian_font do
  desc "Download and install local Vazirmatn font assets"
  task :install_font, [:force] => :environment do |_t, args|
    force = args[:force].to_s == "true"
    OpenProject::PersianFont::FontInstaller.install!(force: force)
  end

  desc "Verify local Vazirmatn font assets"
  task verify_font: :environment do
    OpenProject::PersianFont::FontInstaller.verify!
  end
end

# Compatibility alias namespace
namespace :openproject_vazirmatn do
  desc "Download and install local Vazirmatn font assets (alias)"
  task :install_font, [:force] do |_t, args|
    Rake::Task["openproject_persian_font:install_font"].invoke(args[:force])
  end

  desc "Verify local Vazirmatn font assets (alias)"
  task verify_font: [] do
    Rake::Task["openproject_persian_font:verify_font"].invoke
  end
end
