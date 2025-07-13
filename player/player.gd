extends CharacterBody3D

@export_group("Camera")
@export_range(0.0,1.0) var mouse_sensitivity := 0.25

@export_group("Movement")
@export var move_speed := 6
@export var acceleration := 80
@export var rotation_speed := 15
@export var jump_impulse := 12.0

var gravity := -30.0

var _camera_input_direction := Vector2.ZERO #camera rotation change
var _last_movement_direction := Vector3.BACK


@onready var cameraPivot := $CameraPivot
@onready var camera := $CameraPivot/SpringArm3D/Camera3D

@onready var skin := $RobotArmature #Player Charecter Model
@onready var animTree := $AnimationTree #Animation Handeler


#Player Movement

#Sets the mouse to be in captured mode
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		


func _unhandled_input(event: InputEvent) -> void:
	
	# gets the relitive motion of the mouse
	var is_camera_motion := (
		event is InputEventMouseMotion and 
		Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)
	if is_camera_motion:
		_camera_input_direction = event.screen_relative * mouse_sensitivity
		
func _physics_process(delta: float) -> void:
	handle_animations(delta) # animation handeling
	
	# rotates camera based on mouse inputs
	cameraPivot.rotation.x += _camera_input_direction.y * delta
	cameraPivot.rotation.x = clamp(cameraPivot.rotation.x,
	deg_to_rad(-30),deg_to_rad(60))
	
	cameraPivot.rotation.y -= _camera_input_direction.x * delta
	
	_camera_input_direction = Vector2.ZERO # reset input
	
	#produces a 2d vector with the combination of key inputs
	var raw_input := Input.get_vector("move_left","move_right","move_forward","move_backward")
	
	#the directions relitive to cameras forward and right
	var forward = camera.global_basis.z 
	var right = camera.global_basis.x
	
	#Calculating the moving direction utilising the cameras rotation
	var move_direction = forward * raw_input.y + right * raw_input.x 
	move_direction.y = 0.0
	move_direction = move_direction.normalized() 
	
	var y_velocity := velocity.y
	velocity.y = 0.0
	velocity = velocity.move_toward(move_direction * move_speed, acceleration * delta)
	velocity.y = y_velocity + gravity * delta
	
	#jumping
	var is_starting_jump := Input.is_action_just_pressed("jump") and is_on_floor()
	if is_starting_jump:
		velocity.y += jump_impulse
	
	move_and_slide() # ITS ALIVE!!!
	
	# rotiation of charecter to face motion
	if move_direction.length() > 0.2:
		_last_movement_direction = move_direction
	var target_angle := Vector3.BACK.signed_angle_to(_last_movement_direction,Vector3.UP)
	skin.global_rotation.y = lerp_angle(skin.rotation.y,target_angle,rotation_speed * delta)
	
	#animation prompting
	if is_starting_jump:
		curAnim = JUMP
	elif is_on_floor(): 
		if velocity.length() > 0:
			curAnim = RUN
		else: curAnim = IDLE
		
		
#Animmation stuff
enum {IDLE,RUN,JUMP}
var curAnim = IDLE
@export var blend_speed := 15.0

var run_val := 0.0
var jump_val := 0.0

func handle_animations(delta:float):
	update_tree()
	match curAnim:
		IDLE:
			run_val = lerpf(run_val,0,blend_speed*delta)
			jump_val = lerpf(jump_val,0,blend_speed*delta)
		RUN:
			run_val = lerpf(run_val,1,blend_speed*delta)
			jump_val = lerpf(jump_val,0,blend_speed*delta)
		JUMP:
			run_val = lerpf(run_val,0,blend_speed*delta)
			jump_val = 1
			

func update_tree():
	animTree["parameters/Run/blend_amount"] = run_val
	animTree["parameters/Jump/blend_amount"] = jump_val
