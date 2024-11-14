extends CharacterBody3D

@export var pause_menu: PackedScene

@export var MAX_SPEED = 10
@export var FRICTION  = 16
@export var JUMP_VELOCITY = 150   # Initial upward velocity target

@onready var camera     = $Camera3D
@onready var flashlight = $Camera3D/SpotLight3D

var direction_vector = Vector3.ZERO

var mouse_sensitivity = 0.006

func _input(event):
	
	if event is InputEventMouseMotion:

		rotate_y(-event.relative.x * mouse_sensitivity)
		
		var x_rotation = -event.relative.y * mouse_sensitivity
		camera.rotate_x(x_rotation)
		camera.rotation.x = clamp(camera.rotation.x, -1.2, 1.2)
		
	if event.is_action_pressed("ui_home"):
		
		var pause_menu_instance = pause_menu.instantiate()
		get_tree().get_root().call_deferred("add_child", pause_menu_instance)
		
	if event.is_action_pressed("toggle_flashlight"):
		
		flashlight.visible = !flashlight.visible

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity += get_gravity() * delta  # Ensure gravity points downward on Y-axis

	# Get input and normalize
	var input_vector = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	).normalized()

	# Jumping logic
	if is_on_floor() and Input.is_action_just_pressed("game_jump"):
		velocity.y = JUMP_VELOCITY

	# Apply movement
	if input_vector != Vector2.ZERO:
		var direction_vector = _translate_input_to_camera(input_vector)
		var movement_speed = direction_vector * MAX_SPEED
		velocity = velocity.lerp(movement_speed, FRICTION * delta)
	else:
		# Apply friction only to horizontal axes
		velocity = velocity.lerp(Vector3.ZERO, FRICTION * delta)
		
	# Move and slide with up direction
	move_and_slide()

func _translate_input_to_camera(input : Vector2) -> Vector3 :
	
	var camera_pos   = camera.get_global_transform().basis
	var direction = Vector3.ZERO 
	
	direction += camera_pos.z * input.y
	direction += camera_pos.x * input.x 
	
	direction.y = 0
	direction = direction.normalized()
	
	return direction
	
	
	
