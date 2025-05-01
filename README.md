# 🚀 Rails 8 Demo App – GitHub Codespaces Ready

This repository demonstrates how to generate PDFs from Rails views using
**[`bidi2pdf-rails`](https://rubygems.org/gems/bidi2pdf-rails)** — a modern alternative to Grover or WickedPDF.

## 🔧 Key Technologies

- **Rails 8** – Latest framework version
- **bidi2pdf-rails** – PDF generation via the **BiDi protocol** of ChromeDriver
- **Propshaft** – Lightweight asset pipeline
- **Importmaps** – JavaScript without bundlers
- **Stimulus** – JavaScript framework for modest interactivity
- **Page.js** – Client-side navigation

> **Purpose:** Show how to use `bidi2pdf-rails` to generate high-fidelity PDFs from Rails views **using the native
browser automation capabilities of Chrome (BiDi protocol)**, eliminating the need for tools like Grover or wkhtmltopdf.

---

## ☁️ Instant Setup with GitHub Codespaces

This app is **fully configured for GitHub Codespaces**.

### 🏁 Get started:

1. **Fork** this repo
2. **Open** in a GitHub Codespace
3. **Start the Rails server**:

```bash
./bin/rails s -b 0.0.0.0
```

> You'll access the app via the forwarded port shown in the Codespace interface.

---

## 🖨️ PDF Generation with `bidi2pdf-rails`

`bidi2pdf-rails` uses **ChromeDriver’s BiDi protocol** (Bidirectional WebDriver) to:

- Control a Chromium instance directly from Rails
- Render actual browser output into a PDF
- Avoid flaky headless-browser setups like Puppeteer or wkhtmltopdf
- Keep configuration minimal and embedded within your Rails stack

---

## 🖥️ Optional: View Chromium via VNC

To visually inspect what Chromium renders, VNC is enabled inside the container.

### 🔧 Setup VNC forwarding:

```bash
# Within codespaces
# go to ports tab and forward port 5900

# locally forward the remote port 59000 to 6000 local port
gh auth status
# If not logged in:
echo $GITHUB_TOKEN | gh auth login --with-token

gh codespace list
gh codespace ports forward 5900:6000
```

### 🖥️ Connect:

- Open `vnc://localhost:6000` in a VNC viewer  
  (On macOS: Finder → ⌘ + K → `vnc://localhost:6000`)

- Password: set in `.devcontainer/compose.yml` under `VNC_PASS`, or check container logs if not defined.

---

## ✅ Summary

This app shows how to use the **BiDi protocol of ChromeDriver** via `bidi2pdf-rails` to generate PDFs from Rails views —
a clean, native browser rendering approach that sidesteps complex setups and external services.

---
