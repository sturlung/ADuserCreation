Add-Content -Path C:\Users\zygfr\OneDrive\Pulpit\test.csv -Value "first,last"

#[pscustomobject]$testowi = @{

#first = "stefan"

#last = "Gromeyko"

#}

#$testowi | Export-Csv -Path C:\Users\zygfr\OneDrive\Pulpit\test.csv -Delimiter "," -Append -Force

$a="tet"
$b="qwert"
$c="asd"
$d="ghj"


$testowi = @("$a,$b"
"$c,$d")

$testowi.Add("'ert','tyu'")

$testowi | foreach {Add-Content -Path C:\Users\zygfr\OneDrive\Pulpit\test.csv -Value $_}