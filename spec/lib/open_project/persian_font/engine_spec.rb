# frozen_string_literal: true

require "spec_helper"
require "open_project/persian_font/engine"

RSpec.describe OpenProject::PersianFont::Engine do
  it "defines the correct engine name" do
    expect(described_class.engine_name.to_s).to eq("openproject_persian_font")
  end
end
