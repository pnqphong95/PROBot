#include-once
#include "AppConstant.au3"
Global $mknAppSettings = ObjCreate("Scripting.Dictionary")


; Default app settings
; ====================
$mknAppSettings.Add($APP_TITLE, "PROClient")
$mknAppSettings.Add($APP_NOTIFICATION_ENABLE, False)
$mknAppSettings.Add($APP_NOTIFICATION_TELEGRAM_CHAT_ID, "")
$mknAppSettings.Add($APP_NOTIFICATION_TELEGRAM_BOT_TOKEN, "")
$mknAppSettings.Add($APP_ACTION_1, "Z")
$mknAppSettings.Add($APP_ACTION_2, "X")
$mknAppSettings.Add($APP_ACTION_3, "C")
$mknAppSettings.Add($APP_ACTION_4, "V")
$mknAppSettings.Add($APP_ACTION_5, "B")
$mknAppSettings.Add($APP_ACTION_6, "N")
$mknAppSettings.Add($APP_BATTLE_IDENTIFIER_X, 380)
$mknAppSettings.Add($APP_BATTLE_IDENTIFIER_Y, 155)
$mknAppSettings.Add($APP_BATTLE_IDENTIFIER_W, 620)
$mknAppSettings.Add($APP_BATTLE_IDENTIFIER_H, 5)
$mknAppSettings.Add($APP_BATTLE_IDENTIFIER_COLOR, "0x282528")


; Functions to handle $mknAppSetting dictionary
; =============================================
#Region App setting functions
    
Func mknAppSettingInit(Const $settingPath)
    Local $section = "AppSettings"
    If FileExists($settingPath) Then
        Local $appSettings = IniReadSection($settingPath, $section)
        If Not @error Then
            For $i = 1 To $appSettings[0][0]
                Local $key = $appSettings[$i][0]
                Local $value = $appSettings[$i][1]
                $mknAppSettings.Item($key) = $value
                ConsoleWrite($settingPath & " loaded key [" & $key & "] = " & $value & @CRLF)
            Next
        EndIf
    Else
        For $key In $mknAppSettings
            IniWrite($settingPath, $section, $key, mknAppSettingGet($key))
        Next
    EndIf
EndFunc

Func mknAppSettingGet(Const $key)
    Return $mknAppSettings.Item($key)
EndFunc

#EndRegion