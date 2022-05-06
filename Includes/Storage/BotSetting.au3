#include-once
#include <StringConstants.au3>
#include "AppConstant.au3"
Global $mknBotSettings = ObjCreate("Scripting.Dictionary")
Global $mknBotActionChain = ObjCreate("Scripting.Dictionary")

; Default bot settings
; ====================
$mknBotSettings.Add($APP_NOTIFICATION_ENABLE, 0)
$mknBotSettings.Add($APP_BATTLE_ACTION_CHAIN, "")
$mknBotSettings.Add($APP_BATTLE_ACTION_RUN_AWAY, "")
$mknBotSettings.Add($APP_BATTLE_RIVAL_WISHLIST, "")
$mknBotSettings.Add($APP_BATTLE_RIVAL_WISHLASTMSG, "")
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

Func mknBotActionChainGet()
    Return $mknBotActionChain
EndFunc

Func mknBotSettingParseActionChain()
    Local $autoCatchTxt = mknBotSettingGet($APP_BATTLE_ACTION_CHAIN)
    If $autoCatchTxt <> "" Then
        Local $stripTxt = StringStripWS($autoCatchTxt, $STR_STRIPALL)
        Local $actions = StringSplit($stripTxt, "|")
        For $i = 1 To $actions[0]
            Local $actionRetryPair = StringSplit($actions[$i], "_")
            Local $actionKey = $actionRetryPair[1]
            If $actionRetryPair[0] = 1 Then
                $mknBotActionChain.Item($actionKey) = 1
            ElseIf $actionRetryPair[0] = 2 Then
                $mknBotActionChain.Item($actionKey) = Number($actionRetryPair[2])
            Else
                ConsoleWrite("[Setting Error] Action contain more than one _.  " & $actions[$i])
                Exit
            EndIf 
        Next
    EndIf
EndFunc

#EndRegion