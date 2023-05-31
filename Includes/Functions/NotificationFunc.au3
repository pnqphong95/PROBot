#include-once

Func ProBot_Notify(Const $BotUrl, Const $ChatId, Const $TextMessage)
	ConsoleWrite("[Notification] Message=" & $TextMessage)
	If $BotUrl <> "" And $ChatId <> "" And $TextMessage <> "" Then
		Local $MessageApiUrl = $BotUrl & "/sendMessage"
		Local $MessageBody = '{ \"chat_id\": \"' & $ChatId & '\", \"text\": \"' & $TextMessage & '\", \"disable_notification\": false}'
		ShellExecute(@SystemDir & "\curl.exe", '-XPOST -H "Content-Type: application/json" -d "' & $MessageBody & '" ' & $MessageApiUrl, "", "", @SW_HIDE)
	EndIf
EndFunc