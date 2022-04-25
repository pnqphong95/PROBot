#include-once
#include "ProConstant.au3"
Global $mknAppSettings = ObjCreate("Scripting.Dictionary")

Func mknLoadAppSetting(Const $settingPath)
    Local $section = "AppSettings"
    If FileExists($settingPath) Then
        Local $appSettings = IniReadSection($settingPath, $section)
        If Not @error Then
            For $i = 1 To $appSettings[0][0]
                Local $key = $appSettings[$i][0]
                Local $value = $appSettings[$i][1]
                $mknAppSettings.Item($key) = $value
                ConsoleWrite($settingPath & " loaded key [" & $key & "] = " & $value & @CRLF)
            Next
        EndIf
    Else
        Local $emptySettings
        IniWriteSection($settingPath, $section, $emptySettings)
    EndIf
EndFunc

Func mknAppSetting(Const $key)
    Return $mknAppSettings.Item($key)
EndFunc

;; Default app settings
$mknAppSettings.Add($APP_TITLE, "PROClient")
$mknAppSettings.Add($APP_BATTLE_HOLD_ON_NOTIFICATION, False)
$mknAppSettings.Add($APP_ACTION_1, "Z")
$mknAppSettings.Add($APP_ACTION_2, "X")
$mknAppSettings.Add($APP_ACTION_3, "C")
$mknAppSettings.Add($APP_ACTION_4, "V")
$mknAppSettings.Add($APP_ACTION_5, "B")
$mknAppSettings.Add($APP_ACTION_6, "N")