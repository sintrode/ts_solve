::------------------------------------------------------------------------------
:: NAME
::     ts_solve.bat
::
:: DESCRIPTION
::     Makes recommendations for Typeshift core words as listed in puzzmo.com
::
:: AUTHOR
::     sintrode
::
:: NOTES
::     Originally used /usr/share/dict/words/american-english as created by
::     the SCOWL list by Kevin Atkinson. Currently uses the 2of12inf list from
::     12dicts by Alan Beale. 2to12inf.txt is derived from AGID by Kevin
::     Atkinson. See agid.txt for more details.
::
:: REQUIREMENTS
::     NOTE: curl and tar are both preinstalled on Windows 10 and later
::     curl         (https://curl.se/)
::     tar          (https://gnuwin32.sourceforge.net/packages/gtar.htm)
::     2of12inf.txt (http://wordlist.aspell.net/12dicts/)
::------------------------------------------------------------------------------
:: List the columns of the Typeshift puzzle, separated by spaces. For example:
::
::           U
::          PO I
::          LAPOS
::          MREEL
::          F V R
::            Y
:: becomes
::          ts_solve.bat plmf uoar pevy ioe slr
::------------------------------------------------------------------------------

@echo off
setlocal enabledelayedexpansion

if "%~1"=="" goto :usage
call :validateDictionary || goto :fatalError

set "search_string=^[%*]$"
set "search_string=!search_string: =][!"

findstr /r /c:"!search_string!" 2of12inf.txt
exit /b

::------------------------------------------------------------------------------
:: Confirms that the required dictionary is present and downloads it if not
::
:: Arguments: None
:: Returns:   0 if the list was downloaded and extracted properly, 1 otherwise
::------------------------------------------------------------------------------
:validateDictionary
set "wordlist=2of12inf.txt"
set "legal=agid.txt"

if not exist "%wordlist%" (
    <nul set /p ".=%wordlist% not found. Downloading..."
    curl -sLO "http://downloads.sourceforge.net/wordlist/12dicts-6.0.2.zip"
    if not exist 12dicts-6.0.2.zip exit /b 1

    REM tar is *supposed* to create the target directory when extracting, but
    REM it doesn't for some reason, so create the folder, move the file, and
    REM delete the folder again
    md American
    >nul 2>&1 tar -xvf 12dicts-6.0.2.zip American/2of12inf.txt
    >nul 2>&1 move American\2of12inf.txt . 
    rd American
    if not exist "%wordlist%" exit /b 1

    REM This has to be here for legal reasons
    >nul 2>&1 tar -xvf 12dicts-6.0.2.zip agid.txt

    del 12dicts-6.0.2.zip
    echo DONE
)
exit /b 0

::------------------------------------------------------------------------------
:: Displays the usage text for the script
::
:: Arguments: None
:: Returns:   None
::------------------------------------------------------------------------------
:usage
echo USAGE: %~nx0 ^<puzzle columns separated by spaces^>
exit /b

::------------------------------------------------------------------------------
:: If you're seeing this error message, there was an issue getting the wordlist
::
:: Arguments: None
:: Returns:   None
::------------------------------------------------------------------------------
echo ERROR
echo There was an issue downloading and extracting the wordlist.
echo Please manually download and extract http://wordlist.aspell.net/12dicts/
exit /b