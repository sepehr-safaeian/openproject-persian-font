# frozen_string_literal: true

require "net/http"
require "uri"
require "fileutils"
require "tempfile"

module OpenProject
  module PersianFont
    class FontInstaller
      FONT_VERSION = "33.0.3"
      CDN_BASE_URL = "https://cdn.jsdelivr.net/npm/vazirmatn@#{FONT_VERSION}".freeze
      CSS_RELATIVE_PATH = "Vazirmatn-Variable-font-face.css"
      WOFF2_MAGIC = "wOF2".b.freeze

      class Error < StandardError; end
      class DownloadError < Error; end
      class ValidationError < Error; end

      attr_reader :base_dir, :logger

      def initialize(base_dir: nil, logger: nil)
        @base_dir = base_dir || default_base_dir
        @logger = logger || default_logger
      end

      def self.install!(...)
        new(...).install!
      end

      def self.verify!(...)
        new(...).verify!
      end

      def install!(force: false)
        log_info "Checking Vazirmatn installation..."

        if !force && installed?
          log_success "Vazirmatn #{FONT_VERSION} is already installed and verified."
          return true
        end

        log_info "Downloading Vazirmatn #{FONT_VERSION}..."

        FileUtils.mkdir_p(fonts_dir)
        FileUtils.mkdir_p(stylesheets_dir)

        css_content = fetch_http(css_url)
        validate_non_empty!(css_content, "CSS stylesheet")

        relative_font_path = extract_font_path(css_content)
        font_url = "#{CDN_BASE_URL}/#{relative_font_path}"

        font_binary = fetch_http(font_url)
        validate_font_binary!(font_binary)

        font_filename = File.basename(relative_font_path)
        target_font_path = File.join(fonts_dir, font_filename)
        atomic_write(target_font_path, font_binary)

        local_css = generate_local_css(target_font_filename: font_filename)
        atomic_write(target_css_path, local_css)

        log_success "Font assets installed successfully."
        verify!
        true
      end

      def verify!
        unless File.exist?(target_font_path)
          raise ValidationError, "Font file missing at #{target_font_path}"
        end

        font_content = File.binread(target_font_path)
        validate_font_binary!(font_content)

        unless File.exist?(target_css_path)
          raise ValidationError, "CSS file missing at #{target_css_path}"
        end

        css_content = File.read(target_css_path)
        unless css_content.include?("Vazirmatn") && css_content.include?("@font-face")
          raise ValidationError, "Invalid CSS format in #{target_css_path}"
        end

        log_success "Local font configuration verified."
        true
      end

      def installed?
        File.exist?(target_font_path) &&
          File.exist?(target_css_path) &&
          valid_font_file?(target_font_path) &&
          File.size(target_css_path).positive?
      rescue StandardError
        false
      end

      def fonts_dir
        File.expand_path(File.join(base_dir, "app/assets/fonts/openproject_persian_font"))
      end

      def stylesheets_dir
        File.expand_path(File.join(base_dir, "app/assets/stylesheets/openproject_persian_font"))
      end

      def target_font_path
        File.join(fonts_dir, "Vazirmatn[wght].woff2")
      end

      def target_css_path
        File.join(stylesheets_dir, "vazirmatn.css")
      end

      def css_url
        "#{CDN_BASE_URL}/#{CSS_RELATIVE_PATH}"
      end

      private

      def default_base_dir
        File.expand_path("../../../", __dir__)
      end

      def default_logger
        if defined?(Rails.logger) && Rails.logger
          Rails.logger
        else
          SimpleLogger.new
        end
      end

      def log_info(msg)
        if logger.respond_to?(:info)
          logger.info("[INFO] #{msg}")
        else
          puts "[INFO] #{msg}"
        end
      end

      def log_success(msg)
        if logger.respond_to?(:info)
          logger.info("[SUCCESS] #{msg}")
        else
          puts "[SUCCESS] #{msg}"
        end
      end

      def fetch_http(url_string, limit = 5)
        raise DownloadError, "HTTP redirect limit exceeded" if limit <= 0

        # Encode brackets for RFC3986 parser compatibility
        safe_url = url_string.gsub("[", "%5B").gsub("]", "%5D")
        uri = URI.parse(safe_url)
        unless uri.is_a?(URI::HTTPS)
          raise DownloadError, "Insecure URL scheme: #{uri.scheme}. Only HTTPS is permitted."
        end

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.open_timeout = 15
        http.read_timeout = 30

        request = Net::HTTP::Get.new(uri.request_uri)
        request["User-Agent"] = "OpenProject-Persian-Font/#{OpenProject::PersianFont::VERSION}"

        response = http.request(request)

        case response
        when Net::HTTPSuccess
          response.body
        when Net::HTTPRedirection
          location = response["location"]
          redirect_uri = URI.parse(location)
          redirect_url = redirect_uri.relative? ? URI.join(url_string, location).to_s : location
          fetch_http(redirect_url, limit - 1)
        else
          raise DownloadError, "Failed to download from #{url_string}: HTTP #{response.code} #{response.message}"
        end
      rescue SocketError, Timeout::Error, Errno::ECONNREFUSED => e
        raise DownloadError, "Network error downloading #{url_string}: #{e.message}"
      end

      def validate_non_empty!(content, name)
        if content.nil? || content.bytesize.zero?
          raise ValidationError, "#{name} is empty"
        end
      end

      def validate_font_binary!(data)
        validate_non_empty!(data, "Font asset")

        if data.bytesize < 1000
          raise ValidationError, "Font binary is unexpectedly small (#{data.bytesize} bytes)"
        end

        header = data[0, 4]
        unless header == WOFF2_MAGIC
          raise ValidationError, "Invalid WOFF2 signature header. Expected 'wOF2', got #{header.inspect}"
        end
      end

      def valid_font_file?(path)
        return false unless File.exist?(path) && File.size(path) >= 1000

        File.open(path, "rb") { |f| f.read(4) == WOFF2_MAGIC }
      end

      def extract_font_path(css_content)
        match = css_content.match(/url\(['"]?([^'")]+?\.woff2)['"]?\)/i)
        if match && match[1]
          match[1].sub(%r{^\./}, "")
        else
          "fonts/webfonts/Vazirmatn[wght].woff2"
        end
      end

      def generate_local_css(target_font_filename:)
        <<~CSS
          /* Local Vazirmatn Variable Font Definition */
          @font-face {
            font-family: 'Vazirmatn';
            src: url('/assets/openproject_persian_font/#{target_font_filename}') format('woff2 supports variations'),
                 url('/assets/openproject_persian_font/#{target_font_filename}') format('woff2-variations');
            font-weight: 100 900;
            font-style: normal;
            font-display: swap;
          }

          /* CSS Custom Properties / Design Tokens */
          :root {
            --body-font-family: "Vazirmatn", -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            --fontStack-sans-serif: "Vazirmatn", -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            --fontStack-system: "Vazirmatn", -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            --ck-content-font-family: var(--body-font-family);
          }

          /* Global Application Typography */
          html,
          body,
          #wrapper,
          .op-app,
          .primer-theme,
          [data-color-mode] {
            font-family: var(--body-font-family);
          }

          /* Header, Navigation & Sidebar */
          .op-app-header,
          .op-app-header * :not([class*="icon"]):not(.octicon),
          .op-sidebar,
          .main-menu,
          .main-menu--navigation,
          .op-tabs {
            font-family: var(--body-font-family);
          }

          /* Form Controls & Interactive Elements */
          button,
          .button,
          .btn,
          input:not([type="checkbox"]):not([type="radio"]):not([type="color"]),
          optgroup,
          select,
          textarea,
          .form--field,
          .form--label,
          .form--text-field,
          .form--select {
            font-family: var(--body-font-family);
          }

          /* Tables, Data Grids & Work Packages */
          .generic-table,
          .generic-table--cell,
          .data-table,
          .wp-table,
          .work-packages--table,
          .work-package--details,
          .work-packages--show-view,
          .wp-card {
            font-family: var(--body-font-family);
          }

          /* Agile Boards, Modals, Dropdowns & Notifications */
          .boards-list,
          .board-column,
          .modal-delivery,
          .spot-modal,
          .op-dialog,
          .dropdown-menu,
          .action-menu,
          .op-toast,
          .flash,
          .notification-box,
          .settings-section,
          .user-profile-widget {
            font-family: var(--body-font-family);
          }

          /* Preserve Icon Fonts */
          [class^="icon-"],
          [class*=" icon-"],
          .op-icon,
          .octicon,
          .fa,
          [class^="spot-icon-"],
          .openproject-icon-font {
            font-family: "openproject-icon-font" !important;
          }
        CSS
      end

      def atomic_write(target_path, content)
        dir = File.dirname(target_path)
        FileUtils.mkdir_p(dir)

        temp_file = Tempfile.new(["asset", File.extname(target_path)], dir)
        temp_path = temp_file.path

        begin
          temp_file.binmode
          temp_file.write(content)
          temp_file.flush
          temp_file.close

          File.rename(temp_path, target_path)
        rescue StandardError => e
          temp_file.close unless temp_file.closed?
          FileUtils.rm_f(temp_path)
          raise e
        end
      end

      class SimpleLogger
        def info(msg)
          puts msg
        end

        def error(msg)
          warn msg
        end
      end
    end
  end
end
