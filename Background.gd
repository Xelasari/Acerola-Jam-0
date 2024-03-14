extends ParallaxBackground

var eye_1_texture = preload("res://assets/eye_1.png")
var eye_2_texture = preload("res://assets/eye_2.png")
var eye_3_texture = preload("res://assets/eye_3.png")
var eye_4_texture = preload("res://assets/eye_4.png")
var eye_5_texture = preload("res://assets/eye_5_no_eyeball.png")


var playerReference
var max_radius : float = 100
var original_eye_position : Vector2 = Vector2(640, 360)

var start_tracking_player : bool = false
var tracking_counter : float = 0
var tracking_threshold : float = 0.20

var tracking_player : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	scroll_offset.x -= 20 * delta
	
	if tracking_player and Input.get_vector("left", "right", "up", "down") != Vector2.ZERO:
		tracking_counter += delta
		if tracking_counter > tracking_threshold:
			start_tracking_player = true
	

func set_eye_stage(stage : int):
	match stage:
		0:
			$Eye.visible = false
			$Eyeball.visible = false
		1:
			$Eye.visible = true
			$Eyeball.visible = false
			$Eye.texture = eye_1_texture
			$Eye.modulate = Color(1, 1, 1, 0.2)
		2:
			$Eye.visible = true
			$Eyeball.visible = false
			$Eye.texture = eye_2_texture
			$Eye.modulate = Color(1, 1, 1, 0.4)
		3:
			$Eye.visible = true
			$Eyeball.visible = false
			$Eye.texture = eye_3_texture
			$Eye.modulate = Color(1, 1, 1, 0.6)
		4:
			$Eye.visible = true
			$Eyeball.visible = false
			$Eye.texture = eye_4_texture
			$Eye.modulate = Color(1, 1, 1, 0.8)
		5:
			$Eye.visible = true
			$Eyeball.visible = true
			$Eye.texture = eye_5_texture
			$Eye.modulate = Color(1, 1, 1, 1.0)

func set_blackhole_scale(level_number : int):
	if level_number == 0: $Blackhole.scale = Vector2(4.0, 4.0)
	$Blackhole.scale = Vector2(4.0, 4.0) * ((1 + float((level_number * 3) / 30.0)))

func set_eye_scale(level_number : int):
	if level_number == 0: $Eye.scale = Vector2(4.0, 4.0)
	$Eye.scale = Vector2(4.0, 4.0) * (4.0 * float(level_number / 30.0))
	$Eyeball.scale = Vector2(4.0, 4.0) * (4.0 * float(level_number / 30.0))

func set_player_reference(player_ref):
	playerReference = player_ref

func toggle_eye_tracking(value : bool):
	tracking_player = value

func eye_track_player():
	if playerReference != null and start_tracking_player:
	
		var dir = original_eye_position.direction_to(playerReference.position)
		var target = dir * Vector2(max_radius, max_radius) + original_eye_position
		$Eyeball.position = target.lerp($Eyeball.position, 0.2)
	#var player_pos = get_parent().get_node("Level").get_node("Player").position
	#var dir = original_eye_position.direction_to(player_pos)
	
	
