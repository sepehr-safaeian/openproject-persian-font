# Persian Font for OpenProject

<div align="center">

[![CI](https://github.com/Sepehr-Safaeian/openproject-persian-font/actions/workflows/ci.yml/badge.svg)](https://github.com/Sepehr-Safaeian/openproject-persian-font/actions/workflows/ci.yml)
[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/Sepehr-Safaeian/openproject-persian-font/releases)
[![OpenProject](https://img.shields.io/badge/OpenProject-%3E%3D%2012.0-indigo.svg)](https://www.openproject.org)
[![Font](https://img.shields.io/badge/Font-Vazirmatn%2033.0.3-emerald.svg)](https://github.com/rastikerdar/vazirmatn)
[![License](https://img.shields.io/badge/License-MIT-orange.svg)](LICENSE)

**Native, elegant Persian typography for OpenProject powered by local Vazirmatn variable fonts.**

[Key Capabilities](#key-capabilities) •
[Architecture](#architecture) •
[Installation Guide](#installation-guide) •
[Verification](#verification) •
[Compatibility Matrix](#compatibility-matrix) •
[Troubleshooting](#troubleshooting) •
[License](#license)

</div>

---

## Overview

**Persian Font for OpenProject** integrates the modern **Vazirmatn** typeface directly into the OpenProject interface. Built strictly around local asset serving, it eliminates external runtime CDN requests, delivers fast typographic rendering in disconnected and on-premise environments, and preserves full system icon font integrity.

```
┌─────────────────────────────────────────┐
│           OpenProject Web UI            │
│  (Header, Menus, Work Packages, Boards) │
└────────────────────┬────────────────────┘
                     │ overrides --body-font-family
┌────────────────────▼────────────────────┐
│      Plugin Head Hook & Stylesheet      │
│  (app/assets/stylesheets/.../vazirmatn) │
└────────────────────┬────────────────────┘
                     │ references local WOFF2
┌────────────────────▼────────────────────┐
│         Local Variable WOFF2            │
│      (Vazirmatn[wght].woff2: 100-900)   │
└─────────────────────────────────────────┘
```

---

## Key Capabilities

- **Complete Interface Typographic Coverage**: Automatically applies to navigation bars, work package lists, agile boards, dialog modals, forms, tables, and settings views.
- **Variable Font Delivery (100–900 Weights)**: Utilizes a single modern WOFF2 variable font container supporting all weights from Thin (100) to Black (900).
- **100% Offline Runtime**: All font files are stored within the application assets; no client browser ever queries external endpoints at runtime.
- **Zero-Dependency Core**: Pure Ruby on Rails Engine architecture; no Node.js or frontend rebuild requirements.
- **Idempotent Asset Installation**: Font installer validates HTTP integrity, enforces WOFF2 binary headers, and avoids redundant network transfers.
- **Atomic Operations**: Employs atomic staging for file writes to prevent corrupted asset states.
- **Icon Font Preservation**: Carefully scoped selectors prevent collision with OpenProject icon fonts and Octicons.

---

## Typography Specifications

| Specification | Value |
| :--- | :--- |
| **Primary Font Family** | `Vazirmatn` |
| **Typeface Upstream** | `rastikerdar/vazirmatn` |
| **Pinned Font Release** | `33.0.3` |
| **Container Format** | WOFF2 (Variable Font) |
| **Supported Weights** | 100, 200, 300, 400, 500, 600, 700, 800, 900 |
| **Fallback Stack** | `-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif` |
| **Font File Size** | ~111 KB |

---

## Installation Guide

### Step 1: Register in Gemfile.plugins

Append the gem declaration to your OpenProject `Gemfile.plugins` file:

```ruby
group :opf_plugins do
  gem "openproject-persian-font",
      git: "https://github.com/Sepehr-Safaeian/openproject-persian-font.git",
      tag: "v1.0.0"
end
```

### Step 2: Install Bundle Dependencies

Execute Bundler from your OpenProject directory:

```bash
bundle install
```

### Step 3: Fetch and Install Local Font Assets

Run the automated font installation task:

```bash
bundle exec rake openproject_persian_font:install_font
```

> **Note**: For backward compatibility, `rake openproject_vazirmatn:install_font` is also supported.

### Step 4: Verify Asset Integrity

Confirm the local font files and stylesheets are valid:

```bash
bundle exec rake openproject_persian_font:verify_font
```

### Step 5: Precompile Assets and Restart Server

Compile assets (if running in production) and restart OpenProject:

```bash
# In production installations:
bundle exec rake assets:precompile

# Restart your application server (Puma, Passenger, Docker, or systemd):
# systemctl restart openproject
# or
# docker restart openproject-app
```

---

## Verification

To ensure successful integration:

1. Open your browser developer tools (`F12`) on any OpenProject page.
2. Select the **Network** tab and filter by `Font` or `WS`.
3. Reload the page: `Vazirmatn[wght].woff2` must load with HTTP `200` from your local domain (`/assets/openproject_persian_font/...`).
4. Ensure no requests are dispatched to external CDN servers.
5. In the **Computed** styles panel for text elements, verify `font-family` renders `Vazirmatn`.

---

## Compatibility Matrix

| Component | Supported Version Range | Status |
| :--- | :--- | :--- |
| **OpenProject** | `12.x`, `13.x`, `14.x`, `15.x`, `16.x`, `17.x` | Verified |
| **Ruby** | `>= 3.1.0` (including `3.2`, `3.3`, `3.4`) | Verified |
| **Rails** | `~> 7.0`, `~> 7.1`, `~> 8.0` | Verified |
| **Modern Browsers** | Chrome/Edge >= 80, Firefox >= 75, Safari >= 14 | Verified |

---

## Troubleshooting

### The font does not appear after installation
- Check that `bundle exec rake openproject_persian_font:verify_font` completes with `[SUCCESS]`.
- If running under production mode (`RAILS_ENV=production`), ensure `bundle exec rake assets:precompile` was executed.
- Clear browser cache (`Ctrl+F5` / `Cmd+Shift+R`).

### Network failure during font download
- The installer preserves any previously installed valid assets if the network fails.
- Once connectivity is available, re-run with force flag:
  ```bash
  bundle exec rake openproject_persian_font:install_font[true]
  ```

---

## Contributing

Contributions, bug reports, and suggestions are welcome. Please check [CONTRIBUTING.md](CONTRIBUTING.md) for testing guidelines and pull request conventions.

---

## Licensing & Attribution

- **Plugin Code**: Distributed under the [MIT License](LICENSE).
- **Vazirmatn Font**: Designed by Saber Rastikerdar and contributors, distributed under the [SIL Open Font License 1.1](FONT-LICENSE.txt).

---

## Author

**Sepehr Safaeian**  
- GitHub: [@sepehr-safaeian](https://github.com/sepehr-safaeian)  
- LinkedIn: [Sepehr Safaeian](https://www.linkedin.com/in/sepehr-safaeian)
