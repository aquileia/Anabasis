:: po.cmd : Generate the pot and po files for the specified domain

:: preamble: don't spam stdout with commands, append to files
@echo off
setlocal enabledelayedexpansion

:: gettext dependency
where msginit >nul 2>nul
if not !ERRORLEVEL!==0 (
	echo gettext tools not found in PATH variable
	echo get them from e.g.
	echo https://github.com/vslavik/gettext-tools-windows
	exit
)

:: my personal setup for the campaign Anabasis
set domain=wesnoth-Anabasis
set languages=de,fr
set gettext_path=C:/GitHub/wesnoth/utils/wmlxgettext

if not "%1"=="" set domain=%1
for /f %%G in ('dir /b /s *.cfg') do set files=!files! %%G
for /f %%G in ('dir /b /s *.lua') do set files=!files! %%G

if not exist po/%domain%/ mkdir po/%domain%
perl %gettext_path% --domain=%domain% %files% > po/%domain%/%domain%.pot
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
