#include-once
#include <Array.au3>
#include "..\Functions\Logger.au3"
#include "..\Libs\CSVSplit.au3"

Global Const $BATTLE_INDICATOR_LEFT = "bot.battle.indicator.left"
Global Const $BATTLE_INDICATOR_TOP = "bot.battle.indicator.top"
Global Const $BATTLE_INDICATOR_RIGHT = "bot.battle.indicator.right"
Global Const $BATTLE_INDICATOR_BOTTOM = "bot.battle.indicator.bottom"
Global Const $BATTLE_INDICATOR_COLOR_HEX= "bot.battle.indicator.colorhex"
Global Const $ACTION_INDICATOR_LEFT = "bot.battle.action.indicator.left"
Global Const $ACTION_INDICATOR_TOP = "bot.battle.action.indicator.top"
Global Const $ACTION_INDICATOR_RIGHT = "bot.battle.action.indicator.right"
Global Const $ACTION_INDICATOR_BOTTOM = "bot.battle.action.indicator.bottom"
Global Const $ACTION_INDICATOR_COLOR_HEX= "bot.battle.action.indicator.colorhex"
Global Const $TITLE_INDICATOR_LEFT = "bot.battle.title.indicator.left"
Global Const $TITLE_INDICATOR_TOP = "bot.battle.title.indicator.top"
Global Const $TITLE_INDICATOR_RIGHT = "bot.battle.title.indicator.right"
Global Const $TITLE_INDICATOR_BOTTOM = "bot.battle.title.indicator.bottom"
Global Const $LOG_INDICATOR_LEFT = "bot.battle.log.indicator.left"
Global Const $LOG_INDICATOR_TOP = "bot.battle.log.indicator.top"
Global Const $LOG_INDICATOR_RIGHT = "bot.battle.log.indicator.right"
Global Const $LOG_INDICATOR_BOTTOM = "bot.battle.log.indicator.bottom"
Global Const $PREVIEW_INDICATOR_LEFT = "bot.battle.caught-preview.indicator.left"
Global Const $PREVIEW_INDICATOR_TOP = "bot.battle.caught-preview.indicator.top"
Global Const $PREVIEW_INDICATOR_RIGHT = "bot.battle.caught-preview.indicator.right"
Global Const $PREVIEW_INDICATOR_BOTTOM = "bot.battle.caught-preview.indicator.bottom"
Global Const $MOVE_LIST_INDICATOR_LEFT = "bot.battle.move-list.indicator.left"
Global Const $MOVE_LIST_INDICATOR_TOP = "bot.battle.move-list.indicator.top"
Global Const $MOVE_LIST_INDICATOR_RIGHT = "bot.battle.move-list.indicator.right"
Global Const $MOVE_LIST_INDICATOR_BOTTOM = "bot.battle.move-list.indicator.bottom"
Global Const $MOVE_POINT_INDICATOR_LEFT = "bot.battle.move-point.indicator.left"
Global Const $MOVE_POINT_INDICATOR_RIGHT = "bot.battle.move-point.indicator.right"
Global Const $FIRST_PARTY_INDICATOR_X = "bot.party.first.indicator.x"
Global Const $FIRST_PARTY_INDICATOR_Y = "bot.party.first.indicator.y"
Global Const $FIRST_PARTY_INDICATOR_SPACE = "bot.party.first.indicator.space"
Global Const $FIRST_PARTY_COLOR = "bot.party.first.color"
Global Const $ACTION_KEY_1 = "bot.battle.action.keybinding1"
Global Const $ACTION_KEY_2 = "bot.battle.action.keybinding2"
Global Const $ACTION_KEY_3 = "bot.battle.action.keybinding3"
Global Const $ACTION_KEY_4 = "bot.battle.action.keybinding4"
Global Const $REPORT_BOT_URL = "bot.report.telegram-bot-url"
Global Const $REPORT_CHAT_ID = "bot.report.telegram-chat-id"
Global $Settings = ObjCreate("Scripting.Dictionary")
Global $DataPokemonTypes
Global $DataTypeChart
Global $DataPokemonMoves

;Default battle indicator coordinators
$Settings.Item($BATTLE_INDICATOR_LEFT) = 360
$Settings.Item($BATTLE_INDICATOR_TOP) = 176
$Settings.Item($BATTLE_INDICATOR_RIGHT) = 1000
$Settings.Item($BATTLE_INDICATOR_BOTTOM) = 178
$Settings.Item($BATTLE_INDICATOR_COLOR_HEX) = 0x282528

;Default battle action indicator coordinators
$Settings.Item($ACTION_INDICATOR_LEFT) = 1020
$Settings.Item($ACTION_INDICATOR_TOP) = 595
$Settings.Item($ACTION_INDICATOR_RIGHT) = 1025
$Settings.Item($ACTION_INDICATOR_BOTTOM) = 596
$Settings.Item($ACTION_INDICATOR_COLOR_HEX) = 0x7F7F7F

;Default battle title indicator coordinators
$Settings.Item($TITLE_INDICATOR_LEFT) = 480
$Settings.Item($TITLE_INDICATOR_TOP) = 240
$Settings.Item($TITLE_INDICATOR_RIGHT) = 1180
$Settings.Item($TITLE_INDICATOR_BOTTOM) = 290

;Default battle log indicator coordinators
$Settings.Item($LOG_INDICATOR_LEFT) = 320
$Settings.Item($LOG_INDICATOR_TOP) = 900
$Settings.Item($LOG_INDICATOR_RIGHT) = 920
$Settings.Item($LOG_INDICATOR_BOTTOM) = 1000

;Default caught preview indicator coordinators
$Settings.Item($PREVIEW_INDICATOR_LEFT) = 888
$Settings.Item($PREVIEW_INDICATOR_TOP) = 265
$Settings.Item($PREVIEW_INDICATOR_RIGHT) = 1185
$Settings.Item($PREVIEW_INDICATOR_BOTTOM) = 555

;Default move list indicator coordinators
$Settings.Item($MOVE_LIST_INDICATOR_LEFT) = 1325
$Settings.Item($MOVE_LIST_INDICATOR_TOP) = 290
$Settings.Item($MOVE_LIST_INDICATOR_RIGHT) = 1500
$Settings.Item($MOVE_LIST_INDICATOR_BOTTOM) = 550
$Settings.Item($MOVE_POINT_INDICATOR_LEFT) = 1660
$Settings.Item($MOVE_POINT_INDICATOR_RIGHT) = 1730

;Default party 1 indicator coordinators
$Settings.Item($FIRST_PARTY_INDICATOR_X) = 46
$Settings.Item($FIRST_PARTY_INDICATOR_Y) = 51
$Settings.Item($FIRST_PARTY_INDICATOR_SPACE) = 55
$Settings.Item($FIRST_PARTY_COLOR) = 0x504D4D

;Default battle action key bindings
$Settings.Item($ACTION_KEY_1) = "Z"
$Settings.Item($ACTION_KEY_2) = "X"
$Settings.Item($ACTION_KEY_3) = "C"
$Settings.Item($ACTION_KEY_4) = "V"

;Default report channel
$Settings.Item($REPORT_BOT_URL) = ""
$Settings.Item($REPORT_CHAT_ID) = ""

Func ProBot_LoadExternalSettings(Const $file)
	If Not FileExists($file) Then
		ProBot_Log("Use default setting, external file not exist " & $file)
        For $key In $Settings
            IniWrite($file, "Settings", $key, $Settings.Item($key))
        Next
		Return
	EndIf
	Local $externalSettings = IniReadSection($file, "Settings")
	If @error Or $externalSettings[0][0] = 0 Then
		ProBot_Log("Use default setting, external file corrupted or empty " & $file)
        For $key In $Settings
			IniWrite($file, "Settings", $key, $Settings.Item($key))
        Next
		Return
	EndIf
	For $i = 1 To $externalSettings[0][0]
		Local $key = $externalSettings[$i][0]
		If $Settings.Exists($key) Then
			Local $newValue = $externalSettings[$i][1]
			Local $oldValue = $Settings.Item($key)
			$Settings.Item($key) = $newValue
		EndIf
	Next
EndFunc

Func ProBot_LoadPokemonTypeData(Const $pokemonTypeCsv)
	$DataPokemonTypes = _LoadCsvToArray($pokemonTypeCsv)
	_ArraySort($DataPokemonTypes, 0, 0, 0, 1)
EndFunc

Func ProBot_LoadPokemonTypeChartData(Const $typeChartCsv)
	$DataTypeChart = _LoadCsvToArray($typeChartCsv)
	_ArraySort($DataTypeChart)
EndFunc

Func ProBot_LoadPokemonMoves(Const $moveCsv)
	$DataPokemonMoves= _LoadCsvToArray($moveCsv)
	_ArraySort($DataPokemonMoves)
EndFunc

Func _LoadCsvToArray(Const $csvPath)
	Local $csvFile = FileOpen($csvPath)
	If $csvFile = -1 Then
		ConsoleWrite("Unable to open file " & $csvPath)
		Exit
	EndIf
	Local $csvString = FileRead($csvFile)
	If @error Then
		ConsoleWrite("Unable to read file" & $csvPath)
		FileClose($csvFile)
		Exit
	EndIf
	FileClose($csvFile)
	Local $csvArray = _CSVSplit($csvString, ",")
	If @error Then
		ConsoleWrite("Unable to parse to CSV, file " & $csvPath & @error & @LF)
		Exit
	EndIf
	Return $csvArray
EndFunc



