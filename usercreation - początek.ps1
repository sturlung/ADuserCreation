. .\email.ps1
. .\EmployeeID.ps1
. .\homedrive.ps1
. .\importingCSV.ps1
. .\passwordGenerator.ps1

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