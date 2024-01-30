# Typeshift Solver

This script will determine the best words to use for [Typeshift](http://www.playtypeshift.com) by Zach Gage.

## Usage
Enter the columns as arguments to the script, separated by spaces. For example, the puzzle

    SGE
    ICLOS
    ALHDO
    COATA
      C

should be entered as `siac gclo elhac odt soa`.

## Prerequisites
- [curl](https://curl.se/) (Included with Windows 10 and later)
- [tar](https://gnuwin32.sourceforge.net/packages/gtar.htm) (Included with Windows 10 and later)
- [2of12inf.txt](http://wordlist.aspell.net/12dicts/)

## Legal
`2of12inf.txt` is compiled by Alan Beale.

`agid.txt` is included with the script because `2of12inf.txt` is derived from AGID by Kevin Atkinson (but is otherwise public domain), which requires the text file to be present.

`ts_solve.bat` is provided "as-is," without warranty of any kind. You are free to distribute this script as desired as long as this legal notice and `agid.txt` are included in the distribution.  
(c) 2024 by sintrode