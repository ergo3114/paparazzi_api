<#
.Synopsis
   Gets all inventory from Paparazzi Accessories
.DESCRIPTION
   Queries the API to get all inventory from Paparazzi Accessories and saves it to a csv file
.EXAMPLE
   Get-PAInventory
.OUTPUTS
   .csv file
.NOTES
   You will have to log in to expand the capabilities of the api.
#>
[cmdletbinding()]
Param(
    # The output file that hold the results of this function; should be a csv
    [string]$Filename = "$($env:temp)\$(Get-Date -UFormat %Y-%m-%d_%H%M%S)_PaparazziAccessories_Products.csv",
    # The paparazzi url that shows the products
    [string]$URL = "https://paparazziaccessories.com/api/products/?page_size=5000",
    # The username for paparazzi
    [string]$Username = "username",
    # The password for the account
    [string]$Pass = "password"
)
BEGIN{
    $Logfile = "$($env:temp)\LittlejohnAutomation_Paparazzi_log.txt"
    Start-Transcript -Path $Logfile -IncludeInvocationHeader -Force
    Write-Verbose "[$(Get-Date)] $($MyInvocation.MyCommand) has started"
    Write-Verbose "$($MyInvocation.InvocationName)"
    
    Write-Verbose "Setting up variables"
    $array = New-Object System.Collections.ArrayList
    $flag = $true
    
    Write-Verbose "Setting up basic auth"
    $pair = "${Username}:${pass}"
    $bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
    $base64 = [System.Convert]::ToBase64String($bytes)
    $basicAuthValue = "Basic $base64"
    $headers = @{ Authorization = $basicAuthValue }

    Write-Verbose "Attempting to make a REST call"
    try{
        $apiresults = Invoke-RestMethod -Headers $headers -Uri $url -ErrorAction Stop
    } catch{
        Write-Verbose "An error occurred when trying to call REST method"
        Write-Error -Message $PSItem -RecommendedAction "Find the logs here: $Logfile"
        Write-Verbose "[$(Get-Date)] $($MyInvocation.MyCommand) has completed with errors"
        Stop-Transcript -ErrorAction SilentlyContinue
        $flag = $false
        return
    }
    Write-Verbose "Saving results to an array"
    $results = $apiresults.results
}
PROCESS{
    Write-Verbose "Processing $($results.count) records..."
    foreach($result in $results){
        $obj = [pscustomobject]@{
            Item_Number = $result.remote_id
            Name = $result.name
            Description = $result.description
            Retail_Price = $result.prices.null
            Wholesale_Price = $result.prices.wholesale
            Image = $result.image
            Volume = $result.volume
            Link = $result.full_link
            Date_Added = $result.date_added
            Release_Date = $result.release_date
        }
        [void]$array.Add($obj)
        if(!(Test-Path -Path "$($env:temp)\Paparazzi")){
            New-Item -ItemType Directory -Path "$($env:temp)\Paparazzi"
        }
        foreach($image in $result.images[0]){
            
        }
    }
}
END{
    if($flag){
        $array | Export-Csv $Filename -Force -NoTypeInformation
        Write-Verbose "[$(Get-Date)] $($MyInvocation.MyCommand) has completed"
        Stop-Transcript -ErrorAction SilentlyContinue
    }
}