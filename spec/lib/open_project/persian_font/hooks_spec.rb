# frozen_string_literal: true

require "spec_helper"
require "open_project/persian_font/hooks"

RSpec.describe OpenProject::PersianFont::Hooks do
  it "defines the head hook name" do
    expect(described_class.hook_name).to eq(:view_layouts_base_html_head)
  end
end
