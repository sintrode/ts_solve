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

call :columnToArray %*
call :iterateOverLargestColumns !column_max!

set "search_string="
for /L %%A in (0,1,%column_count%) do set "search_string=!search_string![!columns[%%A]!]"
findstr /r /c:"^^!search_string!$" 2of12inf.txt
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
:: Counts the number of characters in each column and stores the largest value
::
:: Arguments: %* - All column lists as given by the player
:: Returns:   None
::------------------------------------------------------------------------------
:columnToArray
set "column_count=-1"
set "column_max=0"
for %%A in (%*) do (
    set /a column_count+=1
    set "columns[!column_count!]=%%A"
    call :getLength %%A length
    set "col_lengths[!column_count!]=!length!"
    if !length! GTR !column_max! (
        set "column_max=!length!"
        set "longest_columns=!column_count!"
    ) else if !length! EQU !column_max! (
        set "longest_columns=!longest_columns! !column_count!"
    )
)
exit /b

::------------------------------------------------------------------------------
:: strLen7 by dbenham
:: Calculates the length of a string and stores that value in a variable
:: https://ss64.org/viewtopic.php?pid=6478#p6478
::
:: Arguments: %1 - The string to calculate the length of
::            %2 - The variable to store the length in
:: Returns:   None
::------------------------------------------------------------------------------
:getLength
setlocal EnableDelayedExpansion
set "s=%~1"
set "len=0"
for %%N in (4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (
	if "!s:~%%N,1!" neq "" (
		set /a "len+=%%N"
		set "s=!s:~%%N!"
	)
)
endlocal&if "%~2" neq "" (set %~2=%len%) else echo %len%
exit /b

::------------------------------------------------------------------------------
:: Iterates over the largest columns to generate regex patterns that contain
:: one character in the relevant field
::
:: Arguments: %1 - The length of the longest columns
:: Returns:   None
::------------------------------------------------------------------------------
:iterateOverLargestColumns
echo UNIQUE
echo ------
for /L %%A in (0,1,%column_count%) do (
    set /a "before_col=%%A-1", "after_col=%%A+1"
    
    for /L %%B in (0,1,%column_max%) do (
        set "iterated_pattern=["
        for /L %%C in (0,1,!before_col!) do set "iterated_pattern=!iterated_pattern!!columns[%%~C]!]["
        set "iterated_pattern=!iterated_pattern!!columns[%%A]:~%%B,1!]["
        for /L %%C in (!after_col!,1,!column_count!) do set "iterated_pattern=!iterated_pattern!!columns[%%~C]!]["
        set "iterated_pattern=^^!iterated_pattern:~0,-1!$"

        for /f %%C in ('findstr /r /c:"!iterated_pattern!" "%wordlist%" ^| find /v /c ""') do (
            if "%%C"=="1" (
                for /f %%D in ('findstr /r /c:"!iterated_pattern!" "%wordlist%"') do (
                    echo %%D
                    call :stripUniqueChars "%%D"
                )
            )
        )
    )
)

echo.
echo POSSIBLE
echo --------
exit /b

::------------------------------------------------------------------------------
:: If any unique words are found, remove any characters in that word that are
:: in the longest columns to remove duplicate or otherwise incorrect entries
::
:: Arguments: %1 - The word whose characters will be removed
:: Returns:   None
::------------------------------------------------------------------------------
:stripUniqueChars
set "temp_string=%~1"
for %%E in (%longest_columns%) do (
    for /f "delims=" %%F in ("!temp_string:~%%E,1!") do (
        set "columns[%%E]=!columns[%%E]:%%~F=!"
    )
)
exit /b

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
pause
exit /b