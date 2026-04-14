# Work-Desk 🖥️

An automated environment setup script for Windows. This project uses PowerShell and `winget` to transform a fresh Windows installation into a ready-to-use workstation with essential software and personalized configurations.

## 🚀 Overview

The `auto.ps1` script automates the following tasks:
1.  **Software Installation**: Detects and installs missing essential programs using Windows Package Manager (`winget`).
2.  **Custom Office 365 Deployment**: Downloads and installs a specific version of Office 365 (PT-BR) using the Office Deployment Tool (ODT) and a custom `config.xml`.
3.  **Visual Personalization**: Downloads a repository-hosted wallpaper and applies it as the desktop background automatically.

## 📦 Included Software
The script checks for and installs:
*   **Browsers**: Google Chrome
*   **Runtimes**: Java JRE
*   **Utilities**: WinRAR
*   **Documents**: Adobe Acrobat Reader (64-bit)
*   **Productivity**: Microsoft Office 365 (Custom PT-BR build)

## 🛠️ How to Use

To run this setup on a new machine, follow these steps:

1.  Open **PowerShell** as an **Administrator**.
2.  Run the following command to execute the script directly from the cloud:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; 
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; 
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/arthurdev449/Work-Desk/main/auto.ps1'))
```

## 📂 File Structure

*   `auto.ps1`: The main automation engine. Handles logic, downloads, and system calls.
*   `config.xml`: Configuration file for the Office Deployment Tool. It is set to install 64-bit Office in Portuguese (Brazil), excluding unnecessary apps like Access, Teams, and Lync.
*   `wallpaper.png`: The default desktop background applied by the script.
*   `LICENSE`: Licensed under the Apache License 2.0.

## ⚙️ Requirements
*   **Windows 10/11**
*   **PowerShell 5.1+**
*   **Internet Connection**
*   **Administrator Privileges**

## 📝 Technical Notes
*   **Office Deployment**: The script dynamically downloads the official Microsoft Office Deployment Tool (ODT) and applies the local `config.xml` during runtime.
*   **Wallpaper Logic**: Uses a C# snippet (via `Add-Type`) within PowerShell to interface with the `user32.dll` system API for immediate wallpaper application without requiring a log-off.

---
**Author:** [Arthur Zanini Marzagão](https://github.com/arthurdev449)  
**License:** Apache-2.0
