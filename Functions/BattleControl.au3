#include-once
#include "WndHelper.au3"
#include "Storage\AppSetting.au3"

#cs ----------------------------------------------------------------------------

 Version: 0.1.0
 AutoIt Version: 3.3.16.0
 Author: pnqphong95
 Function: mknBattleIsDisplayed
 Description: Search if battle dialog is displayed on given window screen.
 Settings: Read settings coordinator x, y, width, height from MonKnife.ini

#ce ----------------------------------------------------------------------------
Func mknBattleIsDisplayed($hnwd)
	If IsHWnd($hnwd) Then
		; Sets the way coords are used in the pixel search functions.
		; 2 =  relative coords to the client area of the defined window.
		activateWindow($hnwd)
		Opt("PixelCoordMode", 2)
		Local $color = mknAppSettingGet($APP_BATTLE_IDENTIFIER_COLOR)
        Local $xCoor = mknAppSettingGet($APP_BATTLE_IDENTIFIER_X)
        Local $yCoor = mknAppSettingGet($APP_BATTLE_IDENTIFIER_Y)
        Local $width = mknAppSettingGet($APP_BATTLE_IDENTIFIER_W)
        Local $height = mknAppSettingGet($APP_BATTLE_IDENTIFIER_H)
        Local $battleDialogCoor = PixelSearch($xCoor, $yCoor, $xCoor + $width, $yCoor + $height, $color, 1, 1, $hnwd)
		Return Not @error
	EndIf
	Return False
EndFunc