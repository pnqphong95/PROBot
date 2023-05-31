#include-once
#include "..\Libs\Tesseract.au3"

Func ProBot_ActivateWindow(Const $hwnd)
	If Not WinActive($hwnd) Then
		WinActivate($hwnd)
	EndIf
EndFunc

Func ProBot_ClientWindow(Const $title, Const $activate = True)
	Local $hwnds = WinList($title)
	Local $instanceNum = $hwnds[0][0]
	If $instanceNum = 1 Then
		Local $hwnd = $hwnds[1][1]
		If $activate Then
			ProBot_ActivateWindow($hwnd)
		EndIf
		Return $hwnd
	EndIf
EndFunc

Func ProBot_IsMouseHoverGameClient(Const $title) 
	Local $window = WinGetPos($title)
	Local $mouse = MouseGetPos()
	Return $mouse[0] > $window[0] And $mouse[0] < ($window[0] + $window[2]) And $mouse[1] > $window[1] And $mouse[1] < ($window[1] + $window[3]) 
EndFunc

Func ProBot_IsPixelColorDisplayed($hwnd, Const $left, Const $top, Const $right, Const $bottom, Const $color, Const $variant = 1)
	If IsHWnd($hwnd) Then
		Opt("PixelCoordMode", 2)
		ProBot_ActivateWindow($hwnd)
        PixelSearch($left, $top, $right, $bottom, $color, $variant, 1, $hwnd)
		Return Not @error
	EndIf
	Return False
EndFunc

Func ProBot_ExtractText($hwnd, Const $left, Const $top, Const $right, Const $bottom, Const $scale = 2)
	If IsHWnd($hwnd) Then
		_TesseractTempPathSet(@TempDir & "\")
		Return _TesseractWinCapture(WinGetTitle($hwnd), "", 0, "", 1, $scale, $left, $top, $right, $bottom, 0)
	EndIf
	Return ""
EndFunc