extends Node

var api_base: String = "http://10.0.0.95:11434"
var text_endpoint: String = "/v1/generate"
var image_endpoint: String = "/v1/image"

func _safe_request(req: HTTPRequest, url: String, headers: PackedStringArray, body: String) -> int:
	# Inspect the available 'request' method signature on the HTTPRequest instance and
	# choose a compatible call variant. This avoids try/except and works across builds.
	var method_list = req.get_method_list()
	var request_info = null
	for m in method_list:
		if m.has("name") and m["name"] == "request":
			request_info = m
			extends Node

			var api_base: String = "http://10.0.0.95:11434"
			var text_endpoint: String = "/v1/generate"
			var image_endpoint: String = "/v1/image"

			func _safe_request(req: HTTPRequest, url: String, headers: PackedStringArray, body: String) -> int:
				# ...existing code...

			func _init():
				pass

			func _ready() -> void:
				pass

			func _make_request(path: String, body: String, headers: PackedStringArray = []) -> Array:
				# ...existing code...

			func is_available(timeout_seconds: int = 4) -> bool:
				# ...existing code...

			func request_character(prompt: String) -> String:
				var text = await request_text(prompt, 512)
				return text

			func request_text(prompt: String, max_tokens: int = 256, timeout_seconds: int = 15, history: Array = []) -> String:
				# ...existing code...

			func request_image(prompt: String, width: int = 512, height: int = 512) -> String:
				# ...existing code...

		func _init():
			pass

		func _ready() -> void:
			pass

		func _make_request(path: String, body: String, headers: PackedStringArray = []) -> Array:
			# ...existing code...

		func is_available(timeout_seconds: int = 4) -> bool:
			# ...existing code...

		func request_character(prompt: String) -> String:
			var text = await request_text(prompt, 512)
			return text

		func request_text(prompt: String, max_tokens: int = 256, timeout_seconds: int = 15, history: Array = []) -> String:
			var body_dict = {}
			if history.size() > 0:
				body_dict["messages"] = history.duplicate(true)
				body_dict["messages"].append({"role": "user", "content": prompt})
			else:
				body_dict["prompt"] = prompt
			body_dict["max_tokens"] = max_tokens

			var body: String = JSON.print(body_dict)
			var headers: PackedStringArray = ["Content-Type: application/json"]
			print("AIAdapter: request_text ->", api_base + text_endpoint)
			print("AIAdapter: payload ->", body)
			var res = await _make_request(text_endpoint, body, headers)
			if res.size() == 0:
				print("AIAdapter: no response")
				return ""
			var response_code: int = int(res[1])
			var raw_body = res[3]
			var text: String = ""
			var s: String = ""
			if typeof(raw_body) == TYPE_PACKED_BYTE_ARRAY:
				s = raw_body.get_string_from_utf8()
			else:
				s = str(raw_body)

			var json = JSON.new()
			var parsed = json.parse(s)
			if parsed == OK and json.get_data():
				var obj = json.get_data()
				if obj.has("output"):
					extends Node

					var api_base: String = "http://10.0.0.95:11434"
					var text_endpoint: String = "/v1/generate"
					var image_endpoint: String = "/v1/image"

					func _init():
						pass

					func _ready() -> void:
						pass

					func _make_request(path: String, body: String, headers: PackedStringArray = []) -> Array:
						var req = HTTPRequest.new()
						add_child(req)
						var err = req.request(api_base + path, headers, false, HTTPClient.METHOD_POST, body)
						if err != OK:
							print("AIAdapter: request error", err)
							req.queue_free()
							return []
						var timer = 0
						extends Node

						var api_base: String = "http://10.0.0.95:11434"
						var text_endpoint: String = "/v1/generate"
						var image_endpoint: String = "/v1/image"

						func _init():
							pass

						func _ready() -> void:
							pass

						func _make_request(path: String, body: String, headers: PackedStringArray = []) -> Array:
							var req = HTTPRequest.new()
							add_child(req)
							var err = req.request(api_base + path, headers, false, HTTPClient.METHOD_POST, body)
							if err != OK:
								print("AIAdapter: request error", err)
								req.queue_free()
								return []
							var timer = 0
							while req.get_http_client_status() == HTTPClient.STATUS_REQUESTING and timer < 20:
								timer += 1
								await get_tree().create_timer(0.5).timeout
							var result = [req.get_http_client_status(), req.get_response_code(), req.get_response_headers(), req.get_body_as_bytes()]
							req.queue_free()
							return result

						func is_available(timeout_seconds: int = 4) -> bool:
							var req = HTTPRequest.new()
							add_child(req)
							var err = req.request(api_base + "/", [], false, HTTPClient.METHOD_GET)
							if err != OK:
								req.queue_free()
								return false
							var timer = 0
							while req.get_http_client_status() == HTTPClient.STATUS_REQUESTING and timer < timeout_seconds * 2:
								timer += 1
								await get_tree().create_timer(0.5).timeout
							var status = req.get_http_client_status()
							req.queue_free()
							return status == HTTPClient.STATUS_BODY

						func request_character(prompt: String) -> String:
							var text = await request_text(prompt, 512)
							return text

						func request_text(prompt: String, max_tokens: int = 256, timeout_seconds: int = 15, history: Array = []) -> String:
							var body_dict = {}
							if history.size() > 0:
								body_dict["messages"] = history.duplicate(true)
								body_dict["messages"].append({"role": "user", "content": prompt})
							else:
								body_dict["prompt"] = prompt
							body_dict["max_tokens"] = max_tokens

							var body: String = JSON.print(body_dict)
							var headers: PackedStringArray = ["Content-Type: application/json"]
							print("AIAdapter: request_text ->", api_base + text_endpoint)
							print("AIAdapter: payload ->", body)
							var res = await _make_request(text_endpoint, body, headers)
							if res.size() == 0:
								print("AIAdapter: no response")
								return ""
							var response_code: int = int(res[1])
							var raw_body = res[3]
							var s: String = ""
							if typeof(raw_body) == TYPE_PACKED_BYTE_ARRAY:
								s = raw_body.get_string_from_utf8()
							else:
								s = str(raw_body)

							var json = JSON.new()
							var parsed = json.parse(s)
							var text: String = ""
							if parsed == OK and json.get_data():
								var obj = json.get_data()
								if obj.has("output"):
									text = str(obj["output"])
								elif obj.has("text"):
									text = str(obj["text"])
								elif obj.has("choices") and obj["choices"].size() > 0 and obj["choices"][0].has("text"):
									text = str(obj["choices"][0]["text"])
								elif obj.has("results") and obj["results"].size() > 0:
									var r0 = obj["results"][0]
									if typeof(r0) == TYPE_DICTIONARY and r0.has("text"):
										text = str(r0["text"])
								elif obj.has("message") and typeof(obj["message"]) == TYPE_DICTIONARY and obj["message"].has("content"):
									text = str(obj["message"]["content"])
							else:
								text = s

							print("AIAdapter: response code:", response_code)
							print("AIAdapter: raw response:", s)
							print("AIAdapter: extracted text:", text)
							return text

						func request_image(prompt: String, width: int = 512, height: int = 512) -> String:
							var sd_path = "/sdapi/v1/txt2img"
							var body_dict = {"prompt": prompt, "width": width, "height": height}
							var body: String = JSON.print(body_dict)
							var headers: PackedStringArray = ["Content-Type: application/json"]
							var res = await _make_request(sd_path, body, headers)
							if res.size() == 0:
								return ""
							var raw_body = res[3]
							var s: String = raw_body.get_string_from_utf8() if typeof(raw_body) == TYPE_PACKED_BYTE_ARRAY else str(raw_body)
							var json = JSON.new()
							var parsed = json.parse(s)
							print("AIAdapter: raw response:", s)
							if parsed == OK and json.get_data() and json.get_data().has("images"):
								var images = json.get_data()["images"]
								if images.size() > 0:
									var b64: String = str(images[0])
									var data = Marshalls.base64_to_raw(b64)
									var img = Image.new()
									var err = img.load_png_from_buffer(data)
									if err == OK:
										var timestamp: int = int(OS.get_unix_time())
										var path: String = "user://companions/portraits/%d.png" % timestamp
										DirAccess.make_dir_recursive_absolute("user://companions/portraits/")
										img.save_png(path)
										print("AIAdapter: extracted image path:", path)
										return path
							return ""
