#include <MsgBoxConstants.au3>

Local $window = WinGetPos("PROClient")
Local $mouse = MouseGetPos()
MsgBox($MB_SYSTEMMODAL, "", "Inside = " & ($mouse[0] > $window[0] And $mouse[0] < ($window[0] + $window[2]) And $mouse[1] > $window[1] And $mouse[1] < ($window[1] + $window[3])))