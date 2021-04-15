# Renameulator_PS
PowerShell script for renaming TV media files using The Movie Database (TMDB) API.

The script assumes your files are nested in the following manner:
    
    /TVShow
      /Season 1
        <Season 1 files>
      /Season 2
        <Season 2 files>
        
Every episode must be in a folder whose name gives the season number (i.e. "Season 1").
Every season folder must be in a folder whose name gives the show's name (e.g. "Game of Thrones").

The script will ask for the directory of your TV show. Enter the directory of the show only, not including any "season" folders.
  Example input: "C:\Users\user\Videos\TV Shows\Game of Thrones"


TODO: Add error checking
