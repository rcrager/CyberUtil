### Add parameters later for only showing reponse code (-r), display content to file (-o), etc.
### Param(
###    [# Parameter help description
###    [Parameter(AttributeValues)]
###    [string[]]
###    $ParameterName]
### )

# Script to CURL multiple URLs from a file
$file = Read-Host "Enter the filename or path to the URLs: "
$contents = Get-Content -path $file
$results = @()

if(-not($contents.Contains("https") -or $contents.Contains("http"))){
    $baseURI = read-host "Enter the base URL: "
    $c=0
    ForEach($page in $contents){
        #if (-not($baseURI.EndsWith("/") -and (-not($page.StartsWith("/"))))){$baseURI += "/"}
        try{
            $Response = Invoke-WebRequest -Uri ($baseURI+$page)
            $responseCode = $Response.StatusCode
        }catch{
            $responseCode = $_.Exception.Response.StatusCode.value_
        }
        $c = $c+1
        Write-Progress -Activity "Reaching Pages" -Status "Progress: " -PercentComplete ($c/$contents.Count*100)
        $row = "" | Select-Object "URL","Response"
        $row."URL" = $baseURI+$page
        $row."Response" = $responseCode
        $results += $row
    }
    $results
}