### Script to Check if SMB V1.0 Protocol is enabled on any AD Computer.

### Check (via ciminstance) whether SMB 1 is enabled
#### Check the InstallState parameter (uint32-value)
#### 	Enabled (1)
####	Disabled (2)
####	Absent (3)
####	Unknown (4)

write-host -ForegroundColor green "Script to Check if SMB V1.0 Protocol is enabled on any AD Computer."

### Build the table
$Table = @()

Get-ADComputer -Filter * | ForEach-Object {


	### RESULTS:: the scripts is taking a while to execute because each ping takes >5 secs.
$PCSMB = Get-WmiObject -ComputerName $_.Name -query "select * from Win32_OptionalFeature where name = 'SMB1Protocol'"
	if(-not($PCSMB.InstallState -eq 2)){
		$Row = "" | Select-Object Name, Service, Enabled, "Enabled(Num)"
		$Row.Name = $_.name
		$Row.Service = $PCSMB.name
		$Row."Enabled(Num)" = $PCSMB.InstallState
		if($PCSMB.InstallState -eq 1){
			$Row.Enabled = "YES"
		}elseif ($PCSMB.InstallState -eq 4) {
			$Row.Enabled = "Unknown"
		}elseif ($PCSMB.InstallState -eq 3) {
			$Row.Enabled = "Absent"
		}
		$Table += $Row
		#Write-Host "Row added to table for pc: " $_.Name
	}
}

if(-not $Table){
	Write-Host -ForegroundColor Green "There are no computers in the domain that have SMB V1 Protocol Currently Enabled."
}
$Table | Sort-Object "Enabled(Num)", Name