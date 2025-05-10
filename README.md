# 🚀 Rails 8 Demo App – GitHub Codespaces Ready

This repository demonstrates how to generate high-fidelity PDFs from Rails views using  
**[`bidi2pdf-rails`](https://rubygems.org/gems/bidi2pdf-rails)** — a modern, native alternative to Grover or WickedPDF.

---

## 🔧 Key Technologies

- **Rails 8** – The latest version of the Ruby on Rails framework
- **bidi2pdf-rails** – PDF generation via ChromeDriver’s **BiDi (Bidirectional) protocol**
- **Propshaft** – A lightweight, modern asset pipeline
- **Importmaps** – JavaScript without bundlers or Node
- **Stimulus** – A minimal JavaScript framework for progressive enhancements
- **Page.js** – Fast, client-side navigation with zero SPA overhead

> **Goal:** Showcase how to leverage `bidi2pdf-rails` for clean, browser-accurate PDF rendering inside Rails, using
> Chrome’s native BiDi protocol—no Puppeteer, no wkhtmltopdf, no hassle.

---

## ☁️ Instant Setup with GitHub Codespaces

This app is **fully preconfigured for GitHub Codespaces**, making onboarding as smooth as possible.

### 🏁 Getting Started:

1. **Fork** this repository
2. **Open** it in a GitHub Codespace
3. **Wait** for the container to build and run `bin/setup` (takes a few minutes)
4. **Start the Rails server**:

```bash
./bin/rails s -b 0.0.0.0
```

> Access the app via the forwarded port shown in the Codespace interface.

---

## 🖨️ PDF Generation with `bidi2pdf-rails`

The gem uses **ChromeDriver's BiDi protocol** to:

- Launch and control a Chromium browser
- Render full browser output to PDF
- Avoid fragile, legacy PDF tools like wkhtmltopdf
- Keep everything inside your Rails stack — no Node, no extra services

---

## 🖥️ Optional: Visual Browser Rendering via VNC

You can observe exactly what Chromium renders by connecting to the live browser instance through VNC.

### 🔧 VNC Setup Instructions:

```bash
# In your GitHub Codespace:
# Open the "Ports" tab and forward port 5900

# On your local machine:
gh auth status
# If not authenticated:
echo $GITHUB_TOKEN | gh auth login --with-token

gh codespace list
gh codespace ports forward 5900:6000
```

### 🖥️ Connect with VNC Viewer:

- Open `vnc://localhost:6000` in your VNC viewer  
  (macOS shortcut: Finder → ⌘ + K → enter the URL)

- Password: Defined in `.devcontainer/compose.yml` under `VNC_PASS`, or check the container logs if undefined.

---

## 🚀 Deployment with Kamal

This app is ready for **simple, single-machine deployment with [Kamal](https://github.com/basecamp/kamal)**.

You'll need [`sops`](https://github.com/getsops/sops) to manage encrypted secrets.

### 🔐 Add production secrets:

```bash
sops edit .kamal/production.secrets.yml
```

Example content:

```yaml
mysql_root_password: ...
mysql_password: ...
registry_password: ...
minio_root_password: ...
master_key: ...
```

### 🌍 Configure your environment:

Set the following variables in your environment or `.env` file:

```bash
SERVER_IP=<your-server-ip>
USER_ID=<kamal-uid>
GROUP_ID=<kamal-gid>
```

### 🚢 Deploy:

```bash
kamal server bootstrap -v \
  && kamal accessory boot all \
  && kamal deploy -v
```

> For more context, tips, and caveats, check out this deep dive:  
> [Kamal Deployment Chronicles – The Quest for Production-like Nirvana](https://medium.com/code-and-coffee/kamal-deployment-chronicles-the-quest-for-production-like-nirvana-82c9ce727045)

---

## ✅ Summary

This demo app illustrates a modern way to generate PDFs directly from Rails views using the **native BiDi protocol of
ChromeDriver**, offering:

- **True-to-browser output**
- **Zero Node.js dependencies**
- **Full Rails integration**
- **GitHub Codespaces + Kamal support out of the box**

Build PDFs the Rails way — clean, fast, and future-ready.
