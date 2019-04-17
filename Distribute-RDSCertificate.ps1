# Get all Farm Session Hosts
$sessionHostArr = Get-RDSessionCollection -ConnectionBroker rds-cb1.rds.lab | Get-RDSessionHost

foreach ($sessionHost in $sessionHostArr) {
    $serverName = $sessionHost.SessionHost
    Write-Verbose "Current Object is: $($sessionHost.SessionHost)"
    # Test on SMB Protocol
    if (-not (Test-NetConnection -ComputerName $serverName -Port 445)) {
        # Test if target is online
        if (-not (Test-WSMan $serverName)) {
            Write-Warning "Connectivity Check failed for: $serverName"
            continue
        }
        else {
            # Remotely enable SMB Firewall Rules
            Invoke-Command -ComputerName $serverName -ScriptBlock {
                Enable-NetFirewallRule -DisplayGroup "File and Printer Sharing"
            }
        }
    }
    Copy-Item C:\cb.pfx -Destination "\\$serverName\c$\cb.pfx"
    Invoke-Command -ComputerName $serverName -ScriptBlock {
        $securePassword = ConvertTo-SecureString -AsPlainText -Force "Passw0rd"
        Import-PfxCertificate -Exportable -CertStoreLocation Cert:\LocalMachine\My `
            -FilePath C:\cb.pfx -Password $securePassword
    }
}
