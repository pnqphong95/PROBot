 #AutoIt3Wrapper_UseX64=Y

#include <MsgBoxConstants.au3>

Local $hwnds = WinList("PROClient")
Local $instanceNum = $hwnds[0][0]
If $instanceNum = 1 Then
	Local $hwnd = $hwnds[1][1]
	If Not WinActive($hwnd) Then
		WinActivate($hwnd)
	EndIf
	Opt("PixelCoordMode", 2)
	Local $result = PixelSearch(1020, 595, 1025, 596, 0x7F7F7F, 2, 1, $hwnd)
	If Not @error Then
		MsgBox($MB_SYSTEMMODAL, "", $hwnd & " .Found pixel at: " & $result[0] & "," & $result[1])
	EndIf
;~ 	Local $iColor = PixelGetColor(1020, 595)
;~ 	MsgBox($MB_SYSTEMMODAL, "", $hwnd & " .The hex color is: " & Hex($iColor, 6))
EndIf