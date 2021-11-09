# Script to get AD computer details for a specific list of computers (from a file).


param (
    [string]$Path = "New Text Document.txt",
    [string]$ComputerName = ""
)
$Computers = @()
if($ComputerName -eq ""){
    $Computers = try{
        Get-Content $path
    } catch {
        Write-Error -Message "File path not found, verify path directory." -ErrorAction Stop
    }
} else{
    $Computers = @($ComputerName)
}
foreach ($item in $Computers){
    Get-ADComputer $item -Properties Name, lastlogondate, operatingsystem, operatingsystemversion |
    Select-Object Name, LastLogonDate, OperatingSystem, OperatingSystemVersion, @{Name="LastUserLogon";Expression={
        if(!$_.LastLogonDate -lt (Get-Date).AddDays(-30)){
            try {
                (Get-WmiObject -Class win32_process -ComputerName $_.Name | Where-Object name -Match explorer).getowner().user
            }
            catch {
                Write-Output "PC Offline or Timeout." 
            }
        } else{
            Write-Output "Logon > 30 Days Ago."
        }
    }} | Sort-Object Lastlogondate
}