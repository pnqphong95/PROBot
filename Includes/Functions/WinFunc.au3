#include-once
#include "..\Libs\Tesseract.au3"
#include <File.au3>
#include <ScreenCapture.au3>

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

Func ProBot_MoveMouseIntoGameClient(Const $title) 
	Opt("MouseCoordMode", 2)
	Local $window = WinGetPos($title)
	MouseMove($window[0] + 5, $window[1] + 200, 5)
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

Func ProBot_TesseractWinScreenshot($hwnd, Const $left = 0, Const $top = 0, Const $right = 0, Const $bottom = 0, Const $scale = 2)
	If IsHWnd($hwnd) Then
		_TesseractTempPathSet(@TempDir & "\")
		Return _TesseractWinScreenshot(WinGetTitle($hwnd), "", $scale, $left, $top, $right, $bottom)
	EndIf
	Return ""
EndFunc

Func ProBot_TesseractWinTextRecognise($capture_filename, $delimiter = "", $cleanup = 1)
	Return _TesseractWinTextRecognise($capture_filename, $delimiter, $cleanup)
EndFunc

Func ProBot_MakeScreenshotArea($hwnd, Const $left, Const $top, Const $right, Const $bottom)
	Local $tempScreenshot = _TempFile(@TempDir & "\", "temp_screenshot_", ".jpg", Default)
	_ScreenCapture_CaptureWnd($tempScreenshot, $hwnd, $left, $top, $right, $bottom)
	Return $tempScreenshot
EndFunc

Func ProBot_MakeScreenshot($hwnd)
	Local $tempScreenshot = _TempFile(@TempDir & "\", "temp_screenshot_", ".jpg", Default)
	_ScreenCapture_CaptureWnd($tempScreenshot, $hwnd)
	Return $tempScreenshot
EndFunc