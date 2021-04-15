### GLOBAL VARIABLE DEFINITIONS ##################

$TMDBApiKey_v3 = #INSERT_YOUR_TMDB_v3_API_KEY_HERE
$TMDBBaseUri = "https://api.themoviedb.org/3/";


### FUNCTION DEFINITIONS #########################

# Parameters: Nothing
# Returns:    Current working directory [string]
# Function:   Get path of folder where episodes to rename are located

function Get-Directory {
    Write-Host "Default directory: " $DefaultDirectory;
    $Directory = Read-Host -Prompt "Enter your TV show's full folder pathname:";
    return $Directory;
}


# Parameters: -ShowDirectory
# Returns:    Name of TV show in $ShowDirectory [string]
# Function:   Extract the name of the TV show for API calls

function Get-ShowName{
    Param ([string] $ShowDirectory)
    return Split-Path $ShowDirectory -Leaf;
}


# Parameters: -FileName, -ShowName
# Returns:    ID of TV show in $ShowDirectory [string], retrieved from TMDB
# Function:   Get ID of TV show in TMDB for future API calls

function Get-ShowId([string] $FileName, [string]$ShowName) {
    $CallUri = $TMDBBaseUri + "search/tv?query=" + $ShowName + "&api_key=" + $TMDBApiKey_v3;
    $Response = Invoke-RestMethod -Method Get -Uri $CallUri;
    $ShowId = $Response.results[0].id;
    return $ShowId;
}


# Parameters: -FileName, -ShowId, -SeasonNo, -EpisodeNo
# Returns:    Nothing
# Function:   Rename one file ( $FileName )

function Renameulate([string] $FileName, [string]$ShowId, [int]$SeasonNo, [int]$EpisodeNo) {
    $CallUri = $TMDBBaseUri + "/tv/" + $ShowId + "/season/" + $SeasonNo + "/episode/" + $EpisodeNo + "?api_key=" + $TMDBApiKey_v3;
    $Response = Invoke-RestMethod -Method Get -Uri $CallUri;
    $EpisodeName = $Response.name
    $FileExtension = $FileName.Split("\")
    $FileExtension = $FileExtension[$FileExtension.Length - 1]
    $FileExtension = $FileExtension.Split(".")
    $FileExtension = "." + $FileExtension[$FileExtension.Length - 1]
    if ([int]$SeasonNo -le 10) {$SeasonPreface = "S0"} else {$SeasonPreface = "S"}
    if ([int]$EpisodeNo -le 10) {$EpisodePreface = "E0"} else {$EpisodePreface = "E"}
    $NewFileName = ($SeasonPreface + $SeasonNo + $EpisodePreface + $EpisodeNo + " - " + $EpisodeName + $FileExtension)
    Rename-Item $FileName $NewFileName
    Write-Host $FileName "renamed to" ($EpisodeName + $FileExtension) -ForegroundColor Green
}

# Parameters: -WorkingDirectory, -Show
# Returns:    Nothing
# Function:   Cycle through directory, pass each file to Renameulate function

function Renameulate-All([string]$WorkingDirectory, [string]$ShowId) {
    $CurrentSeason = 1
    $CurrentEpisode = 1
    # (Wrap below statement in loop - loop through all files in working directory)
    Get-ChildItem -Path $WorkingDirectory |
    ForEach-Object {
        Get-ChildItem -Path $_.FullName |
        ForEach-Object {
            Renameulate -FileName $_.FullName -ShowId $ShowId -SeasonNo $CurrentSeason.ToString() -EpisodeNo $CurrentEpisode.ToString()
            $CurrentEpisode = $CurrentEpisode + 1
        }
        $CurrentSeason = $CurrentSeason + 1;
    }

    
}


### MAIN EXECUTION #################################

$CurrentDirectory = Get-Directory;

$ShowName = Get-ShowName -ShowDirectory $CurrentDirectory;

$CurrentShowId = Get-ShowId -ShowName $ShowName

Renameulate-All -WorkingDirectory $CurrentDirectory -Show $CurrentShowId;