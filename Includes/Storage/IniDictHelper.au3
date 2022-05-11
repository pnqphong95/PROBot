#include-once

Func loadIniSection($dictionary, Const $path, Const $section)
    If Not FileExists($path) Then
        ConsoleWrite($path & @CRLF & "File doesn't exist. Auto-create " & $section & " with default value!" & @CRLF)
        For $key In $dictionary
            IniWrite($path, $section, $key, $dictionary.Item($key))
        Next
        Return
    EndIf
    Local $settingSection = IniReadSection($path, $section)
    If @error Or $settingSection[0][0] = 0 Then
        ConsoleWrite($path & @CRLF & $section & " is corrupted or empty. Auto-create " & $section & " setting with default value!" & @CRLF)
        For $key In $dictionary
            IniWrite($path, $section, $key, $dictionary.Item($key))
        Next
        Return
    EndIf
    For $i = 1 To $settingSection[0][0]
        Local $key = $settingSection[$i][0]
        Local $overwrittenValue = $settingSection[$i][1]
        Local $oldValue = $dictionary.Item($key)
        If $overwrittenValue <> "" And $overwrittenValue <> $oldValue Then
            Local $oldValue = $dictionary.Item($key)
            $dictionary.Item($key) = $overwrittenValue
            ConsoleWrite("Resolved [" & $section & "] " & $key & " = " & $overwrittenValue & @CRLF)
        Else
            ConsoleWrite("Resolved [" & $section & "] " & $key & " = " & $oldValue & @CRLF)
        EndIf
    Next
EndFunc