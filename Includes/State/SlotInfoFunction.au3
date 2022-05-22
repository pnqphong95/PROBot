#include-once
#include <AutoItConstants.au3>
#include "..\Constant\StateConstant.au3"
#include "GlobalStateObject.au3"
#include "..\Utilities\WndHelper.au3"

Func SlotInfo_isAlive(Const $hnwd, Const $slot)
    If IsHWnd($hnwd) Then
		Opt("PixelCoordMode", 2)
	    activateWindow($hnwd)
        Local $color = $SlotInfo[$slot].Item($state_client_slot_usable_color)
        Local $width = $SlotInfo[$slot].Item($state_client_slot_width)
        Local $height = $SlotInfo[$slot].Item($state_client_slot_height)
        Local $x = $SlotInfo[$slot].Item($state_client_slot_coorx)
        Local $y = $SlotInfo[$slot].Item($state_client_slot_coory)
        Local $resultCoor = PixelSearch($x, $y, $x + $width, $y + $height, $color, 2, 1, $hnwd)
		Return Not @error
	EndIf
	Return False
EndFunc

Func SlotInfo_aliveSlot(Const $hnwd, Const $start = 0)
  For $slot = $start To 5
    Local $alive = SlotInfo_isAlive($hnwd, $slot)
    If $alive Then
      Return $slot
    EndIf
  Next
  ConsoleWrite("[SlotInfo] No alive pokemon found!")
EndFunc

Func SlotInfo_swapUiSlot(Const $slot1, Const $slot2)
  Opt("MouseCoordMode", 2)
  Local $x1 = $SlotInfo[$slot1].Item($state_client_slot_coorx)
  Local $y1 = $SlotInfo[$slot1].Item($state_client_slot_coory)
  Local $x2 = $SlotInfo[$slot2].Item($state_client_slot_coorx)
  Local $y2 = $SlotInfo[$slot2].Item($state_client_slot_coory)
  If MouseClickDrag($MOUSE_CLICK_LEFT, $x1, $y1, $x2, $y2, Random(10, 30, 1)) = 1 Then
    ConsoleWrite("[SlotInfo] Completed swap pokemon slot " & $slot1 + 1 & " to slot " & $slot2 + 1)
    Return True
  EndIf
EndFunc