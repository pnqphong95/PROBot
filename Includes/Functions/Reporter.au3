#include-once
#include <Logger.au3>
#include "..\Storage\BotSetting.au3"
#include "..\Storage\SessionVariable.au3"

Func ProBot_Notify(Const $TextMessage = "", Const $Photo = "")
	Local $BotUrl = $Settings.Item($REPORT_BOT_URL)
	Local $ChatId = $Settings.Item($REPORT_CHAT_ID)
	If $SessionVariables.Item($REPORT_ENABLE) <> 1 Then
		ProBot_Log("Skip message as feature disabled.")
		Return
	EndIf
	If $BotUrl = "" Or $ChatId = "" Then
		ProBot_Log("Skip message as telegram bot and chat id not setup.")
		Return
	EndIf
	If $Photo <> "" And FileExists($Photo) Then
		Local $PhotoApiUrl = $BotUrl & "/sendPhoto"
		Local $Params =  '-F "photo=@' & $Photo & '" -F "chat_id=\"' & $ChatId & '\"" -F "caption=\"' & $TextMessage & '\""'
		ShellExecute(@SystemDir & "\curl.exe", '-XPOST "' & $PhotoApiUrl & '" ' & $Params, "", "", @SW_HIDE)
		Return
	EndIf
	If $TextMessage <> "" Then
		Local $MessageApiUrl = $BotUrl & "/sendMessage"
		Local $MessageBody = '{ \"chat_id\": \"' & $ChatId & '\", \"text\": \"' & $TextMessage & '\", \"disable_notification\": false}'
		ShellExecute(@SystemDir & "\curl.exe", '-XPOST -H "Content-Type: application/json" -d "' & $MessageBody & '" ' & $MessageApiUrl, "", "", @SW_HIDE)
		Return
	EndIf
	ProBot_Log("Skip message as provide empty message & no photo.")
EndFunc