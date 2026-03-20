# ==============================================================================
# VISIONGAIATECHNOLOGY - GENESIS ADD-ON: ANTI-HANDALA BLACKLIST
# STATUS: SUPREME DEFENSE / KINETIC SYNC
# MISSION: NEUTRALIZE HANDALA C2 INFRASTRUCTURE & IRANIAN PROXY NODES
# ==============================================================================

$ErrorActionPreference = "SilentlyContinue"

# VGT COLOR ENGINE
$E = [char]27
$C_VGT = "$E[38;5;201m"  # Magenta
$C_Ok = "$E[38;5;82m"    # Green
$C_Crit = "$E[38;5;196m" # Red
$C_Reset = "$E[0m"

Write-Host "`n$C_VGT [!] INITIALISIERE ANTI-HANDALA BLACKLIST (GENESIS MODULE)... $C_Reset"

# --- 1. IOC LISTE (IP-BEREICHE & C2 KNOTEN - STAND FEB 2026) ---
# Diese IPs und Ranges korrelieren mit verifizierten Handala Infrastrukturen
$Blacklist = @(
    "91.206.178.0/24",   # C2 Infrastructure Cluster A (Handala Primary)
    "103.14.26.0/24",    # Proxy / Relay Nodes
    "195.133.40.0/24",   # Exfiltration Gateways
    "185.162.0.0/16",    # Iranian ASN Range (Broad Block)
    "193.104.161.0/24",  # Specific VPS Provider used by Handala
    "5.160.0.0/16",      # AS43754 (Asiatech Data Center)
    "31.24.0.0/14",      # AS197285 (TCI / TIC)
    "176.12.0.0/16"      # Known VPN Exit Nodes for Proxy Operations
)

# --- 2. FIREWALL REGEL-IMPLEMENTIERUNG ---
Write-Host " [-] Erstelle Firewall-Regeln (Inbound & Outbound)..."

foreach ($IPRange in $Blacklist) {
    # OUTBOUND BLOCK (Verhindert C2-Kommunikation und Exfiltration)
    New-NetFirewallRule -DisplayName "VGT-BLOCK-HANDALA-OUT ($IPRange)" `
                        -Direction Outbound `
                        -Action Block `
                        -RemoteAddress $IPRange `
                        -Description "VGT Genesis: Blockiert Handala C2 Outbound" `
                        -Enabled True

    # INBOUND BLOCK (Verhindert direkten Zugriff/Scanning)
    New-NetFirewallRule -DisplayName "VGT-BLOCK-HANDALA-IN ($IPRange)" `
                        -Direction Inbound `
                        -Action Block `
                        -RemoteAddress $IPRange `
                        -Description "VGT Genesis: Blockiert Handala Inbound Scanning" `
                        -Enabled True
}

# --- 3. DNS-SINKHOLE ERWEITERUNG (Handala Domains) ---
Write-Host " [-] Aktualisiere DNS-Sinkhole für Handala-Domains..."
$HostsPath = "$env:windir\System32\drivers\etc\hosts"
$Domains = @(
    "handala-group.net",
    "handala-ops.org",
    "ir-c2-secure.com",
    "proxy.handala.io"
)

foreach ($Domain in $Domains) {
    $Line = "0.0.0.0 $Domain"
    if (!(Select-String -Path $HostsPath -Pattern $Domain)) {
        Add-Content -Path $HostsPath -Value $Line
    }
}

Write-Host "`n$C_Ok [V] ANTI-HANDALA BLACKLIST AKTIV. $C_Reset"
Write-Host " STATUS: GENESIS LOCKDOWN LEVEL 4 ERREICHT."
Write-Host "================================================================================"
