#include <Misc.au3>
#include <MsgBoxConstants.au3>
#include <Tesseract.au3>

Local $user32Lib = DllOpen("user32.dll")
Local $running = False
Local $battle = False

While 1
	Local $battleSwitchOn = False

	; Check if PROClient is opened, then activate it
	Local $client = WinGetHandle("PROClient")
	If @error Then
		$running = False
		$battle = False
		ContinueLoop
	Else
		WinActivate("PROClient", "")
	EndIf

	; Search pixel of battle dialog
	Opt("PixelCoordMode", 2)
	Local $battleDialog = PixelSearch(380, 155, 1000, 160, 0x282528, 1, 1, $client)
	If Not @error  Then
		If Not $battle Then
			ConsoleWrite ("Battle started!" & @CRLF)
			$battleSwitchOn = True
			$battle = True
		EndIf
	Else
		If $battle Then
			ConsoleWrite ("Battle ended!" & @CRLF)
			$battle = False
		EndIf
	EndIf

	; Capture pokemon name
	If $battleSwitchOn Then
		MsgBox($MB_SYSTEMMODAL, "Information", "Battle started!")
	EndIf

	If $battle Then
		; Continue the loop, leave control the battle to user
		ContinueLoop
	Else
		; Find the pokemon
		If $running Or _IsPressed("25", $user32Lib) Or _IsPressed("26", $user32Lib) Or _IsPressed("27", $user32Lib) Or _IsPressed("28", $user32Lib) Then
			Send("{Right Down}")
			Sleep(Random(800, 1400, 1))
			Send("{Left Down}")
			Sleep(Random(0, 100, 1))
			Send("{Right Up}")
			Sleep(Random(800, 1200, 1))
			Send("{Left Up}")
			$running = True
		EndIf
	EndIf

WEnd

DllClose($user32Lib)