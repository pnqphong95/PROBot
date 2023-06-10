#include-once
#include <Date.au3>

Func ProBot_Log(Const $msg)
	Local $formattedMsg = StringReplace(StringReplace($msg, @LF, ""), @CRLF, "")
	ConsoleWrite("[" & _NowTime(5) & "] " & $formattedMsg & @CRLF)
EndFunc