Add-Type -AssemblyName System.Windows.Forms

function Email ($name) {

$email = $name + "@sportsport.dk"

$isThere = get-aduser -Filter "EmailAddress -like $email"

$n=1

    while ($isThere -ne $null) {

    [string]$email = $name + $n + "@sportsport.dk"
    $isThere = get-aduser -Filter "EmailAddress -like $email"
    $n++

    }

return $email
}

function employeeID ($kraj, $mngrEmail){

    switch ($kraj){
        
        "Polska" {$part1 = "pl"}
        "Dania" {$part1 = "da"}
        "Anglia" {$part1 = "en"}

    }

    $manager = Import-Csv -Path ".\managers.csv" | where {$($_.manageremail) -like $mngrEmail}
    $part2 = $manager.managercode

    $almostThere = $part1 + $part2 + "*"
   	#$thisManagersIds = Get-ADuser -Properties EmployeeId -filter * | where {$_.employeeid -like "$almostThere*"}
    $thisManagersIds = Get-ADuser -Properties EmployeeId -filter 'employeeid -like $almostThere'
    $idSearch = 0
	
	Foreach ($managersUser in $thisManagersIds ) {
		$eID = $managersUser.EmployeeID
		[int]$placeholder = $eID[4] + $eID[5] + $eID[6]
		if ($idSearch -le $placeholder) {$idSearch = $placeholder + 1}
		}
	$part3 = $idSearch.ToString("000")

return $part1+$part2+$part3
}


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

function ImportingCSV () {

$inputcsv = New-Object windows.forms.openfiledialog   
    $inputcsv.initialDirectory = [Environment]::GetFolderPath('Desktop')   
    $inputcsv.title = "Choose input CSV file"   
    $inputcsv.filter = "CSV Files|*.CSV|All Files|*.*" 
    $inputcsv.ShowHelp = $True   
    Write-Host "Please, locate the input CSV file" -ForegroundColor Green  
    $inputcsv.ShowDialog() | Out-Null 
    $path = $inputcsv.filename
    $result = Import-Csv -Path $path -Delimiter ";"
    
return $result

}


function passwordGenerator () {

$numbers = @('1','2','3','4','5','6','7','8','9','0')
$capitals = @('Q','A','Z','E','D','C','R','F','V','T','G','B','Y','H','N','U','J','M','I','K','O','L','P','w','S','X')
$minuscules = @('q','w','e','r','t','y','u','i','o','p','a','s','d','f','g','h','j','k','l','z','x','c','v','b','n','m')

$n=0
$c=0
$m=0



while (($n -eq 0) -or ($c -eq 0) -or ($m -eq 0)) {

$password = ''

  for ($i=1; $i -le 8; $i++){

    $type = Get-Random -Minimum 1 -Maximum 4

        switch ($type){

            1 {$chara = Get-Random -Minimum 1 -Maximum 11
            $password = $password + $numbers[$chara]
            $n++}

            2 {$chara = Get-Random -Minimum 1 -Maximum 27
            $password = $password + $capitals[$chara]
            $c++}
            
            3 {$chara = Get-Random -Minimum 1 -Maximum 27
            $password = $password + $minuscules[$chara]
            $m++}

        }
    }
}

return $password

}

$mainPath = "OU=CompanyUsers,DC=Laboratory,DC=local"

$newUsers = ImportingCSV

$createdusers = @()
#$oneTimePasswords = @()
$today = Get-Date

$passpath = ".\1timePass + $today"
$csv = @"
User,OneTimePassword
"@ 
$csv | Out-File $passpath

foreach ($user in $newUsers){

$sam = $user.samaccountname
$given = $user.givenname
$surname = $user.surname 
$managerEmail = $user.manager

if ($($user.enabled) -eq "true") {
[bool]$enabled = 1}
else {[bool]$enabled = 0}

[datetime]$expirationmidnight = $user.accountexpirationdate
$expiration = $expirationmidnight.AddDays(1)

$phone = $user.telephonenumber
$country = $user.country

$name = $given + " " + $surname
$display = $name + " - " + $sam
$email = email $name
$principal = $sam + '@laboratory.local'
$eID = employeeID $country $managerEmail

$plainPass = passwordGenerator
$password = ConvertTo-SecureString $plainPass -AsPlainText -Force

switch ($country){
"England" {$path = "OU=Anglia"+$mainPath}
"Denmark" {$path = "OU=Dania"+$mainPath}
"Poland" {$path = "OU=Polska"+$mainPath}
}

$NewUser = New-ADUser -SamAccountName $sam -Name $name -UserPrincipalName $principal -EmailAddress $email -GivenName $given -Surname $surname -DisplayName $display -EmployeeID $eID -Path $Path -AccountPassword $password -ChangePasswordAtLogon $true -Enabled $enabled -Country $country -PassThru

homedrive $sam

$createdusers += $(Get-ADUser $sam -Properties manager, homedrive | select givenname,samaccountname,emailaddress,manager,homedrive)

"$sam,$plainPass" | Add-Content -Path $passpath

}

$logpath = ".\usersCreatedOn " + $today

$createdusers | Export-Csv -Path $logpath -NoTypeInformation

#$passPath = ".\1timePass " + $today

#$oneTimePasswords | Export-Csv -Path $passPath 