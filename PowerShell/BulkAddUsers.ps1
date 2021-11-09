# AS OF 8/9/21 - SCRIPT IS NOT OPERATIONAL
# IS CREATING A NEW USER UNDER '/' BUT GIVING THE CORRECT EMAIL AND LOGON NAMES

$UserList = Import-Csv C:\Users\rcrager\Downloads\users.csv

foreach ($User in $UserList){

    $username = $User.Username
    $password = $User.password
    $first = $User.firstname
    $last = $User.lastname
    $OU = $User.OU

    if(Get-ADUser -F {SamAccountName -eq $Username}){
        #User account already exists
        Write-warning "User account ($Username) already exists!"
    }
    else{
        # Create user account
        New-ADUser -UserPrincipalName "$username@dustfree.local" -SamAccountName "$username" -Path "$OU" -Name "$first $last" -GivenName $first -Surname $last -DisplayName "$first $last" -AccountPassword (ConvertTo-SecureString $password -AsPlainText -Force) -PasswordNeverExpires $True -Enabled $True
        Write-Output "User $Username successfully created!"
    }
}