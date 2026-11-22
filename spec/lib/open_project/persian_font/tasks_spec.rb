# frozen_string_literal: true

require "spec_helper"
require "rake"

RSpec.describe "OpenProject Persian Font Rake tasks" do
  before(:all) do
    Rake.application = Rake::Application.new
    load File.expand_path("../../../../lib/tasks/openproject_persian_font.rake", __dir__)
    Rake::Task.define_task(:environment)
  end

  describe "openproject_persian_font:install_font" do
    it "invokes FontInstaller.install!" do
      expect(OpenProject::PersianFont::FontInstaller).to receive(:install!).with(force: false).and_return(true)
      Rake::Task["openproject_persian_font:install_font"].reenable
      Rake::Task["openproject_persian_font:install_font"].invoke
    end
  end

  describe "openproject_persian_font:verify_font" do
    it "invokes FontInstaller.verify!" do
      expect(OpenProject::PersianFont::FontInstaller).to receive(:verify!).and_return(true)
      Rake::Task["openproject_persian_font:verify_font"].reenable
      Rake::Task["openproject_persian_font:verify_font"].invoke
    end
  end
end
