#include-once
#include "Includes\Storage\BotSetting.au3"
#include "Includes\Storage\AppState.au3"

#cs ----------------------------------------------------------------------------

 Version: 0.1.0
 AutoIt Version: 3.3.16.0
 Author: pnqphong95
 Function: mknSpawnDirectionRelease
 Description: Release last direction key (LEFT, RIGHT, UP, DOWN) retrive from AppState.au3

#ce ----------------------------------------------------------------------------
Func mknSpawnDirectionRelease()
	Local $lastDirection = mknStateGet($APP_SPAWN_LAST_DIRECTION)
	If $lastDirection <> "" Then
		Send("{" & $lastDirection & " up}")
	EndIf
EndFunc

Func mknSpawnMoving()
	Local $shortest = mknBotSettingGet($APP_SPAWN_SHORTEST_PRESS)
	Local $longest = mknBotSettingGet($APP_SPAWN_LONGEST_PRESS)
	Local $randomPress = Random($shortest, $longest, 1)
	If mknStateGet($APP_SPAWN_LAST_DIRECTION) = "" Then
		Local $startDirection = mknBotSettingGet($APP_SPAWN_START_DIRECTION)
		If $startDirection <> "" Then
			mknStateSet($APP_SPAWN_LAST_DIRECTION, $startDirection)
		EndIf
	EndIf
	If mknStateGet($APP_SPAWN_LAST_DIRECTION) = "LEFT" Then
		Send("{RIGHT down}")
		Sleep($randomPress)
		mknStateSet($APP_SPAWN_LAST_DIRECTION, "RIGHT")
	ElseIf mknStateGet($APP_SPAWN_LAST_DIRECTION) = "RIGHT" Then
		Send("{LEFT down}")
		Sleep($randomPress)
		mknStateSet($APP_SPAWN_LAST_DIRECTION, "LEFT")
	ElseIf mknStateGet($APP_SPAWN_LAST_DIRECTION) = "UP" Then
		Send("{DOWN down}")
		Sleep($randomPress)
		mknStateSet($APP_SPAWN_LAST_DIRECTION, "DOWN")
	ElseIf mknStateGet($APP_SPAWN_LAST_DIRECTION) = "DOWN" Then
		Send("{UP down}")
		Sleep($randomPress)
		mknStateSet($APP_SPAWN_LAST_DIRECTION, "UP")
	EndIf
EndFunc