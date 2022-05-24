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