#include-once
#include "AppConstant.au3"
Global $mknAppSettings = ObjCreate("Scripting.Dictionary")


; Default app settings
; ====================
$mknAppSettings.Add($APP_TITLE, "PROClient")
$mknAppSettings.Add($APP_NOTIFICATION_ENABLE, 1)
$mknAppSettings.Add($APP_NOTIFICATION_TELEGRAM_CHAT_ID, "")
$mknAppSettings.Add($APP_NOTIFICATION_TELEGRAM_BOT_TOKEN, "")
$mknAppSettings.Add($APP_BATTLE_IDENTIFIER_X, 380)
$mknAppSettings.Add($APP_BATTLE_IDENTIFIER_Y, 155)
$mknAppSettings.Add($APP_BATTLE_IDENTIFIER_W, 620)
$mknAppSettings.Add($APP_BATTLE_IDENTIFIER_H, 5)
$mknAppSettings.Add($APP_BATTLE_IDENTIFIER_COLOR, "0x282528")
$mknAppSettings.Add($APP_BATTLE_RIVAL_IDENTIFIER_X, 770)
$mknAppSettings.Add($APP_BATTLE_RIVAL_IDENTIFIER_Y, 225)
$mknAppSettings.Add($APP_BATTLE_RIVAL_IDENTIFIER_W, 300)
$mknAppSettings.Add($APP_BATTLE_RIVAL_IDENTIFIER_H, 40)
$mknAppSettings.Add($APP_BATTLE_CONTROLABLE_IDENTIFIER_X, 920)
$mknAppSettings.Add($APP_BATTLE_CONTROLABLE_IDENTIFIER_Y, 575)
$mknAppSettings.Add($APP_BATTLE_CONTROLABLE_IDENTIFIER_W, 2)
$mknAppSettings.Add($APP_BATTLE_CONTROLABLE_IDENTIFIER_H, 1)
$mknAppSettings.Add($APP_BATTLE_CONTROLABLE_IDENTIFIER_COLOR, "0x8f8f8f")

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
                Local $oldValue = mknAppSettingGet($key)
                If $value <> "" And $value <> $oldValue Then
                    Local $oldValue = mknAppSettingGet($key)
                    ConsoleWrite("Setting overwritten [" & $key & "]: " & $oldValue &" -> " & $value & @CRLF)
                    $mknAppSettings.Item($key) = $value
                EndIf
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