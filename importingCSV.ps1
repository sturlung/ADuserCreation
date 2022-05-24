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

$a = importingcsv