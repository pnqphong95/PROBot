#include-once
#include "AppConstant.au3"
Global $pbAppSettings = ObjCreate("Scripting.Dictionary")


; Default app settings
; ====================
$pbAppSettings.Add($APP_TITLE, "PROClient")
$pbAppSettings.Add($APP_NOTIFICATION_ENABLE, 0)
$pbAppSettings.Add($APP_NOTIFICATION_TELEGRAM_CHAT_ID, "")
$pbAppSettings.Add($APP_NOTIFICATION_TELEGRAM_BOT_TOKEN, "")
$pbAppSettings.Add($APP_BATTLE_IDENTIFIER_X, 380)
$pbAppSettings.Add($APP_BATTLE_IDENTIFIER_Y, 155)
$pbAppSettings.Add($APP_BATTLE_IDENTIFIER_W, 620)
$pbAppSettings.Add($APP_BATTLE_IDENTIFIER_H, 5)
$pbAppSettings.Add($APP_BATTLE_IDENTIFIER_COLOR, "0x282528")
$pbAppSettings.Add($APP_BATTLE_RIVAL_IDENTIFIER_X, 770)
$pbAppSettings.Add($APP_BATTLE_RIVAL_IDENTIFIER_Y, 225)
$pbAppSettings.Add($APP_BATTLE_RIVAL_IDENTIFIER_W, 300)
$pbAppSettings.Add($APP_BATTLE_RIVAL_IDENTIFIER_H, 40)
$pbAppSettings.Add($APP_BATTLE_CONTROLABLE_IDENTIFIER_X, 920)
$pbAppSettings.Add($APP_BATTLE_CONTROLABLE_IDENTIFIER_Y, 575)
$pbAppSettings.Add($APP_BATTLE_CONTROLABLE_IDENTIFIER_W, 2)
$pbAppSettings.Add($APP_BATTLE_CONTROLABLE_IDENTIFIER_H, 1)
$pbAppSettings.Add($APP_BATTLE_CONTROLABLE_IDENTIFIER_COLOR, "0x8f8f8f")

; Functions to handle $pbAppSetting dictionary
; =============================================
#Region App setting functions
    
Func pbAppSettingInit(Const $settingPath)
    Local $section = "AppSettings"
    If FileExists($settingPath) Then
        Local $appSettings = IniReadSection($settingPath, $section)
        If Not @error Then
            For $i = 1 To $appSettings[0][0]
                Local $key = $appSettings[$i][0]
                Local $value = $appSettings[$i][1]
                Local $oldValue = pbAppSettingGet($key)
                If $value <> "" And $value <> $oldValue Then
                    Local $oldValue = pbAppSettingGet($key)
                    ConsoleWrite("Setting overwritten [" & $key & "]: " & $oldValue &" -> " & $value & @CRLF)
                    $pbAppSettings.Item($key) = $value
                EndIf
            Next
        EndIf
    Else
        For $key In $pbAppSettings
            IniWrite($settingPath, $section, $key, pbAppSettingGet($key))
        Next
    EndIf
EndFunc

Func pbAppSettingGet(Const $key)
    Return $pbAppSettings.Item($key)
EndFunc

#EndRegion