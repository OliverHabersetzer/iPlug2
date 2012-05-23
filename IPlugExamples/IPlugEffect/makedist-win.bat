echo off

REM - batch file to build 32&64 bit VS2010 VST/APP project and VS2005 RTAS project and zip the resulting binaries
REM - updating version numbers requires python and python path added to %PATH% env variable 
REM - zipping requires 7zip in %ProgramFiles%\7-Zip\7z.exe
REM - building installer requires innotsetup in "%ProgramFiles(x86)%\Inno Setup 5\iscc"

echo Making IPlugEffect win distribution...

echo ------------------------------------------------------------------
echo Updating version numbers...

call python update_version.py

REM - START VST2/VST3/APP VS2010

echo ------------------------------------------------------------------
echo "Building VST2/VST3/APP (VS2010)..."

if exist "%ProgramFiles(x86)%" (goto 64-Bit) else (goto 32-Bit)

:32-Bit
echo 32-Bit O/S detected
call "%ProgramFiles%\Microsoft Visual Studio 10.0\VC\vcvarsall.bat"
goto END

:64-Bit
echo 64-Bit Host O/S detected
call "%ProgramFiles(x86)%\Microsoft Visual Studio 10.0\VC\vcvarsall.bat"
goto END
:END

REM - set preprocessor macros like this, for instance to enable demo build:
REM - SET CMDLINE_DEFINES="DEMO_VERSION"

REM - Could build individual projects like this:
REM - msbuild IPlugEffect-app.vcxproj /p:configuration=release /p:platform=win32

msbuild IPlugEffect.sln /p:configuration=release /p:platform=win32 /nologo /noconsolelogger /fileLogger /v:quiet /flp:logfile=build-win.log;errorsonly 
msbuild IPlugEffect.sln /p:configuration=release /p:platform=x64 /nologo /noconsolelogger /fileLogger /v:quiet /flp:logfile=build-win.log;errorsonly;append

REM - START RTAS VS2005

echo ------------------------------------------------------------------
echo Building RTAS/AAX Plugins (VS2005)...

REM - this is bit clumsy, oh well
if exist "%ProgramFiles(x86)%" (goto 64-Bit-pt) else (goto 32-Bit-pt)

:32-Bit-pt
call "%ProgramFiles%\Microsoft Visual Studio 8\VC\vcvarsall.bat"
goto END-pt

:64-Bit-pt
call "%ProgramFiles(x86)%\Microsoft Visual Studio 8\VC\vcvarsall.bat"
goto END-pt

:END-pt

REM - seems it's not possible to print only errors with vs2005 msbuild
msbuild IPlugEffect-pt.sln /p:configuration=release /p:platform=win32 /nologo /noconsolelogger /logger:fileLogger,Microsoft.Build.Engine;LogFile=build-win.log;append /v:quiet

echo TODO: sign aax binary

REM - Make Installer (InnoSetup)

echo ------------------------------------------------------------------
echo Making Installer...

if exist "%ProgramFiles(x86)%" (goto 64-Bit-is) else (goto 32-Bit-is)

:32-Bit-is
"%ProgramFiles%\Inno Setup 5\iscc" /cc ".\installer\IPlugEffect.iss"
goto END-is

:64-Bit-is
"%ProgramFiles(x86)%\Inno Setup 5\iscc" /cc ".\installer\IPlugEffect.iss"
goto END-is

:END-is

REM - ZIP
REM - "%ProgramFiles%\7-Zip\7z.exe" a .\installer\IPlugEffect-win-32bit.zip .\build-win-app\win32\bin\IPlugEffect.exe .\build-win-vst3\win32\bin\IPlugEffect.vst3 .\build-win-vst2\win32\bin\IPlugEffect.dll .\build-win-rtas\bin\IPlugEffect.dpm .\build-win-rtas\bin\IPlugEffect.dpm.rsr .\build-win-aax\bin\IPlugEffect.aaxplugin\Contents\Win32\IPlugEffect.aaxplugin .\installer\license.rtf .\installer\readmewin.rtf
REM - "%ProgramFiles%\7-Zip\7z.exe" a .\installer\IPlugEffect-win-64bit.zip .\build-win-app\x64\bin\IPlugEffect.exe .\build-win-vst3\x64\bin\IPlugEffect.vst3 .\build-win-vst2\x64\bin\IPlugEffect.dll .\installer\license.rtf .\installer\readmewin.rtf

echo ------------------------------------------------------------------
echo Printing log file to console...

type build-win.log

pause