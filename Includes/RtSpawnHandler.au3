#include-once
#include "Storage\BotSetting.au3"
#include "Storage\SessionVariable.au3"

Func ProBot_ReleaseSpawnKey()
	Local $spawnDirection = $SessionVariables.Item($RT_SPAWN_LAST_DIRECTION)
	If $spawnDirection <> "" Then
		Send("{" & $spawnDirection & " up}")
	EndIf
EndFunc

Func ProBot_PressSpawnKey()
	Local $minDistance = $SessionVariables.Item($SPAWN_MIN)
	Local $maxDistance = $SessionVariables.Item($SPAWN_MAX)
	Local $distance = Random($minDistance, $maxDistance, 1)
	If $SessionVariables.Item($RT_SPAWN_LAST_DIRECTION) = "" Then
		Local $initialValue = $SessionVariables.Item($SPAWN_INITIAL_DIRECTION)
		If $initialValue <> "" Then
			$SessionVariables.Item($RT_SPAWN_LAST_DIRECTION) = $initialValue
		Else
			$SessionVariables.Item($RT_SPAWN_LAST_DIRECTION) = "LEFT"
		EndIf
	EndIf
	If $SessionVariables.Item($RT_SPAWN_LAST_DIRECTION) = "LEFT" Then
		Send("{RIGHT down}")
		$SessionVariables.Item($RT_SPAWN_LAST_DIRECTION) = "RIGHT"
	ElseIf $SessionVariables.Item($RT_SPAWN_LAST_DIRECTION) = "RIGHT" Then
		Send("{LEFT down}")
		$SessionVariables.Item($RT_SPAWN_LAST_DIRECTION) = "LEFT"
	ElseIf $SessionVariables.Item($RT_SPAWN_LAST_DIRECTION) = "UP" Then
		Send("{DOWN down}")
		$SessionVariables.Item($RT_SPAWN_LAST_DIRECTION) = "DOWN"
	ElseIf $SessionVariables.Item($RT_SPAWN_LAST_DIRECTION) = "DOWN" Then
		Send("{UP down}")
		$SessionVariables.Item($RT_SPAWN_LAST_DIRECTION) = "UP"
	Else
		$SessionVariables.Item($RT_SPAWN_LAST_DIRECTION) = ""
	EndIf
	Sleep($distance)
EndFunc