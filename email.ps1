function Email ($given,$surname) {

$email = $given + $surname + "@sportsport.dk"

$isThere = get-aduser -Filter {EmailAddress -like $email}

$n=1

    while ($isThere -ne $null) {

    [string]$email = $name + $n + "@sportsport.dk"
    $isThere = get-aduser -Filter "EmailAddress -like $email"
    $n++

    }

return $email
}
