# frozen_string_literal: true

require "spec_helper"
require "open_project/persian_font/font_installer"

RSpec.describe OpenProject::PersianFont::FontInstaller do
  let(:tmp_dir) { Dir.mktmpdir("op_persian_font_test") }
  let(:null_logger) { instance_double("Logger", info: nil, error: nil) }
  let(:installer) { described_class.new(base_dir: tmp_dir, logger: null_logger) }

  let(:mock_css_url) { "https://cdn.jsdelivr.net/npm/vazirmatn@33.0.3/Vazirmatn-Variable-font-face.css" }
  let(:mock_font_url) { "https://cdn.jsdelivr.net/npm/vazirmatn@33.0.3/fonts/webfonts/Vazirmatn%5Bwght%5D.woff2" }

  let(:sample_css) do
    <<~CSS
      @font-face {
        font-family: 'Vazirmatn';
        src: url('fonts/webfonts/Vazirmatn[wght].woff2') format('woff2 supports variations');
      }
    CSS
  end

  # Valid WOFF2 binary starts with "wOF2" followed by dummy bytes to reach > 1000 bytes
  let(:valid_woff2_binary) { "wOF2" + ("\x00" * 1500) }
  let(:invalid_woff2_binary) { "FAIL" + ("\x00" * 1500) }

  after do
    FileUtils.remove_entry(tmp_dir) if File.directory?(tmp_dir)
  end

  describe "#install!" do
    context "with valid upstream responses" do
      before do
        stub_request(:get, mock_css_url).to_return(status: 200, body: sample_css)
        stub_request(:get, mock_font_url).to_return(status: 200, body: valid_woff2_binary)
      end

      it "downloads and creates local font and stylesheet files" do
        expect(installer.install!).to be true

        expect(File.exist?(installer.target_font_path)).to be true
        expect(File.exist?(installer.target_css_path)).to be true

        font_data = File.binread(installer.target_font_path)
        expect(font_data[0, 4]).to eq("wOF2")

        css_data = File.read(installer.target_css_path)
        expect(css_data).to include("Vazirmatn")
        expect(css_data).to include("--body-font-family")
        expect(css_data).to include("/assets/openproject_persian_font/Vazirmatn[wght].woff2")
      end

      it "is idempotent and does not re-download if assets exist" do
        installer.install!

        # Remove stubs to verify no further HTTP requests occur
        WebMock.reset!

        expect(installer.install!).to be true
      end

      it "supports reinstallation when force: true is provided" do
        installer.install!

        stub_request(:get, mock_css_url).to_return(status: 200, body: sample_css)
        stub_request(:get, mock_font_url).to_return(status: 200, body: valid_woff2_binary)

        expect(installer.install!(force: true)).to be true
      end
    end

    context "when upstream returns HTTP error" do
      it "raises DownloadError on HTTP 404" do
        stub_request(:get, mock_css_url).to_return(status: 404, body: "Not Found")

        expect { installer.install! }.to raise_error(OpenProject::PersianFont::FontInstaller::DownloadError, /HTTP 404/)
      end

      it "raises DownloadError on HTTP 500" do
        stub_request(:get, mock_css_url).to_return(status: 500, body: "Server Error")

        expect { installer.install! }.to raise_error(OpenProject::PersianFont::FontInstaller::DownloadError, /HTTP 500/)
      end

      it "preserves existing valid assets if re-download fails" do
        # Setup initial valid installation
        stub_request(:get, mock_css_url).to_return(status: 200, body: sample_css)
        stub_request(:get, mock_font_url).to_return(status: 200, body: valid_woff2_binary)
        installer.install!

        original_font_content = File.binread(installer.target_font_path)

        # Re-attempt with failure
        stub_request(:get, mock_css_url).to_return(status: 503, body: "Service Unavailable")
        expect { installer.install!(force: true) }.to raise_error(OpenProject::PersianFont::FontInstaller::DownloadError)

        # Verify existing file is untouched
        expect(File.binread(installer.target_font_path)).to eq(original_font_content)
      end
    end

    context "when upstream returns empty or invalid content" do
      it "raises ValidationError if CSS response is empty" do
        stub_request(:get, mock_css_url).to_return(status: 200, body: "")

        expect { installer.install! }.to raise_error(OpenProject::PersianFont::FontInstaller::ValidationError, /CSS stylesheet is empty/)
      end

      it "raises ValidationError if font binary does not have wOF2 signature" do
        stub_request(:get, mock_css_url).to_return(status: 200, body: sample_css)
        stub_request(:get, mock_font_url).to_return(status: 200, body: invalid_woff2_binary)

        expect { installer.install! }.to raise_error(OpenProject::PersianFont::FontInstaller::ValidationError, /Invalid WOFF2 signature/)
      end

      it "raises ValidationError if font binary is truncated" do
        stub_request(:get, mock_css_url).to_return(status: 200, body: sample_css)
        stub_request(:get, mock_font_url).to_return(status: 200, body: "wOF2_short")

        expect { installer.install! }.to raise_error(OpenProject::PersianFont::FontInstaller::ValidationError, /unexpectedly small/)
      end
    end
  end

  describe "#verify!" do
    it "succeeds when valid assets are present" do
      FileUtils.mkdir_p(installer.fonts_dir)
      FileUtils.mkdir_p(installer.stylesheets_dir)
      File.binwrite(installer.target_font_path, valid_woff2_binary)
      File.write(installer.target_css_path, "@font-face { font-family: 'Vazirmatn'; }")

      expect(installer.verify!).to be true
    end

    it "raises ValidationError when font file is missing" do
      FileUtils.mkdir_p(installer.stylesheets_dir)
      File.write(installer.target_css_path, "@font-face { font-family: 'Vazirmatn'; }")

      expect { installer.verify! }.to raise_error(OpenProject::PersianFont::FontInstaller::ValidationError, /Font file missing/)
    end

    it "raises ValidationError when font file is corrupted" do
      FileUtils.mkdir_p(installer.fonts_dir)
      FileUtils.mkdir_p(installer.stylesheets_dir)
      File.binwrite(installer.target_font_path, invalid_woff2_binary)
      File.write(installer.target_css_path, "@font-face { font-family: 'Vazirmatn'; }")

      expect { installer.verify! }.to raise_error(OpenProject::PersianFont::FontInstaller::ValidationError, /Invalid WOFF2 signature/)
    end
  end
end
