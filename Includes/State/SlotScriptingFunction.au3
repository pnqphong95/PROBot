#include-once
#include "..\Constant\StateConstant.au3"
#include "GlobalStateObject.au3"
#include "..\State\SlotStateFunction.au3"

Func SlotScripting_at(Const $slot)
    Return $SlotScripting[$slot]
EndFunc

Func SlotScripting_reset(Const $slot)
    $SlotScripting[$slot].RemoveAll
EndFunc

Func SlotScripting_fromSlotState(Const $SlotState)
    For $i = 0 To 5
        SlotScripting_reset($i)
        Local $script = SlotState_actionScript($i)
        SlotScripting_parseScript($i, $script) 
    Next
EndFunc

Func SlotScripting_setActionScript(Const $slot, Const $actionScript)
    SlotScripting_reset($slot)
    Return SlotScripting_parseScript($slot, $actionScript)
EndFunc

Func SlotScripting_parseScript(Const $slot, Const $script)
    If $script <> "" Then
        Local $stepCount = 1
        Local $actions = StringSplit($script, $CLIENT_BATTLE_ACTION_SEPARATOR)
        For $i = 1 To $actions[0]
            Local $actionPair = StringSplit($actions[$i], $CLIENT_BATTLE_CHOICE_SEPARATOR)
            If $actionPair[0] <> 2 Then
                ConsoleWrite("[SlotScripting] Parse script error, script = " & $script)
                SlotScripting_reset($slot)
                Return False
            EndIf
            Local $actionType = $actionPair[1]
            Local $actionChoice = $actionPair[2]
            Local $actionChoiceAsNumber = Number($actionChoice)
            $SlotScripting[$slot].Item($stepCount & "-" & $actionType) = $actionChoiceAsNumber
             ConsoleWrite("[SlotScripting] Slot " & $slot + 1 & ", updated step " & $actionType & "(" & $actionChoiceAsNumber & ")" & @CRLF)
            $stepCount = $stepCount + 1
        Next
    EndIf
    Return True
EndFunc