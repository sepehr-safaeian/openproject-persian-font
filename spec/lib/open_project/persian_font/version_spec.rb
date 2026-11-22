# frozen_string_literal: true

require "spec_helper"

RSpec.describe OpenProject::PersianFont do
  it "has a valid semantic version number" do
    expect(OpenProject::PersianFont::VERSION).to match(/\A\d+\.\d+\.\d+\z/)
    expect(OpenProject::PersianFont::VERSION).to eq("1.0.0")
  end

  it "provides compatibility alias OpenProject::Vazirmatn::VERSION" do
    expect(OpenProject::Vazirmatn::VERSION).to eq(OpenProject::PersianFont::VERSION)
  end
end
