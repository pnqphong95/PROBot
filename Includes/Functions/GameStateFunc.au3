#include-once
#include <StringConstants.au3>
#include "..\Libs\Tesseract.au3"
#include "WindowFunc.au3"

Func ProBot_IsBattleDialogVisible($hwnd)
	If IsHWnd($hwnd) Then
		Opt("PixelCoordMode", 2)
		ProBot_ActivateWindow($hwnd)
        PixelSearch(360, 176, 1000, 178, 0x282528, 1, 1, $hwnd)
		Return Not @error
	EndIf
	Return False
EndFunc

Func ProBot_IsBattleActionReady($hwnd)
	If IsHWnd($hwnd) Then
		Opt("PixelCoordMode", 2)
		ProBot_ActivateWindow($hwnd)
        PixelSearch(1020, 595, 1025, 596, 0x7F7F7F, 2, 1, $hwnd)
		Return Not @error
	EndIf
	Return False
EndFunc

Func ProBot_CaptureOpponent($hwnd)
	If IsHWnd($hwnd) Then
		_TesseractTempPathSet(@TempDir & "\")
		Return  _TesseractWinCapture(WinGetTitle($hwnd), "", 0, "", 1, 2, 480, 240, 1180, 290, 0)
	EndIf
	Return ""
EndFunc

Func ProBot_CaptureLatestBattleLog($hwnd)
	If IsHWnd($hwnd) Then
		_TesseractTempPathSet(@TempDir & "\")
		Return _TesseractWinCapture(WinGetTitle($hwnd), "", 0, "", 1, 2, 320, 900, 920, 1000, 0)
	EndIf
	Return ""
EndFunc

Func ProBot_OpponentExtractText(Const $opponentRaw)
	Local $keyword = "Wild"
	Local $stripText = StringStripWS($opponentRaw, $STR_STRIPTRAILING)
	Local $keywordPosition = StringInStr($stripText, $keyword, 1)
	If $keywordPosition = 0 Or @error Then
		Return $opponentRaw
	Else
		Local $includeKeyword = StringRight($stripText, StringLen($stripText) - $keywordPosition + 1)
		Local $nonKeyword = StringRight($includeKeyword, StringLen($includeKeyword) - StringLen($keyword) - 1)
		Return $nonKeyword
	EndIf
EndFunc

Func ProBot_IsOpponentQualified(Const $input, Const $acceptOpponents = "", Const $rejectOpponents = "")
	If $rejectOpponents <> "" And StringInStr($rejectOpponents, $input) Then
		Return False
	EndIf
	If $acceptOpponents <> "" And Not StringInStr($acceptOpponents, $input) Then
		Return False
	EndIf
	Return True
EndFunc