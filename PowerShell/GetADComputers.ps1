Get-ADComputer -Filter * -Properties Name, lastlogondate, operatingsystem, operatingsystemversion |
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
}} | Sort-Object Lastlogondate | Export-Csv GetADComputers.csv
