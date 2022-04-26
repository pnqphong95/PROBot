#include-once
#include "AppConstant.au3"
Global $mknBotSettings = ObjCreate("Scripting.Dictionary")


; Default bot settings
; ====================
$mknBotSettings.Add($APP_BATTLE_RIVAL_WISHLIST, "")
$mknBotSettings.Add($APP_BATTLE_RIVAL_IGNORELIST, "")
$mknBotSettings.Add($APP_SPAWN_START_DIRECTION, "LEFT")
$mknBotSettings.Add($APP_SPAWN_SHORTEST_PRESS, 300)
$mknBotSettings.Add($APP_SPAWN_LONGEST_PRESS, 500)

; Functions to handle $mknBotSetting dictionary
; =============================================
#Region Bot setting functions
    
Func mknBotSettingInit(Const $settingPath)
    Local $section = "BotSettings"
    If FileExists($settingPath) Then
        Local $botSettings = IniReadSection($settingPath, $section)
        If Not @error Then
            For $i = 1 To $botSettings[0][0]
                Local $key = $botSettings[$i][0]
                Local $value = $botSettings[$i][1]
                Local $oldValue = mknBotSettingGet($key)
                If $value <> "" And $value <> $oldValue Then
                    Local $oldValue = mknBotSettingGet($key)
                    ConsoleWrite("Setting overwritten [" & $key & "]: " & $oldValue &" -> " & $value & @CRLF)
                    $mknBotSettings.Item($key) = $value
                EndIf
            Next
        EndIf
    Else
        For $key In $mknBotSettings
            IniWrite($settingPath, $section, $key, mknBotSettingGet($key))
        Next
    EndIf
EndFunc

Func mknBotSettingGet(Const $key)
    Return $mknBotSettings.Item($key)
EndFunc

#EndRegion