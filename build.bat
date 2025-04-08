@echo off

@echo off
setlocal enabledelayedexpansion

:: Configuration
set "TARGET_DIR=%AEROSIM_OMNIVERSE_ROOT%\source\extensions"
set "AEROSIM_EXTENSION=aerosim.omniverse.extension"
set "CESIUM_FOLDER1=cesium.omniverse"
set "CESIUM_FOLDER2=cesium.usd.plugins"
set "ZIP_URL=https://github.com/CesiumGS/cesium-omniverse/releases/download/v0.24.0/CesiumGS-cesium-omniverse-windows-x86_64-v0.24.0.zip"
set "ZIP_FILE=%TARGET_DIR%\cesium_omniverse.zip"
set "EXTRACT_PATH=%TARGET_DIR%"

:: Check if the folders exist
if exist "%TARGET_DIR%\%CESIUM_FOLDER1%" (
    echo Folder %CESIUM_FOLDER1% already exists. No need to download.
    goto :end
)

if exist "%TARGET_DIR%\%CESIUM_FOLDER2%" (
    echo Folder %CESIUM_FOLDER2% already exists. No need to download.
    goto :end
)

:: Download the ZIP file if the folders don't exist
echo Downloading Cesium Omniverse file...
powershell -Command "(New-Object Net.WebClient).DownloadFile('%ZIP_URL%', '%ZIP_FILE%')"

:: Check if the download was successful
if exist "%ZIP_FILE%" (
    echo File downloaded successfully.

    :: Extract the ZIP file
    echo Extracting the file to %EXTRACT_PATH%...
    powershell -Command "Expand-Archive -Path '%ZIP_FILE%' -DestinationPath '%EXTRACT_PATH%' -Force"

    :: Check if extraction was successful
    if exist "%EXTRACT_PATH%\%CESIUM_FOLDER1%" (
        echo Extraction completed successfully.
    ) else (
        echo Error: The folder %CESIUM_FOLDER1% was not found after extraction.
    )

    echo repo_build.prebuild_link { "mdl", ext.target_dir.."/mdl" } >> "%TARGET_DIR%\%CESIUM_FOLDER1%\premake5.lua"
    echo repo_build.prebuild_link { "vendor", ext.target_dir.."/vendor" } >> "%TARGET_DIR%\%CESIUM_FOLDER1%\premake5.lua"

    :: Delete the ZIP file after extraction
    del "%ZIP_FILE%"
    echo ZIP file deleted.
) else (
    echo Error: The file could not be downloaded.
)

:end

echo AEROSIM_WORLD_LINK_LIB is set to: %AEROSIM_WORLD_LINK_LIB%
echo %AEROSIM_WORLD_LINK_LIB%>"%TARGET_DIR%\%AEROSIM_EXTENSION%\aerosim_world_link_lib_path.txt"

call "%~dp0repo" build %*
