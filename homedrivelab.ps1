

<#$group = Get-ADGroup CompanyUsersGroup
Add-ADGroupMember -Identity $group -Members $user /#>


$path = "\\wserver2012\HomeDirectories\" + $sam
$user = Get-ADUser $sam
$letter = "N:"

$group = Get-ADGroup CompanyUsersGroup                 #dodawanie dostępu typu Read do folderu HomeDirectories; grupa stworzona wcześniej
Add-ADGroupMember -Identity $group -Members $user

Set-ADUser $user -HomeDrive $letter -HomeDirectory $path

if (Test-Path $path) {Rename-Item $path "$path.Old"}
$homedrive = New-Item -Path $path -ItemType directory -Force

$FileSystemRights = [System.Security.AccessControl.FileSystemRights]::Modify
$AccessControlType = [System.Security.AccessControl.AccessControlType]::Allow
$InheritanceFlags = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
$PropagationFlags = [System.Security.AccessControl.PropagationFlags]::None

$access = New-Object System.Security.AccessControl.FileSystemAccessRule ($user.SID, $FileSystemRights, $InheritanceFlags, $PropagationFlags, $AccessControlType)


$acl = Get-Acl $homedrive

$acl.AddAccessRule($access)

$objUser = New-Object System.Security.Principal.NTAccount("Laboratory", $sam)

$acl.SetOwner($objUser)

Set-Acl -Path $path -AclObject $acl


