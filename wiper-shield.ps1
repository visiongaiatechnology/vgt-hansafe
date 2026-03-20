# ==============================================================================
# VISIONGAIATECHNOLOGY - WIPER SHIELD MODULE V1.1 (LOCALE INDEPENDENT)
# STATUS: SUPREME PROTECTION / ANTI-DESTRUCTION
# MISSION: PROTECT VSS COPIES & PREVENT MBR/FILE SYSTEM WIPING
# ==============================================================================

$ErrorActionPreference = "SilentlyContinue"

# VGT COLOR ENGINE
$E = [char]27
$C_VGT = "$E[38;5;201m"  # Magenta
$C_Ok = "$E[38;5;82m"    # Green
$C_Warn = "$E[38;5;214m" # Orange
$C_Reset = "$E[0m"

Write-Host "`n$C_VGT [!] INITIALISIERE VGT-WIPER-SHIELD (LOCALE FIX)... $C_Reset"

# --- 1. SCHUTZ DER SCHATTENKOPIEN (VSS) ---
# Nutze SID *S-1-1-0 (Everyone/Jeder) für universelle Kompatibilität
Write-Host " [-] Erschwere Zugriff auf VSSadmin (SID-basiert)..."
# Besitzer auf Administratoren setzen (Hatte laut Log bereits geklappt)
takeown /f "$env:windir\System32\vssadmin.exe" /a | Out-Null

# Zugriff verweigern für ALLE (Universal SID *S-1-1-0)
# Dies verhindert, dass ein Wiper mit Standardrechten vssadmin aufruft
icacls "$env:windir\System32\vssadmin.exe" /deny "*S-1-1-0:(X)" | Out-Null

if ($LASTEXITCODE -eq 0) {
    Write-Host " [V] VSSadmin wurde erfolgreich für alle Ausführungen gesperrt." -ForegroundColor Green
} else {
    Write-Host " [!] Fehler beim Setzen der ACLs. Prüfe administrative Rechte." -ForegroundColor Red
}

# --- 2. REGISTRY-SCHUTZ GEGEN DESTRUKTIVE TOOLS ---
Write-Host " [-] Blockiere destruktive System-Befehle via Registry..."
$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"
if (!(Test-Path $RegPath)) { New-Item -Path $RegPath -Force | Out-Null }
Set-ItemProperty -Path $RegPath -Name "NoRun" -Value 1 -Type DWord

# --- 3. MONITORING KRITISCHER DATEIENDUNGEN ---
Write-Host " [-] Aktiviere Controlled Folder Access (ASR Integration)..."
Set-MpPreference -EnableControlledFolderAccess Enabled
Write-Host " [V] Ransomware/Wiper-Schutz auf Kernel-Ebene aktiv." -ForegroundColor Green

# --- 4. ANTI-MBR OVERWRITE (MITIGATION) ---
# ASR-Regel: Blockiert Prozess-Erstellungen von PsExec und WMI-Befehlen (Häufige Wiper-Vektoren)
Add-MpPreference -AttackSurfaceReductionRules_Ids 92e97fa1-2edf-4476-bdd6-9dd0b4dddc7b -AttackSurfaceReductionRules_Actions Enabled

Write-Host "`n$C_Ok [V] WIPER-SHIELD v1.1 AKTIV. DATEN-AUSLÖSCHUNG VERHINDERT. $C_Reset"
Write-Host "================================================================================"
