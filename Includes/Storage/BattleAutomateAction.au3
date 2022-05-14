#include-once
#include <MsgBoxConstants.au3>
#include <StringConstants.au3>
#include "Settings.au3"
#include "Scripting.au3"

Global $BattleAutomateAction = ObjCreate("Scripting.Dictionary")
Global $BattleAutomateActionDisabled = ObjCreate("Scripting.Dictionary")
Global Const $CLIENT_BATTLE_ACTION_FIGHT = "FIGHT"
Global Const $CLIENT_BATTLE_ACTION_POKEMON = "POKEMON"
Global Const $CLIENT_BATTLE_ACTION_ITEM = "ITEM"
Global Const $CLIENT_BATTLE_ACTION_RETRY = "RETRY"
Global Const $CLIENT_BATTLE_ACTION_CB = "CB"
Global Const $CLIENT_BATTLE_ACTION_CR = "CR"


Func loadBattleAutomateAction(Const $chain)
    If $chain <> "" Then
        Local $stepCount = 1
        Local $actions = StringSplit($chain, "|")
        For $i = 1 To $actions[0]
            Local $actionPair = StringSplit($actions[$i], ":")
            If $actionPair[0] <> 2 Then
                MsgBox($MB_SYSTEMMODAL, "Initializing Error", "Scripting action " & $chain & " is invalid.")
                Exit
            EndIf
            Local $actionType = $actionPair[1]
            Local $actionChoice = $actionPair[2]
            Local $actionChoiceAsNumber = Number($actionChoice)
            $BattleAutomateAction.Item($stepCount & "-" & $actionType) = $actionChoiceAsNumber
            $stepCount = $stepCount + 1
        Next
    EndIf
EndFunc

Func resolveActionKey(Const $actionType)
    Switch ($actionType)
        Case $CLIENT_BATTLE_ACTION_POKEMON
            Return getBotSetting($CLIENT_BATTLE_ACTION_KEY_2)
        Case $CLIENT_BATTLE_ACTION_FIGHT
            Return getBotSetting($CLIENT_BATTLE_ACTION_KEY_1)
        Case $CLIENT_BATTLE_ACTION_ITEM
            Return getBotSetting($CLIENT_BATTLE_ACTION_KEY_3)
        Case Else
            Return ''
    EndSwitch
EndFunc

Func resolveActionValue(Const $actionType, Const $actionValue)
    Switch ($actionType)
        Case $CLIENT_BATTLE_ACTION_POKEMON
            If $actionValue < 1 Or $actionValue > 6 Then
                MsgBox($MB_SYSTEMMODAL, "Runtime Error", "Action choice " & $actionValue & " is invalid.")
                Exit
            EndIf
            If $actionValue > 1 Then
                Return getBotSetting($CLIENT_BATTLE_ACTION_KEY & "." & $actionValue)
            EndIf
            Return ''
        Case $CLIENT_BATTLE_ACTION_FIGHT, $CLIENT_BATTLE_ACTION_ITEM
            Return getBotSetting($CLIENT_BATTLE_ACTION_KEY & "." & $actionValue)
        Case $CLIENT_BATTLE_ACTION_RETRY, $CLIENT_BATTLE_ACTION_CR, $CLIENT_BATTLE_ACTION_CB
            Return $actionValue
        Case Else
            Return ''
    EndSwitch
EndFunc

Func removeClosableBattleAction(Const $actionToRemove)
    Local $size = $BattleAutomateAction.Count
    Local $split = StringSplit($actionToRemove, "-")
	Local $type = $split[2]
	If $CLIENT_BATTLE_ACTION_FIGHT = $type Or $CLIENT_BATTLE_ACTION_ITEM = $type Then
        ConsoleWrite('Remove scripting action: ' & $actionToRemove & @CRLF)
        $BattleAutomateAction.Remove($actionToRemove)
        ; Remove impact actions
        Local $step = $split[1]
        For $i = $step + 1 To $size
            Local $isFight = $BattleAutomateAction.Exists($i & '-' & $CLIENT_BATTLE_ACTION_FIGHT)
            Local $isUseItem = $BattleAutomateAction.Exists($i & '-' & $CLIENT_BATTLE_ACTION_ITEM)
            Local $isSwitchPoke = $BattleAutomateAction.Exists($i & '-' & $CLIENT_BATTLE_ACTION_POKEMON)
            Local $isWaitBattle = $BattleAutomateAction.Exists($i & '-' & $CLIENT_BATTLE_ACTION_CB)
            Local $isWaitReady = $BattleAutomateAction.Exists($i & '-' & $CLIENT_BATTLE_ACTION_CR)
            Local $isRetry = $BattleAutomateAction.Exists($i & '-' & $CLIENT_BATTLE_ACTION_RETRY)
            If $isFight Or $isUseItem Or $isSwitchPoke Then
                ExitLoop
            ElseIf $isWaitBattle Then
                ConsoleWrite('Remove impact scripting action: ' & $i & '-' & $CLIENT_BATTLE_ACTION_CB & @CRLF)
                $BattleAutomateAction.Remove($i & '-' & $CLIENT_BATTLE_ACTION_CB)
            ElseIf $isWaitReady Then
                ConsoleWrite('Remove impact scripting action: ' & $i & '-' & $CLIENT_BATTLE_ACTION_CR & @CRLF)
                $BattleAutomateAction.Remove($i & '-' & $CLIENT_BATTLE_ACTION_CR)
            ElseIf $isRetry Then
                ConsoleWrite('Remove impact scripting action: ' & $i & '-' & $CLIENT_BATTLE_ACTION_RETRY & @CRLF)
                $BattleAutomateAction.Remove($i & '-' & $CLIENT_BATTLE_ACTION_RETRY)
            EndIf
        Next
    EndIf
EndFunc