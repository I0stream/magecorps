extends Node3D

var spell_action: String = "spell_action"

func _ready():
	get_viewport().use_xr = true
	var xr_interface = XRServer.find_interface("OpenXR")
	GameController.connect("playerWon", _on_win)
	if xr_interface:
		xr_interface.initialize()
	else:
		print("OpenXR interface not found.")

func record_audio():
	$Whisper.start_recording()

func end_recording():
	$Whisper.stop_recording()

func _on_win() -> void:
	$XROrigin3D/WinUI.show

func _on_button_pressed(name: String):
	if name == spell_action:
		record_audio()


func _on_button_released(name: String):
	if name == spell_action:
		end_recording()
