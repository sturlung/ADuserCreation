Add-Type -AssemblyName System.Windows.Forms

cd C:\Users\Administrator\Desktop\projectfiles

function Email ($given,$surname) {

$email = "$given$surname@sportsport.dk"

$isThere = get-aduser -Filter {EmailAddress -like $email}

$n=1

    while ($isThere -ne $null) {

    $m = $n.ToString()
    $email = "$given$surname$m@sportsport.dk"
    $isThere = get-aduser -Filter {EmailAddress -like $email}
    $n++

    }

return $email
}

function getSAM ($firstname,$surname) {

$name = "$firstname$surname"

$success = 0

$alphabet = @('q','w','e','r','t','y','u','i','o','p','a','s','d','f','g','h','j','k','l','z','x','c','v','b','n','m')

For ($i=1; $i -le 20; $i++){

$sam = ""

$length = $name.Length -1

(0..$length) | Get-Random -Count 3 | ForEach-Object {$sam += $($name[$_])}

$check = get-aduser -Filter {SamAccountName -like $sam}

if ($check -eq $null) {$success = 1; break}

}

while ($success -eq 0) {

$sam = ""

$alphabet | Get-Random -count 3 | ForEach-Object {$sam += $($name[$_])}

$check = get-aduser -Filter {SamAccountName -like $sam}

if ($check -eq $null) {$success = 1}
}

return $sam

}

function employeeID ($kraj, $mngrEmail){

    switch ($kraj){
        
        "PL" {$part1 = "PL"}
        "DK" {$part1 = "DA"}
        "EN" {$part1 = "EN"}

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

$path = "\\wserver2012\HomeDirectories\$sam"
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

$ACL.SetOwner($objUser)

Set-Acl -Path $path -AclObject $acl
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

While ($true){

$mainPath = "OU=CompanyUsers,DC=Laboratory,DC=local"

$newUsers = ImportingCSV

#$createdusers = @()
#$oneTimePasswords = @()
$today = Get-Date -Format "ddMMMyyyy"

$passpath = ".\1timePass" + $today + ".csv"
<#$csv = @"
User,OneTimePassword
"@ 
$csv | Out-File -filepath $passpath/#>

Write-Output "User,OneTimePassword" | Out-File -filepath $passpath

$logpath = ".\usersCreatedOn$today.csv"

foreach ($user in $newUsers){

$given = $user.givenname
$surname = $user.surname 
$samaccountname = getSAM $given $surname
$managerEmail = $user.manager
$manager = Get-ADUser -Filter {EmailAddress -like $managerEmail}


if ($($user.enabled) -eq "true") {
[bool]$enabled = 1}
else {[bool]$enabled = 0}

[datetime]$expirationmidnight = $user.accountexpirationdate #co jeśli nie ma expiration date
$expiration = $expirationmidnight.AddDays(1)

$phone = $user.telephonenumber
#$country = $user.country -zrób tu switcha zmieniającego na odpowiedni country code -> DONE

switch ($user){
{$($user.country) -eq "England"} {$country = "EN";break}
{$($user.country) -eq "Denmark"} {$country = "DK";break}
{$($user.country) -eq "Poland"} {$country = "PL";break}
}

$name = $given + " " + $surname
$display = $name + " - " + $samaccountname
$email = email $given $surname
$principal = $samaccountname + '@laboratory.local'
$eID = employeeID $country $managerEmail

$plainPass = passwordGenerator
$password = ConvertTo-SecureString $plainPass -AsPlainText -Force

switch ($country){
"EN" {$path = "OU=Anglia,"+$mainPath;break}
"DK" {$path = "OU=Dania,"+$mainPath;break}
"PL" {$path = "OU=Polska,"+$mainPath;break}
}

$NewUser = New-ADUser -SamAccountName $samaccountname -Name $name -UserPrincipalName $principal -EmailAddress $email -Country $country -Manager $manager -GivenName $given -Surname $surname -DisplayName $display -EmployeeID $eID -Path $Path -AccountPassword $password -ChangePasswordAtLogon $true -Enabled $enabled -PassThru
###get-aduser $sam | Set-ADUser -Country "DK"

homedrive $samaccountname

#$createdusers += $(Get-ADUser $sam -Properties manager, homedrive | select givenname,samaccountname,emailaddress,manager,homedrive)
Get-ADUser $sam -Properties manager, homedirectory | select givenname,samaccountname,emailaddress,manager,homedirectory | Export-Csv -Path $logpath -NoTypeInformation -Append

"$sam,$plainPass" | Add-Content -Path $passpath

}

Start-Sleep -Seconds 86400

}

#$logpath = ".\usersCreatedOn " + $today

#$createdusers | Export-Csv -Path $logpath -NoTypeInformation

#$passPath = ".\1timePass " + $today

#$oneTimePasswords | Export-Csv -Path $passPath 