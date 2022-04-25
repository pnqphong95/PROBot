#include-once
#include "Tesseract.au3"
#include "Utility.au3"
#cs ----------------------------------------------------------------------------

 Version: 0.1.0
 AutoIt Version: 3.3.16.0
 Author: pnqphong95

 Script Function:
	Capture, record the information from the game screen.

#ce ----------------------------------------------------------------------------
Func _captureScreenBattle($hnwd)
	If IsHWnd($hnwd) Then
		; Sets the way coords are used in the pixel search functions.
		; 2 =  relative coords to the client area of the defined window.
		activateWindow($hnwd)
		Opt("PixelCoordMode", 2)
		Local $battleDialogColor = 0x282528
		Local $left = 380, $top = 155, $right = 1000, $bottom = 160
		Local $battleDialogCoor = PixelSearch($left, $top, $right, $bottom, $battleDialogColor, 1, 1, $hnwd)
		Return Not @error
	EndIf
	Return False
EndFunc

Func pro_isBattleControlFree($hnwd)
	If IsHWnd($hnwd) Then
		; Sets the way coords are used in the pixel search functions.
		; 2 =  relative coords to the client area of the defined window.
		activateWindow($hnwd)
		Opt("PixelCoordMode", 2)
		Local $controlFreeColor = 0x8f8f8f
		Local $left = 920, $top = 575, $right = 922, $bottom = 576
		Local $controlFreeCoor = PixelSearch($left, $top, $right, $bottom, $controlFreeColor, 2, 1, $hnwd)
		Return Not @error
	EndIf
	Return False
EndFunc

Func _captureBattleTitle($hnwd)
	If IsHWnd($hnwd) Then
		_TesseractTempPathSet(@TempDir & "\")
		Local $left = 770, $top = 225, $right = 1070, $bottom = 265
		Return _TesseractWinCapture(WinGetTitle($hnwd), "", 0, "", 1, 2, $left, $top, $right, $bottom, 0)
	EndIf
	Return ""
EndFunc

Func _extractWildPokemonName(Const $battleTitle)
	Local $keyword = "Wild"
	Local $stripText = StringStripWS($battleTitle, $STR_STRIPTRAILING)
	Local $keywordPosition = StringInStr($stripText, $keyword, 1)
	If $keywordPosition = 0 Or @error Then
		Return $battleTitle
	Else
		Return StringRight($stripText, StringLen($stripText) - ($keywordPosition + StringLen($keyword)))
	EndIf
EndFunc