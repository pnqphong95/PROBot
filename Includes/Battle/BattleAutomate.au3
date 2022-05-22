#include-once
#include <MsgBoxConstants.au3>
#include "..\Constant\ClientKeyBinding.au3"
#include "..\Constant\StateConstant.au3"

Func resolveAction(Const $action)
    Switch ($action)
        Case $CLIENT_BATTLE_ACTION_POKEMON
            Return $CLIENT_BATTLE_ACTION_KEY_2
        Case $CLIENT_BATTLE_ACTION_FIGHT
            Return $CLIENT_BATTLE_ACTION_KEY_1
        Case $CLIENT_BATTLE_ACTION_ITEM
            Return $CLIENT_BATTLE_ACTION_KEY_3
        Case Else
            Return ''
    EndSwitch
EndFunc

Func resolveChoice(Const $action, Const $choice)
    Switch ($action)
        Case $CLIENT_BATTLE_ACTION_POKEMON
            If $choice < 1 Or $choice > 6 Then
                MsgBox($MB_SYSTEMMODAL, "Runtime Error", "Action choice " & $choice & " is invalid.")
                Exit
            EndIf
            If $choice > 1 Then
                Return keyBinding($choice)
            EndIf
            Return ''
        Case $CLIENT_BATTLE_ACTION_FIGHT, $CLIENT_BATTLE_ACTION_ITEM
            Return keyBinding($choice)
        Case Else
            Return ''
    EndSwitch
EndFunc