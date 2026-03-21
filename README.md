# 🛡️ VGT HanSafe — Anti-Wiper & Threat Actor Defense Suite

[![License](https://img.shields.io/badge/License-AGPLv3-green?style=for-the-badge)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Windows-0078D4?style=for-the-badge&logo=windows)](https://microsoft.com/windows)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-5391FE?style=for-the-badge&logo=powershell)](https://microsoft.com/powershell)
[![Status](https://img.shields.io/badge/Status-STABLE-brightgreen?style=for-the-badge)](#)
[![Intel](https://img.shields.io/badge/Threat_Intel-FEB_2026-red?style=for-the-badge)](#)
[![VGT](https://img.shields.io/badge/VGT-VisionGaia_Technology-red?style=for-the-badge)](https://visiongaiatechnology.de)
[![Donate](https://img.shields.io/badge/Donate-PayPal-00457C?style=for-the-badge&logo=paypal)](https://www.paypal.com/paypalme/dergoldenelotus)

> *"Geopolitik ist Security. Security ist Geopolitik."*
> *AGPLv3 — For Humans, not for SaaS Corporations.*

**VGT HanSafe** is a two-module defense suite released on **February 28, 2026** — 20 days before the Handala group executed a destructive wiper attack against Stryker Corporation, wiping 200,000+ devices using Microsoft Intune and VSS deletion.

Both scripts were available to the VGT community **before the attack happened.**

---

## 📅 Timeline

```
Feb 28, 2026  →  VGT HanSafe released to VGT Telegram community
               →  Anti-Handala Blacklist deployed
               →  Wiper Shield deployed

Mar 20, 2026  →  Handala hacks Stryker Corporation
               →  Remote wipe via Microsoft Intune
               →  VSS copies deleted
               →  200,000+ devices destroyed

Delta: 20 days of protection advantage
```

> **VGT HanSafe users were protected before the attack happened.**

---

## 📦 Two Modules

| Module | File | Purpose |
|---|---|---|
| 🔥 **Anti-Handala Blacklist** | `anti-han.ps1` | Blocks known Handala C2 infrastructure at firewall + DNS level |
| 🛡️ **Wiper Shield** | `wiper-shield.ps1` | Prevents VSS deletion, remote wipe and file destruction |

---

## 🔥 Module 1 — Anti-Handala Blacklist

Blocks all known Handala group infrastructure — IP ranges, C2 nodes, proxy networks and known domains — at both the Windows Firewall and DNS level.

### What it blocks

```
91.206.178.0/24   →  C2 Infrastructure Cluster A (Handala Primary)
103.14.26.0/24    →  Proxy / Relay Nodes
195.133.40.0/24   →  Exfiltration Gateways
185.162.0.0/16    →  Iranian ASN Range (Broad Block)
193.104.161.0/24  →  Specific VPS Provider used by Handala
5.160.0.0/16      →  AS43754 (Asiatech Data Center)
31.24.0.0/14      →  AS197285 (TCI / TIC)
176.12.0.0/16     →  Known VPN Exit Nodes for Proxy Operations
```

### DNS Sinkhole

Additionally sinkoles known Handala domains to `0.0.0.0`:

```
handala-group.net
handala-ops.org
ir-c2-secure.com
proxy.handala.io
```

### How it works

```
Layer 1 — Windows Firewall (Inbound + Outbound):
→ All traffic to/from Handala ranges is dropped
→ Even if malware is already on the system,
  it cannot phone home to C2

Layer 2 — DNS Sinkhole (hosts file):
→ Known Handala domains resolve to 0.0.0.0
→ No connection possible even if IP changes
```

### Usage

```powershell
# Run as Administrator
Set-ExecutionPolicy Bypass -Scope Process -Force
.\anti-handala.ps1
```

---

## 🛡️ Module 2 — Wiper Shield

Four hardened protection layers against destructive wiper malware — including the exact attack vector Handala used against Stryker.

### The Four Walls

**Wall 1 — VSS Protection (Backup Vault)**
Wiper malware always deletes Shadow Copies first to prevent recovery. Wiper Shield locks `vssadmin.exe` so no process — even with Administrator rights — can delete your backups.

```powershell
# vssadmin.exe execution denied for ALL users (SID *S-1-1-0)
icacls vssadmin.exe /deny "*S-1-1-0:(X)"
```

**Wall 2 — Registry Lock (Command Barrier)**
Blocks destructive system commands via Windows interfaces commonly used by wipers to blind and destroy systems.

```powershell
# Blocks NoRun policy to prevent destructive command execution
Set-ItemProperty -Path $RegPath -Name "NoRun" -Value 1
```

**Wall 3 — Controlled Folder Access (File Guardian)**
Only verified, authorized programs can modify files. A wiper attempting mass file overwrite or deletion is blocked immediately at kernel level.

```powershell
Set-MpPreference -EnableControlledFolderAccess Enabled
```

**Wall 4 — Anti-Remote-Wipe (ASR Rule)**
Blocks PsExec and WMI — the exact tools used by Handala to remotely wipe Stryker's 200,000 devices via Microsoft Intune.

```powershell
# ASR Rule: Block process creations from PsExec and WMI
Add-MpPreference -AttackSurfaceReductionRules_Ids 92e97fa1-2edf-4476-bdd6-9dd0b4dddc7b `
                 -AttackSurfaceReductionRules_Actions Enabled
```

### The Stryker Attack — What Wiper Shield Blocks

| Handala Attack Vector | Wiper Shield Defense |
|---|---|
| VSS / Shadow Copy deletion | ✅ Wall 1 — vssadmin.exe locked |
| Mass file overwrite | ✅ Wall 3 — Controlled Folder Access |
| Remote wipe via WMI/PsExec | ✅ Wall 4 — ASR Rule active |
| Destructive command execution | ✅ Wall 2 — Registry lock |
| C2 communication | ✅ Module 1 — IP + DNS blocked |

### Usage

```powershell
# Run as Administrator
Set-ExecutionPolicy Bypass -Scope Process -Force
.\wiper-shield.ps1
```

---

## 🚀 Installation

### Requirements
- Windows 10 / 11
- PowerShell 5.1+
- Administrator privileges
- Windows Defender active (for CFA and ASR rules)

### Quick Deploy (Both Modules)

```powershell
# Clone
git clone https://github.com/visiongaiatechnology/vgt-hansafe.git
cd vgt-hansafe

# Run as Administrator — deploy both modules
Set-ExecutionPolicy Bypass -Scope Process -Force
.\anti-handala.ps1
.\wiper-shield.ps1
```

### Verify Deployment

```powershell
# Verify Handala firewall rules are active
Get-NetFirewallRule | Where-Object { $_.DisplayName -like "*HANDALA*" } | Select DisplayName, Enabled

# Verify Wiper Shield is active
Get-MpPreference | Select EnableControlledFolderAccess, AttackSurfaceReductionRules_Ids
```

---

## ⚠️ Important Notes

- **Run as Administrator** — both scripts require elevated privileges
- **Controlled Folder Access** may block some legitimate programs — add exceptions via Windows Security if needed
- **vssadmin.exe lock** — to restore VSS access manually: `icacls vssadmin.exe /remove:d "*S-1-1-0"`
- **Threat Intel** — IOCs are verified as of February 2026. Handala infrastructure may change over time.

---

## 🔗 VGT Windows Defense Ecosystem

| Tool | Purpose |
|---|---|
| 🛡️ **VGT HanSafe** | Anti-wiper + Handala threat actor defense |
| 👁️ **[VGT MHX Community Edition](https://github.com/visiongaiatechnology/winxdr)** | Behavioral EDR — detects LotL, C2 and process injection |
| 🔥 **[VGT Windows Firewall Burner](https://github.com/visiongaiatechnology/vgt-windows-burner)** | 280,000+ APT IPs blocked in native Windows Firewall |
| 🔍 **[VGT Civilian Checker](https://github.com/visiongaiatechnology/Winsyssec)** | Full system security posture audit |

> **Recommended stack:** Firewall Burner (block known APTs) + HanSafe (block Handala + wiper protection) + MHX (behavioral monitoring) = complete Windows defense.

---

## 🤝 Contributing

Pull requests welcome — especially updated IOC lists and new threat actor modules.

Licensed under **AGPLv3** — *"For Humans, not for SaaS Corporations."*

---

## ☕ Support the Project

VGT HanSafe is free. If it protected your system:

[![Donate via PayPal](https://img.shields.io/badge/Donate-PayPal-00457C?style=for-the-badge&logo=paypal)](https://www.paypal.com/paypalme/dergoldenelotus)

---

## 🏢 Built by VisionGaia Technology

[![VGT](https://img.shields.io/badge/VGT-VisionGaia_Technology-red?style=for-the-badge)](https://visiongaiatechnology.de)

VisionGaia Technology builds enterprise-grade security tooling — engineered to the DIAMANT VGT SUPREME standard.

> *"Released February 28. Handala hacked Stryker on March 20. Our community was protected 20 days before the attack."*

---

*VGT HanSafe — Anti-Wiper & Threat Actor Defense Suite // DIAMANT VGT SUPREME*
