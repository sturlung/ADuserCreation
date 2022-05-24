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