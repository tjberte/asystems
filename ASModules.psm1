#full code as of 04.01.2025
echo "To list out all of the available commands, type 'listcomm'"

function listcomm{

echo "ipinfo - display ip address information"
echo "ipinfog - display ip address information in gui"
echo "pingtest - runs a constant ping"
echo "adqa - list all ad accounts and status"
echo "adql - list all ad accounts locked out"

}

function ipinfo {
$network = Get-WmiObject Win32_NetworkAdapterConfiguration -EA Stop | Where-Object { $_.IPEnabled }

# Format the output
$ipAddresses = $network.IPAddress -join ", "
$gateway = $network.DefaultIPGateway -join ", "
# Display IPv4 information
Write-Host "IPv4 Information:"
Write-Host "------------------"
Write-Host "Adapter:          $($network.Description)"
Write-Host "Hostname:         $($network.DNSHostName)"
Write-Host "Domain  :         $($network.DNSDomainSuffixSearchOrder)"
Write-Host "IP Address:       $($ipAddresses)"
Write-Host "MAC Address:      $($network.MACAddress)"
Write-Host "Default Gateway:  $($gateway)"
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

function adqa {
# Ensure Active Directory module is imported
Import-Module ActiveDirectory

# Retrieve AD Users with detailed account status

 # Retrieve AD Users with detailed account status
 Get-ADUser -Filter * -Properties Name, Enabled, LockedOut, AccountExpirationDate | 
 Select-Object SamAccountName, Name, 
     @{Name='AccountStatus';Expression={
         if ($_.Enabled -eq $false) { 'Disabled' }
         elseif ($_.LockedOut -eq $true) { 'Locked Out' }
         elseif ($_.AccountExpirationDate -and $_.AccountExpirationDate -lt (Get-Date)) { 'Expired' }
         elseif ($_.Enabled -eq $true) { 'Active' }
         else { 'Unknown Status' }
     }} | 
 Sort-Object { $_.Name } | 
 Format-Table -AutoSize
}

function adql {
# Ensure Active Directory module is imported
Import-Module ActiveDirectory

# Retrieve AD Users with detailed account status

 # Retrieve AD Users with detailed account status
Search-ADAccount -LockedOut | 
Select-Object SamAccountName, Name, 
    @{Name='AccountStatus';Expression={
        if ($_.Enabled -eq $false) { 'Disabled' }
        elseif ($_.LockedOut -eq $true) { 'Locked Out' }
        elseif ($_.AccountExpirationDate -and $_.AccountExpirationDate -lt (Get-Date)) { 'Expired' }
        elseif ($_.Enabled -eq $true) { 'Active' }
        else { 'Unknown Status' }
    }} | 
Sort-Object { $_.Name } | 
Format-Table -AutoSize
}

function adqg {
    param (
        [string]$GroupName
    )

    # Ensure Active Directory module is imported
    Import-Module ActiveDirectory

    # Retrieve AD Users with detailed account status and their groups
    $users = Get-ADUser -Filter * -Properties Name, Enabled, LockedOut, AccountExpirationDate, MemberOf 

    if ($GroupName) {
        $users = $users | Where-Object { $_.MemberOf -contains (Get-ADGroup -Filter { Name -eq $GroupName }).DistinguishedName }
    }

    $users | 
    Select-Object SamAccountName, Name,
        @{Name='AccountStatus';Expression={
            if ($_.Enabled -eq $false) { 'Disabled' }
            elseif ($_.LockedOut -eq $true) { 'Locked Out' }
            elseif ($_.AccountExpirationDate -and $_.AccountExpirationDate -lt (Get-Date)) { 'Expired' }
            elseif ($_.Enabled -eq $true) { 'Active' }
            else { 'Unknown Status' }
        }},
        @{Name='Groups';Expression={[string]::join(", ", ($_.MemberOf | Get-ADGroup | Select-Object -ExpandProperty Name))}} |
    Sort-Object { $_.Name } |
    Format-Table -AutoSize
}



function unlocku {
    param (
        [string]$Name
    )

     net user $Name /active:yes
}

