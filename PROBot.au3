#AutoIt3Wrapper_UseX64=Y
#AutoIt3Wrapper_Change2CUI=Y
#AutoIt3Wrapper_OutFile=Probot.exe
#AutoIt3Wrapper_Icon=Metadata\command-line_115191.ico
#include <Misc.au3>
#include <MsgBoxConstants.au3>
#include "Includes\Storage\SessionFunc.au3"
#include "Includes\Functions\WindowFunc.au3"
#include "Includes\RuntimeSpawnHandler.au3"
#include "Includes\RuntimeBattleHandler.au3"

If _Singleton(@ScriptName, 1) = 0 Then
    MsgBox($MB_SYSTEMMODAL, @ScriptName, "The bot already running!")
    Exit
EndIf

While 1
	If ProBot_IsMouseHoverGameClient("PROClient") Then
		Local $hwnd = ProBot_ClientWindow("PROClient")
		If Not $hwnd Or $hwnd = '' Then
			MsgBox($MB_SYSTEMMODAL, "Unable to start bot", "Looks like more than one client is running or not stared.")
			ExitLoop
		EndIf
		ProBot_CaptureGameState($hwnd)
		ProBot_ReleaseSpawnKey()
		If $SessionVariables.Item($RT_ON_BATTLE_VISIBLE) Then
			ProBot_EvaluateGameState($hwnd)
			ProBot_DelegateHandler($hwnd)
			ContinueLoop
		Else
			ProBot_PressSpawnKey()
		EndIf
	Else
		Sleep(5000)
	EndIf
WEnd