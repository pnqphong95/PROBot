#AutoIt3Wrapper_UseX64=Y
#AutoIt3Wrapper_Change2CUI=Y
#AutoIt3Wrapper_OutFile=Build\Probot.exe
#AutoIt3Wrapper_Icon=Metadata\Probot.ico

#include <Misc.au3>
#include <MsgBoxConstants.au3>
#include "Includes\Storage\BotSetting.au3"
#include "Includes\Storage\SessionVariable.au3"
#include "Includes\Storage\CmdLineParam.au3"
#include "Includes\Functions\WinFunc.au3"
#include "Includes\Functions\Logger.au3"
#include "Includes\RtSpawnHandler.au3"
#include "Includes\RtBattleHandler.au3"
#include "Includes\RtActionHandler.au3"

; Exit when another bot instance is running
If _Singleton(@ScriptName, 1) = 0 Then
    ProBot_Log("Aborted, close other instances and retry!")
	Exit
EndIf

ProBot_LoadExternalSettings(@WorkingDir & "\Probot.ini")
ProBot_LoadPokemonTypeData(@WorkingDir & "\GameData\pokemon_types.csv")
ProBot_LoadPokemonTypeChartData(@WorkingDir & "\GameData\type_chart.csv")
ProBot_LoadPokemonMoves(@WorkingDir & "\GameData\moves.csv")
ProBot_ParseCmdLineParams($CmdLine)
ProBot_ValidateCmdLineParams()
ProBot_LoadSessionVariables($CmdLineParams.Item("vf"))

While 1
    Local $hwnd = ProBot_ClientWindow("PROClient", False)
	If Not $hwnd Or $hwnd = '' Then
		ProBot_Log("PENDING, waiting for PROClient get opened.")
        Sleep(10000)
	ElseIf Not ProBot_IsMouseHoverGameClient("PROClient") Then
        ProBot_ReleaseSpawnKey()
        ProBot_Log("PENDING, waiting for cursor place inside PROClient.")
        Sleep(5000)
	Else
		ProBot_CaptureGameState($hwnd)
		ProBot_ReleaseSpawnKey()
		If $SessionVariables.Item($RT_ON_BATTLE_VISIBLE) Then
			ProBot_EvaluateGameState($hwnd)
			ProBot_DelegateActionHandler($hwnd)
			ContinueLoop
		Else
			ProBot_PressSpawnKey()
		EndIf
	EndIf
WEnd