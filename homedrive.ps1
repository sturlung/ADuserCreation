function homedrive ($sam) {

<#$group = Get-ADGroup CompanyUsersGroup
Add-ADGroupMember -Identity $group -Members $user /#>


$path = "\\wserver2012\HomeDirectories\" + $sam
$user = Get-ADUser $sam
$letter = "N:"

$group = Get-ADGroup CompanyUsersGroup                 #dodawanie dostępu typu Read do folderu HomeDirectories; grupa stworzona wcześniej
Add-ADGroupMember -Identity $group -Members $user

Set-ADUser $user -HomeDrive $letter -HomeDirectory $path
$home = New-Item -Path $path -ItemType directory -Force

$FileSystemRights = [System.Security.AccessControl.FileSystemRights]::Modify
$AccessControlType = [System.Security.AccessControl.AccessControlType]::Allow
$InheritanceFlags = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
$PropagationFlags = [System.Security.AccessControl.PropagationFlags]::InheritOnly

$access = New-Object System.Security.AccessControl.FileSystemAccessRule ($user.SID, $FileSystemRights, $AccessControlType, $InheritanceFlags, $PropagationFlags)
$acl = Get-Acl $home

$acl.AddAccessRule($access)
Set-Acl -Path $home -AclObject $acl
}