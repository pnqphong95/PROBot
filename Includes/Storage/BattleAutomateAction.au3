#include-once
#include <MsgBoxConstants.au3>
#include <StringConstants.au3>
#include "Settings.au3"
#include "Scripting.au3"

Global $BattleAutomateAction = ObjCreate("Scripting.Dictionary")
Global Const $CLIENT_BATTLE_ACTION_FIGHT = "FIGHT"
Global Const $CLIENT_BATTLE_ACTION_POKEMON = "POKEMON"
Global Const $CLIENT_BATTLE_ACTION_ITEM = "ITEM"
Global Const $CLIENT_BATTLE_ACTION_RETRY = "RETRY"


Func loadBattleAutomateAction(Const $chain)
    If $chain <> "" Then
        Local $stepCount = 1
        Local $actions = StringSplit($chain, "|")
        For $i = 1 To $actions[0]
            Local $actionPair = StringSplit($actions[$i], ":")
            If $actionPair[0] <> 2 Then
                MsgBox($MB_SYSTEMMODAL, "Initializing Error 1", "Scripting action " & $chain & " is invalid.")
                Exit
            EndIf
            Local $actionType = $actionPair[1]
            If $actionType <> $CLIENT_BATTLE_ACTION_FIGHT And $actionType <> $CLIENT_BATTLE_ACTION_POKEMON And $actionType <> $CLIENT_BATTLE_ACTION_ITEM And $actionType <> $CLIENT_BATTLE_ACTION_RETRY Then
                MsgBox($MB_SYSTEMMODAL, "Initializing Error 2", "Scripting action " & $chain & " is invalid.")
                Exit
            EndIf
            Local $actionChoice = $actionPair[2]
            Local $actionChoiceAsNumber = Number($actionChoice)
            If $actionChoiceAsNumber < 1 Or $actionChoiceAsNumber > 6 Then
                MsgBox($MB_SYSTEMMODAL, "Initializing Error 3", "Scripting action " & $chain & " is invalid.")
                Exit
            EndIf
            $BattleAutomateAction.Item($stepCount & "_" & $actionType) = $actionChoiceAsNumber
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

Func resolveChoiceKey(Const $actionType, Const $actionChoice)
    If $actionChoice < 1 Or $actionChoice > 6 Then
        MsgBox($MB_SYSTEMMODAL, "Runtime Error", "Action choice " & $actionChoice & " is invalid.")
        Exit
    EndIf
    Switch ($actionType)
        Case $CLIENT_BATTLE_ACTION_POKEMON
            If $actionChoice > 1 Then
                Return getBotSetting($CLIENT_BATTLE_ACTION_KEY & "." & $actionChoice)
            EndIf
            Return ''
        Case Else
            Return getBotSetting($CLIENT_BATTLE_ACTION_KEY & "." & $actionChoice)
    EndSwitch
EndFunc