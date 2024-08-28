param (
    [string]$inputFile
)

$content = Get-Content $inputFile

$wordMatches = $content | Select-String -Pattern '(?<=Unknown word \()\w+(?=\))' -AllMatches

$words = $wordMatches | ForEach-Object { $_.Matches.Value }

$uniqueWords = $words | Sort-Object | Get-Unique

$uniqueWords