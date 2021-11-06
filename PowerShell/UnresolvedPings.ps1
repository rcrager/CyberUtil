write-host -ForegroundColor green "SCRIPT TO DETERMINE WHICH PCs ARE OFFLINE IN AD."
Get-ADComputer -Filter * | ForEach-Object {
 if(-not(Test-Connection -CN $_.dnshostname -Count 1 -Quiet)){
write-host -ForegroundColor red $_.name
}
}