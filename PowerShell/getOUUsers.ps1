# Script to show the numer of users within an OU (enabled, disabled, and/or all)

param (
    [switch]$showEnabled,
    [switch]$showDisabled
)

function getOUUsers{
    $getOUSpec | ForEach-Object {
        if($_.enabled){
            $userEnabled.Add($_.name) > $null
        }else{
            $userDisabled.Add($_.name) > $null
        }
    }
    Write-Host -ForegroundColor Green "Report for: " $OUStr;
    Write-Host "Number of Total Users in OU: " $getOUSpec.count
    Write-Host "Number of Enabled Users in OU: " $userEnabled.Count
    Write-Host "Number of Disabled Users in OU: " $userDisabled.Count
}

function showEnabled(){
    Write-host -ForegroundColor Yellow "--------------- Users Enabled in the OU ---------------"
    Write-host -ForegroundColor Yellow "---------------  " $userEnabled.Count "  TOTAL ---------------"
    return $userEnabled
}
function showDisabled(){
    Write-host -ForegroundColor Yellow "--------------- Users Disabled in the OU ---------------"
    Write-host -ForegroundColor Yellow "---------------  " $userDisabled.Count "  TOTAL ---------------"
    return $userDisabled
}


#----------------------BEGIN MAIN---------------------------
Write-Host "Get Number of Users within an OU."

$OUStr = Read-Host "Enter the full OU String (ex. `"ou=testusers, ou=UsersOU, dc=company, dc=com`")"
$getOUSpec = Get-ADUser -filter * -SearchBase $OUStr

$userEnabled = New-Object -TypeName "System.Collections.ArrayList"
$userDisabled = New-Object -TypeName "System.Collections.ArrayList"

getOUUsers
if($showEnabled){
    showEnabled
    Write-Host "--------------------------------------------------"
}
if($showDisabled){
    showDisabled
    Write-Host "--------------------------------------------------"
}
