:: po.cmd : Generate the pot and po files for the specified domain

:: requires the gettext tools in your PATH variable
:: e.g. from https://github.com/vslavik/gettext-tools-windows

:: preamble: don't spam stdout with commands, append to cfg_files
@echo off
setlocal enabledelayedexpansion

:: my personal setup for the campaign Anabasis
set domain=wesnoth-Anabasis
set gettext_path=C:/GitHub/wesnoth/utils/wmlxgettext

if not "%1"=="" set domain=%1
for /f %%G in ('dir /b /s *.cfg') do set files=!files! %%G
for /f %%G in ('dir /b /s *.lua') do set files=!files! %%G

if not exist po/%domain%/ mkdir po/%domain%
perl %gettext_path% --domain=%domain% %files% > po/%domain%/%domain%.pot
cd po/%domain%
for %%G in (de,fr) do (
	if not exist %%G.po (
		msginit --no-translator --input=%domain%.pot --output-file=%%G.po --locale=%%G
	) else (
		msgmerge --backup=none --previous -U %%G.po %domain%.pot
	)
)
