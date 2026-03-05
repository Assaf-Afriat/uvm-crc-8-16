# Upload to GitHub

## 1. Create the repo

- Go to [github.com/new](https://github.com/new).
- **Repository name:** `uvm-crc-8-16`
- **Description:** `Configurable CRC-8/16 RTL with full UVM verification (SystemVerilog, QuestaSim). Serial and parallel modes.`
- **Public**, no README, no .gitignore (we have them already).
- Create repository.

## 2. Push this project

From this folder (`DUTs/crc-8-16`):

```powershell
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/uvm-crc-8-16.git
git push -u origin main
```

Or run `.\upload-to-github.ps1` and enter your GitHub username when prompted.

## 3. Set description and topics (on GitHub)

- **Description:**  
  `Configurable CRC-8/16 RTL with full UVM verification (SystemVerilog, QuestaSim). Serial and parallel modes.`
- **Topics:** `systemverilog` `uvm` `rtl` `verification` `fpga` `crc` `questa`

## 4. (Optional) Enable GitHub Pages for the demo

Settings → Pages → Source: **Deploy from branch** → Branch: **main** → Folder: **/ (root)** → Save.  
Demo URL: `https://YOUR_USERNAME.github.io/uvm-crc-8-16/demo/`
