
@echo off&Setlocal EnableExtensions Enabledelayedexpansion
REM 確保變數有抓到
REM 檢查值歸零，用於判斷本機是否有安裝好Yahoo (HKU\.DEFAULT\Keyboard Layout\Preload)
set /A check=0
set input_default=E0200404
for /f "delims= " %%B in (
    'REG Query "HKU\.DEFAULT\Keyboard Layout\Preload" ^
    ^| Findstr %input_default%'
) do (
    REM 判定有抓到輸入法的值，設定狀態值為1
    set check=1
    goto :start
)
REM 判定如果沒有對應的值去做開啟Yahoo安裝程式
If !check!==0 (
    echo 判定本機未安裝或有其他異常之奇摩輸入法，請等候幾秒待程式執行奇摩安裝程式
    echo 如果有提示要重新開機，請按「否」讓程式繼續跑
    call "[install path]"
    timeout /t 2
    echo 已安裝完畢，請等候2秒後，將繼續執行鍵盤配置
    ) Else (
        echo Already Installed yahoo input software
        )
REM  抓當前使用者的SID
:start
echo Check Sid for Current user...
For /F "delims= " %%C in ('"wmic path win32_useraccount where name='%username%' get sid"') do (
    if not "%%C"=="SID" (
       set varsid=%%C
       goto :countline
    )
    
)

:countline
REM 建立備份資料夾、備份機碼到%userprofile%\Keyboard_Value_Bk
MD %userprofile%\Keyboard_Value_Bk
REG Export "HKU\%varsid%\Keyboard Layout\Preload" ^
    ^"%userprofile%\Keyboard_Value_Bk\%date:~0,4%%date:~5,2%%date:~8,2%_Keyboard_Value_Bk.reg"
Timeout /t 1
echo Check count lines of Keyboard Layout\Preload For user side
REM 假定計算總行數基礎值

set /A count=0
set /A yahoo=0
set input1=E0200404
REM 篩選登陸檔值輸出結果中的空格，以確保得到不包含空白的值。並計算總行數

For /F "delims= " %%A in (
    'REG Query "HKU\%varsid%\Keyboard Layout\Preload" ^
    ^| Findstr /L /B /V /C:"REG"'
) do (
    set /A count+=1
    set keyboard=%%A
    
)

REM 檢查當前使用者是否有設置類似第三方輸入法的值，這邊僅查詢E0210404而沒有E0200404情況
For /F "delims= " %%G in (
    'REG Query "HKU\%varsid%\Keyboard Layout\Preload" ^
    ^| Findstr E0210404'
) do (
    REM 檢查如果有第二順位的第三方繁體輸入法進行「刪除」以確保真實性設定值
    REG DELETE "HKU\%varsid%\Keyboard Layout\Preload" /v %%G
    echo 已發現有第二順位的輸入法值，將刪除E0210404
    Timeout /t 2
)

REM
echo 目前鍵盤輸入法數量: %keyboard%

For /F "delims= " %%B in (
    'REG Query "HKU\%varsid%\Keyboard Layout\Preload" ^
    ^| Findstr %input1%'
) do (
    REM 判定有抓到輸入法值，設定狀態值為1
    set yahoo=1
)
REM 判定如果沒有對應的值去做新增動作
If !yahoo!==0 (
    echo Add new line for Preload of %count%
    REG ADD "HKU\%varsid%\Keyboard Layout\Preload" /v %count% /d %input1%
    ) Else (
        echo Already exist value of %input1%
        )
        
Timeout /t 2
echo 已完成，可以重新登出電腦驗證其是否有效
pause
Endlocal
Exit
