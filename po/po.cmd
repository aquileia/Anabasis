:: po.cmd : Generate the pot and po files for the specified domain

:: preamble: don't spam stdout with commands, append to files
@echo off
setlocal enabledelayedexpansion

:: my personal setup for the campaign Anabasis
set domain=wesnoth-Anabasis
set languages=de,fr
set WMLgettext=C:/GitHub/wesnoth/utils/wmlxgettext

Call :dependencies
set dependency_check=!ERRORLEVEL!
if  dependency_check==1 exit 1

if not "%1"=="" set domain=%1
for /f %%G in ('dir /b /s *.cfg') do set files=!files! %%G
for /f %%G in ('dir /b /s *.lua') do set files=!files! %%G

if not exist po/%domain%/ mkdir po/%domain%
perl %WMLgettext% --domain=%domain% %files% > po/%domain%/%domain%.pot
if  dependency_check==2 exit 2
cd po/%domain%
for %%G in (%languages%) do (
	if not exist %%G.po (
		msginit --no-translator --input=%domain%.pot --output-file=%%G.po --locale=%%G
	) else (
		msgmerge --backup=none --previous -U %%G.po %domain%.pot
		if not exist ../../translations/%%G/LC_MESSAGES/ mkdir ../../translations/%%G/LC_MESSAGES
		msgfmt %%G.po --output-file=../../translations/%%G/LC_MESSAGES/%domain%.mo
	)
)
exit 0



:dependencies
	set result=0

	:: gettext dependency
	where msginit >nul 2>nul
	if not !ERRORLEVEL!==0 (
		echo gettext tools not found in PATH variable, only creating .pot file
		echo Either download gettext from
		echo https://github.com/vslavik/gettext-tools-windows/releases
		echo "or use e.g. PoEdit to generate .po & .mo files"
		set result=2
	)

	:: perl dependency
	where perl >nul 2>nul
	if not !ERRORLEVEL!==0 (
		echo Perl not found in PATH variable, download from
		echo https://www.perl.org/get.html#win32
		set result=1
	)

	:: wmlxgettext dependency
	if not exist %WMLgettext% (
		echo wmlxgettext not found at %WMLgettext%, download from
		echo https://github.com/wesnoth/wesnoth/blob/master/utils/wmlxgettext
		echo "(right click 'Raw' button, save link as)"
		set result=1
	)

	if not %result%==0 pause
exit /B %result%
