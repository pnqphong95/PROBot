#include-once
#include <StringConstants.au3>
#include "AppConstant.au3"
Global $pbBotSettings = ObjCreate("Scripting.Dictionary")
Global $pbBotActionChain = ObjCreate("Scripting.Dictionary")

; Default bot settings
; ====================
$pbBotSettings.Add($APP_NOTIFICATION_ENABLE, 0)
$pbBotSettings.Add($APP_BATTLE_ACTION_CHAIN, "")
$pbBotSettings.Add($APP_BATTLE_ACTION_RUN_AWAY, "")
$pbBotSettings.Add($APP_BATTLE_RIVAL_WISHLIST, "")
$pbBotSettings.Add($APP_BATTLE_RIVAL_WISHLASTMSG, "")
$pbBotSettings.Add($APP_BATTLE_RIVAL_IGNORELIST, "")
$pbBotSettings.Add($APP_SPAWN_START_DIRECTION, "LEFT")
$pbBotSettings.Add($APP_SPAWN_SHORTEST_PRESS, 300)
$pbBotSettings.Add($APP_SPAWN_LONGEST_PRESS, 500)


; Functions to handle $pbBotSetting dictionary
; =============================================
#Region Bot setting functions
    
Func pbBotSettingInit(Const $settingPath)
    Local $section = "BotSettings"
    If FileExists($settingPath) Then
        Local $botSettings = IniReadSection($settingPath, $section)
        If Not @error Then
            For $i = 1 To $botSettings[0][0]
                Local $key = $botSettings[$i][0]
                Local $value = $botSettings[$i][1]
                Local $oldValue = pbBotSettingGet($key)
                If $value <> "" And $value <> $oldValue Then
                    Local $oldValue = pbBotSettingGet($key)
                    ConsoleWrite("Setting overwritten [" & $key & "]: " & $oldValue &" -> " & $value & @CRLF)
                    $pbBotSettings.Item($key) = $value
                EndIf
            Next
        EndIf
    Else
        For $key In $pbBotSettings
            IniWrite($settingPath, $section, $key, pbBotSettingGet($key))
        Next
    EndIf
EndFunc

Func pbBotSettingGet(Const $key)
    Return $pbBotSettings.Item($key)
EndFunc

Func pbBotActionChainGet()
    Return $pbBotActionChain
EndFunc

Func pbBotSettingParseActionChain()
    Local $autoCatchTxt = pbBotSettingGet($APP_BATTLE_ACTION_CHAIN)
    If $autoCatchTxt <> "" Then
        Local $stripTxt = StringStripWS($autoCatchTxt, $STR_STRIPALL)
        Local $actions = StringSplit($stripTxt, "|")
        For $i = 1 To $actions[0]
            Local $actionRetryPair = StringSplit($actions[$i], "_")
            Local $actionKey = $actionRetryPair[1]
            If $actionRetryPair[0] = 1 Then
                $pbBotActionChain.Item($actionKey) = 1
            ElseIf $actionRetryPair[0] = 2 Then
                $pbBotActionChain.Item($actionKey) = Number($actionRetryPair[2])
            Else
                ConsoleWrite("[Setting Error] Action contain more than one _.  " & $actions[$i])
                Exit
            EndIf 
        Next
    EndIf
EndFunc

#EndRegion