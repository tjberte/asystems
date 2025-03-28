function ipinfo {
$network = Get-WmiObject Win32_NetworkAdapterConfiguration -EA Stop | Where-Object { $_.IPEnabled }

# Format the output
$ipAddresses = $network.IPAddress -join ", "
$gateway = $network.DefaultIPGateway -join ", "
# Display IPv4 information
Write-Host "IPv4 Information:"
Write-Host "------------------"
Write-Host "Adapter:          $($network.Description)"  -BackgroundColor DarkBlue -ForegroundColor White
Write-Host "Hostname:         $($network.DNSHostName)" -BackgroundColor Green -ForegroundColor White
Write-Host "Domain  :         $($network.DNSDomainSuffixSearchOrder)"  -BackgroundColor White -ForegroundColor Black
Write-Host "IP Address:       $($ipAddresses)" -BackgroundColor Yellow -ForegroundColor Black
Write-Host "MAC Address:      $($network.MACAddress)"
Write-Host "Default Gateway:  $($gateway)" -BackgroundColor Yellow -ForegroundColor Black
Write-Host "DHCP Enabled:     $($network.DHCPEnablede)"
Write-Host "DHCP Server:      $($network.DHCPServer)"
Write-Host "DHCP Obtained:    $($network.DHCPLeaseObtained)"
Write-Host "DHCP Expired:     $($network.DHCPLeaseExpires)"
Write-Host "Subnet Mask:      $($network.IPSubnet[0])"
Write-Host "DNS Servers:      $($network.DNSServerSearchOrder -join ', ')"


}

function ipinfog {
# Add the PresentationFramework assembly
Add-Type -AssemblyName PresentationFramework

# Get network adapter configuration
$network = Get-WmiObject Win32_NetworkAdapterConfiguration -EA Stop | Where-Object { $_.IPEnabled }

# Format the output
$ipAddresses = $network.IPAddress -join ", "
$gateway = $network.DefaultIPGateway -join ", "

# Create a custom message box
[System.Windows.MessageBox]::Show(
    "IPv4 Information:`n" +
    "------------------`n" +
    "Adapter: $($network.Description)`n" +
    "Hostname: $($network.DNSHostName)`n" +
    "Domain: $($network.DNSDomainSuffixSearchOrder)`n" +
    "IP Address: $($ipAddresses[0])`n" +
    "MAC Address: $($network.MACAddress)`n" +
    "Default Gateway: $($gateway)`n" +
    "DHCP Enabled: $($network.DHCPEnabled)`n" +
    "DHCP Server: $($network.DHCPServer)`n" +
    "DHCP Obtained: $($network.DHCPLeaseObtained)`n" +
    "DHCP Expired: $($network.DHCPLeaseExpires)`n" +
    "Subnet Mask: $($network.IPSubnet[0])`n" +
    "DNS Servers: $($network.DNSServerSearchOrder -join ', ')",
    "IPv4 Information",
    "OK",
    "Information"
)

}

function pingtest {
$network = Get-WmiObject Win32_NetworkAdapterConfiguration -EA Stop | Where-Object { $_.IPEnabled }

# Format the output
$gateway = $network.DefaultIPGateway
$idns = $network.DNSServerSearchOrder
$edns = "1.1.1.1"

$computers = "$gateway", "$idns", "$edns"
test-connection $computers -Count 4 | Select-Object Address, ResponseTime, BufferSize


}

function Write-Color([String[]]$Text, [ConsoleColor[]]$Color) {
    for ($i = 0; $i -lt $Text.Length; $i++) {
        Write-Host $Text[$i] -Foreground $Color[$i] -NoNewLine
    }
    Write-Host
}

function adql {
# Ensure Active Directory module is imported
Import-Module ActiveDirectory

# Retrieve AD Users with detailed account status
Get-ADUser -Filter * -Properties Name, Enabled, LockedOut, AccountExpirationDate | 
Select-Object SamAccountName, Name, 
    @{Name='AccountStatus';Expression={
        switch ($true) {
            ($_.Enabled -eq $false) { 'Disabled' }
            ($_.LockedOut -eq $true) { 'Locked Out' }
            (($_.AccountExpirationDate) -and ($_.AccountExpirationDate -lt (Get-Date))) { 'Expired' }
            (($_.Enabled -eq $true) -and ($_.LockedOut -eq $false)) { 'Active' }
            default { 'Unknown Status' }
        }
    }} | 
Sort-Object Name | 
Format-Table -AutoSize
}
