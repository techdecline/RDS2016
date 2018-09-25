$serverList = Get-RDServer
$serverName = $null

foreach ($serverObj in $serverList) {
    $serverName = $serverObj.Server

    Invoke-Command -ComputerName $serverName -ScriptBlock {
        Get-NetFirewallRule -DisplayGroup "File and Printer Sharing" | Enable-NetFirewallRule
    }

    Copy-Item '\\rds-dc1\c$\wildcard.pfx' -Destination "\\$serverName\c$\wildcard.pfx"
    Invoke-Command -ComputerName $serverName -ScriptBlock {
        $password = ConvertTo-SecureString -AsPlainText -Force "Passw0rd"
        Import-PfxCertificate -Exportable -Password $password -CertStoreLocation Cert:\LocalMachine\My `
            -FilePath C:\wildcard.pfx
    }
}