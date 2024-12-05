@tool
extends Node
#based off of textify's plubin

var authToken = Env.gptKey # View docs for more info
var effect
var recording
const save_path = "res://temp/spellcast/tempWav.wav"
const whisper_url = "https://api.openai.com/v1/audio/transcriptions"


func _ready():
	var idx = AudioServer.get_bus_index("Record")
	effect = AudioServer.get_bus_effect(idx, 0)

func processRequest(data):
	var headers = [
		"Authorization: Bearer %s" % authToken,
		"Content-Type: multipart/form-data",
		
	]
	var boundary = "Boundary12345"
	var payload = "--%s\r\nContent-Disposition: form-data; name=\"file\"; filename=\"audio.wav\"\r\nContent-Type: audio/wav\r\n\r\n%s\r\n--%s--\r\n" % [boundary, data.get_string_from_utf8(), boundary]

	$HTTPRequest.request(whisper_url, headers, HTTPClient.METHOD_POST, payload, boundary)

func _on_http_request_request_completed(_result, response_code, _headers, body):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	
	var response = json.get_data()
	if response_code == 503:
		printerr(response)
		WhisperGlobal.emit_signal("loading", response["estimated_time"])
		$Timer.start()
	else:
		if response != null:
			WhisperGlobal.emit_signal("whisper_recieved", response["text"].strip_edges())
		else:
			WhisperGlobal.emit_signal("error", "error in the response")
			printerr("gpted-Textify: There was an error with processing your request. Your audio file was probably too big.")

func start_recording():
	effect.set_recording_active(true)

func stop_recording():
	recording = await effect.get_recording()
	effect.set_recording_active(false)
	await recording.save_to_wav(save_path)
	var file := FileAccess.open(save_path, FileAccess.READ)
	if file:
		var data := file.get_buffer(file.get_length())
		processRequest(data)
	else:
		WhisperGlobal.emit_signal("error", "Failed to read the specified file.")

func parse_file(fileLocation):
	var file := FileAccess.open(fileLocation, FileAccess.READ)
	if file:
		var data := file.get_buffer(file.get_length())
		processRequest(data)
	else:
		WhisperGlobal.emit_signal("error", "Failed to read the specified file.")


func _on_timer_timeout():
	stop_recording()
