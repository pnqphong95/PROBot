#include-once
#include "..\Storage\GlobalStorage.au3"
#include "..\Storage\AppState.au3"

#cs ----------------------------------------------------------------------------

 Version: 0.1.0
 AutoIt Version: 3.3.16.0
 Author: pnqphong95
 Function: pbSpawnDirectionRelease
 Description: Release last direction key (LEFT, RIGHT, UP, DOWN) retrive from AppState.au3

#ce ----------------------------------------------------------------------------
Func pbSpawnDirectionRelease()
	Local $lastDirection = pbStateGet($APP_SPAWN_LAST_DIRECTION)
	If $lastDirection <> "" Then
		Send("{" & $lastDirection & " up}")
	EndIf
EndFunc

Func pbSpawnMoving()
	Local $shortest = getBotScripting($BOT_SPAWN_SHORT_PRESS)
	Local $longest = getBotScripting($BOT_SPAWN_LONG_PRESS)
	Local $randomPress = Random($shortest, $longest, 1)
	If pbStateGet($APP_SPAWN_LAST_DIRECTION) = "" Then
		Local $startDirection = getBotScripting($BOT_SPAWN_START_DIRECTION)
		If $startDirection <> "" Then
			pbStateSet($APP_SPAWN_LAST_DIRECTION, $startDirection)
		EndIf
	EndIf
	If pbStateGet($APP_SPAWN_LAST_DIRECTION) = "LEFT" Then
		Send("{RIGHT down}")
		Sleep($randomPress)
		pbStateSet($APP_SPAWN_LAST_DIRECTION, "RIGHT")
	ElseIf pbStateGet($APP_SPAWN_LAST_DIRECTION) = "RIGHT" Then
		Send("{LEFT down}")
		Sleep($randomPress)
		pbStateSet($APP_SPAWN_LAST_DIRECTION, "LEFT")
	ElseIf pbStateGet($APP_SPAWN_LAST_DIRECTION) = "UP" Then
		Send("{DOWN down}")
		Sleep($randomPress)
		pbStateSet($APP_SPAWN_LAST_DIRECTION, "DOWN")
	ElseIf pbStateGet($APP_SPAWN_LAST_DIRECTION) = "DOWN" Then
		Send("{UP down}")
		Sleep($randomPress)
		pbStateSet($APP_SPAWN_LAST_DIRECTION, "UP")
	EndIf
EndFunc