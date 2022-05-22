#include-once
#include "..\Constant\StateConstant.au3"
#include "GlobalStateObject.au3"
#include "SlotInfoFunction.au3"
#include "SlotScriptingFunction.au3"

Func SlotState_resetAll()
    SlotState_initDefault()
    SlotScripting_fromSlotState($SlotState)
EndFunc

Func SlotState_fromUser(Const $UserScript)
    For $i = 0 To 5
        Local $scriptingKey = $state_bot_battle_action_script & "." & $i + 1
        If $UserScript.Exists($scriptingKey) Then
            $SlotState[$i].Item($state_bot_battle_action_script) = ""
            SlotState_saveActionScript($i, $UserScript.Item($scriptingKey))
        EndIf
    Next
EndFunc

Func SlotState_saveActionScript(Const $slot, Const $actionAcript)
    Local $currentScript = SlotState_actionScript($slot)
    If $currentScript <> $actionAcript Then
        ConsoleWrite("[SlotState] Slot " & $slot + 1 & " updated new script " & $actionAcript & @CRLF)
        SlotState_setActionScript($slot, $actionAcript)
        SlotScripting_setActionScript($slot, $actionAcript)
        Return $actionAcript
    Else
        SlotScripting_setActionScript($slot, $currentScript)
        Return $currentScript
    EndIf
EndFunc

Func SlotState_setActionScript(Const $slot, Const $actionAcript)
    $SlotState[$slot].Item($state_bot_battle_action_script) = $actionAcript
EndFunc

Func SlotState_actionScript(Const $slot)
    Return $SlotState[$slot].Item($state_bot_battle_action_script)
EndFunc

Func SlotState_swapPokemon($slot1, $slot2)
    If SlotInfo_swapUiSlot($slot1, $slot2) Then
        Local $tempObject = ObjCreate("Scripting.Dictionary")
        For $key In $SlotState[$slot1]
            $tempObject.Item($key) = $SlotState[$slot1].Item($key)
        Next
        $SlotState[$slot1].RemoveAll
        For $key In $SlotState[$slot2]
            $SlotState[$slot1].Item($key) = $SlotState[$slot2].Item($key)
        Next
        $SlotState[$slot2].RemoveAll
        For $key In $tempObject
            $SlotState[$slot2].Item($key) = $tempObject.Item($key)
        Next
        SlotScripting_fromSlotState($SlotState)
        Return True
    EndIf
    Return False
EndFunc

Func SlotState_setNoUsableMove(Const $slot)
    ConsoleWrite("[SlotState] Set slot " & $slot & " has no usable move." & @CRLF)
    $SlotState[$slot].Item($state_client_slot_no_usable_move) = True
EndFunc

Func SlotState_hasUsableMove(Const $slot)
    Local $entryExist = $SlotState[$slot].Exists($state_client_slot_no_usable_move)
    Return Not $entryExist Or Not $SlotState[$slot].Item($state_client_slot_no_usable_move)
EndFunc

Func SlotState_isUsableSlot(Const $hnwd, Const $slot)
    Local $haspp = SlotState_hasUsableMove($slot)
    Local $alive = SlotInfo_isAlive($hnwd, $slot)
    Return $haspp And $alive
EndFunc

Func SlotState_usableSlot(Const $hnwd, Const $start = 0)
    For $i = $start To 5
        If SlotState_isUsableSlot($hnwd, $i) Then
            Return $i
        EndIf
    Next
    ConsoleWrite("[SlotState] No usable pokemon found!")
EndFunc

Func SlotState_removeAction(Const $slot, Const $action, Const $choice)
    Local $currentScript = SlotState_actionScript($slot)
    Local $temp = StringReplace($currentScript, $action & $CLIENT_BATTLE_CHOICE_SEPARATOR & $choice, "")
    While StringLeft($temp, 1) = $CLIENT_BATTLE_ACTION_SEPARATOR
        $temp = StringTrimLeft($temp, 1)
    WEnd
    While StringRight($temp, 1) = $CLIENT_BATTLE_ACTION_SEPARATOR
        $temp = StringTrimRight($temp, 1)
    WEnd
    Local $doubleSeparator = $CLIENT_BATTLE_ACTION_SEPARATOR & $CLIENT_BATTLE_ACTION_SEPARATOR
    Local $newScript = StringReplace($temp, $doubleSeparator, $CLIENT_BATTLE_ACTION_SEPARATOR)
    Return SlotState_saveActionScript($slot, $newScript)
EndFunc