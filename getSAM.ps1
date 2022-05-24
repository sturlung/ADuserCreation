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



