Get-ADGroup -filter * -properties whenChanged, whenCreated, description | 
select Name, whenChanged, whenCreated, description | 
sort whenChanged | Export-Csv AdGroupMembers.csv;

# Get member count VV
#(Get-ADGroup MFA_Users -Properties *).Member.Count
Get-ADGroup -filter * | select Name | 
ForEach-Object{Get-ADGroupMember -Identity $_.Name |Sort Name |Select Name, @{l='OU';e={$_.distinguishedname.split(',')[1].split('=')[1]}}
|Export-Csv -path $_.Name}