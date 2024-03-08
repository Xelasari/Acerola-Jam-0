extends Node2D

var speed : Vector2
var speed_scale : Vector2


var characterBody2D : CharacterBody2D


var walls_colliding_with : Array = []

var tiles_on_top_of : Array = []


signal player_died()

# Called when the node enters the scene tree for the first time.
func _ready():
	speed = Vector2(2.0, 2.0)
	speed_scale = Vector2(1.0, 1.0)
	characterBody2D = $CharacterBody2D
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var input_vector = Input.get_vector("left", "right", "up", "down")
	
	if input_vector != Vector2.ZERO:
		if input_vector.x < -0.05:
			$PlayerAnimatedSprite.flip_h = true
		elif input_vector.x > 0.05:
			$PlayerAnimatedSprite.flip_h = false
		$PlayerAnimatedSprite.play("walk")
	else:
		$PlayerAnimatedSprite.play("idle")
	
	
	
	#if walls_colliding_with.is_empty(): position += (speed * speed_scale) * input_vector
	#else: position += (speed * speed_scale * -1) * input_vector
	
	# TODO: can put together a hacky solution for wall sliding here by testing zero'd x and y vectors
	if !characterBody2D.test_move(self.transform, (speed * speed_scale) * input_vector):
		position += (speed * speed_scale) * input_vector
	
	
	
	var test_hold : KinematicCollision2D = characterBody2D.move_and_collide(Vector2(0, 0))
	if test_hold != null:
		test_hold.get_collider()
		print("Testing?")
	
	#characterBody2D.position = position
	
	#for w in walls_colliding_with:
	#	var vector_to_move : Vector2 = Vector2(0, 0)
	#	var p1 : Vector2 = position 
	#	var p2 : Vector2 = w.get_parent().position
	#	var rad = p2.angle_to_point(p1)
	#	
	#	vector_to_move += Vector2.RIGHT.rotated(rad)
	#	
	#	var delta_pos = 50 * delta * vector_to_move
	#	position += delta_pos
	
	
	if tiles_on_top_of.is_empty():
		#print("Technically dead")
		player_died.emit()
	else:
		var safe_or_not = true
		for area in tiles_on_top_of:
			var tile = area.get_parent()
			for t in tile.tiles_connected_to:
				if t.draggableComponent.being_dragged:
					safe_or_not = false
					player_died.emit()
					#print("Technically also dead")
		if safe_or_not:
			pass
			#print("Safe")


func _on_hitbox_set_speed_scale(scale):
	speed_scale = scale


func _on_ground_detector_area_entered(area):
	if area.get_parent().is_group_being_dragged(): return
	
	if area.get_parent().blocks_player:
		walls_colliding_with.append(area)
	tiles_on_top_of.append(area)


func _on_ground_detector_area_exited(area):
	if area.get_parent().is_group_being_dragged(): return
	
	if area.get_parent().blocks_player:
		walls_colliding_with.erase(area)
	tiles_on_top_of.erase(area)
