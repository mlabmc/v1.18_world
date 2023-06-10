@echo off
rem Naruhiko Ueda 2023-06-11 v1.18_world_v1.0
set "directory=%USERPROFILE%\AppData\Roaming\Minecraft Education Edition\games\com.mojang\minecraftWorlds"

chcp 65001 > nul

echo マインクラフトを終了...
taskkill /F /T /IM Minecraft.Windows.exe

for /d %%i in ("%directory%\*") do (
  setlocal enabledelayedexpansion
  set "subdir=%%~nxi"
  if exist "%%i\levelname.txt" (
    type "%%i\levelname.txt"
    echo.
    echo !subdir!
    echo 処理中...
    echo.
    call :world_convert "!directory!\!subdir!"
  )
  endlocal
)
echo 処理が完了しました！
echo Minecraft Educationを起動します...
start "" "C:\Program Files (x86)\Microsoft Studios\Minecraft Education Edition\Minecraft.Windows.exe"
del %0
exit

:world_convert
@echo off
setlocal

set "FILENAME=%~1\level.dat"

REM バックアップ作成
copy "%FILENAME%" "%FILENAME%.org" > NUL

REM 16進数に変換
REM certutil -f -encodehex "%FILENAME%" "%FILENAME%.hex"
powershell -Command "$bytes = [System.IO.File]::ReadAllBytes('"%FILENAME%"');$hexContent = [System.BitConverter]::ToString($bytes);$hexContent | Out-File -Encoding ASCII -NoNewline '"%FILENAME%.hex"'"

REM level.dat.hex 書き換え
powershell -Command "$content = Get-Content -Encoding ASCII '"%FILENAME%.hex"' -Raw; $content = $content.Remove(0, 11); $content = $content.Insert(0, '09-00-00-00'); [System.IO.File]::WriteAllText('"%FILENAME%.hex"', $content)"
REM InventoryVersion
powershell -Command "$content = Get-Content -Encoding ASCII '"%FILENAME%.hex"' -Raw; $index = $content.IndexOf('49-6E-76-65-6E-74-6F-72-79-56-65-72-73-69-6F-6E-'); $content = $content.Remove($index+48, 35);$content = $content.Insert($index+48, '07-00-31-2E-31-38-2E-34-35-01-0C-00'); [System.IO.File]::WriteAllText('"%FILENAME%.hex"', $content)"
REM StorageVersion
powershell -Command "$content = Get-Content -Encoding ASCII '"%FILENAME%.hex"' -Raw; $index = $content.IndexOf('53-74-6F-72-61-67-65-56-65-72-73-69-6F-6E-'); $content = $content.Remove($index+42, 11);$content = $content.Insert($index+42, '09-00-00-00'); [System.IO.File]::WriteAllText('"%FILENAME%.hex"', $content)"
REM MinimumCompatibleClientVersion
powershell -Command "$content = Get-Content -Encoding ASCII '"%FILENAME%.hex"' -Raw; $index = $content.IndexOf('4D-69-6E-69-6D-75-6D-43-6F-6D-70-61-74-69-62-6C-65-43-6C-69-65-6E-74-56-65-72-73-69-6F-6E-'); $content = $content.Remove($index+90, 84);$content = $content.Insert($index+90, '03-05-00-00-00-01-00-00-00-12-00-00-00-1E-00-00-00-00-00-00-00-00-00-00-00-01-0F-00'); [System.IO.File]::WriteAllText('"%FILENAME%.hex"', $content)"

REM .hex ファイルをバイナリに変換して元のファイルに戻す
certutil -f -decodehex "%FILENAME%.hex" "%FILENAME%.new" > NUL

REM 編集後のファイルで元のファイルを上書き
copy /y "%FILENAME%.new" "%FILENAME%" > NUL

REM 一時ファイルの削除
del "%FILENAME%.hex" "%FILENAME%.new"

endlocal
exit /b 0


