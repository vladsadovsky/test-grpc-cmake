@echo on
if "%1"=="clean" goto clean
if "%1"=="info"  goto info
if "%1"=="debug" goto debug
if "%1"=="release" goto release
if "%1"=="vsdebug" goto vsdebug
if "%1"=="vsrelease" goto vsrelease
if "%1"=="sln" goto sln
if "%1"== "test" goto test
goto release

:clean
@echo Cleaning up all build artifacts, both release and debug
rd /s /q build\win
rem del *.sln *.vcxproj*
goto done

:info
@echo off
@echo Build tools invormation
@echo ==== CMAKE ====
where cmake.exe
cmake --version
@echo ... 
@echo ==== NINJA ====
where ninja
ninja --version
@echo ...
@echo ==== MS VC* ====
where cl.exe
cl 
@echo .
@echo VCPKG_ROOT=%VCPKG_ROOT%
@set VCP
goto done

:sln
@echo Generating Visual Studio solution 
rd /s /q build
mkdir build
cmake -G "Visual Studio 17 2022" -B build\win  -S . 
goto done

:vsdebug
@echo Building with msbuild -- Debug
msbuild build\win\galacell.sln -t:Rebuild -p:Configuration=Debug -p:Platform=X64

goto done

:vsrelease
@echo Building with msbuild -- Release
msbuild build\win\galacell.sln -t:Rebuild -p:Configuration=Release -p:Platform=X64
goto done

:debug
@echo Building debug in build\win\debug with Ninja
cmake -G "Ninja" -B build\win\debug -S . -DCMAKE_BUILD_TYPE=Debug  
ninja -v -C build\win\debug all
goto done

:release
@echo Building release in build\win\release with Ninja
cmake -G "Ninja" -B build\win\release -S . -DCMAKE_BUILD_TYPE=Release 
ninja -v -C build\win\release all
goto done

:test
start build\win\debug\gt_server.exe & timeout 1 & build\win\debug\gt_client.exe
goto done

:done