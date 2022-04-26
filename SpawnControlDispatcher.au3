#include-once
#include "Includes\Storage\AppState.au3"

#cs ----------------------------------------------------------------------------

 Version: 0.1.0
 AutoIt Version: 3.3.16.0
 Author: pnqphong95
 Function: mknSpawnDirectionRelease
 Description: Release last direction key (LEFT, RIGHT, UP, DOWN) retrive from AppState.au3

#ce ----------------------------------------------------------------------------
Func mknSpawnDirectionRelease()
	Send("{" & mknStateGet($APP_SPAWN_LAST_DIRECTION) & " up}")
EndFunc

Func mknSpawnMoving(Const $lowest, Const $highest)
	Local $randomPress = Random($lowest, $highest, 1)
	If mknStateGet($APP_SPAWN_LAST_DIRECTION) = "" Then
		mknStateSet($APP_SPAWN_LAST_DIRECTION, "LEFT")
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