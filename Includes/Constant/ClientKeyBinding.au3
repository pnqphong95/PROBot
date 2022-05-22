#include-once

;~ Game client, keyboard setting
;~ Bot used to send correct key to game client
Global Const $CLIENT_BATTLE_ACTION_KEY_1 = "Z"
Global Const $CLIENT_BATTLE_ACTION_KEY_2 = "X"
Global Const $CLIENT_BATTLE_ACTION_KEY_3 = "C"
Global Const $CLIENT_BATTLE_ACTION_KEY_4 = "V"
Global Const $CLIENT_BATTLE_ACTION_KEY_5 = "B"
Global Const $CLIENT_BATTLE_ACTION_KEY_6 = "N"

Func keyBinding(Const $number)
    Switch ($number)
        Case 1
            Return $CLIENT_BATTLE_ACTION_KEY_1
        Case 2
            Return $CLIENT_BATTLE_ACTION_KEY_2
        Case 3
            Return $CLIENT_BATTLE_ACTION_KEY_3
        Case 4
            Return $CLIENT_BATTLE_ACTION_KEY_4
        Case 5
            Return $CLIENT_BATTLE_ACTION_KEY_5
        Case 6
            Return $CLIENT_BATTLE_ACTION_KEY_6
        Case Else
            Return ""
    EndSwitch
EndFunc