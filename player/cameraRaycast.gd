extends RayCast3D

@onready var platform = preload("res://Building/Objects/wooden_floor_pallet.tscn")

var held_floor : StaticBody3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("left_click") and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if not get_child(0):
			var floor : StaticBody3D = platform.instantiate()
			floor.set_collision_layer_value(1,false)
			floor.set_as_top_level(true)
			add_child(floor)
		else: 
			get_child(0).queue_free()
			
	if Input.is_action_just_pressed("place") and get_child(0):
		var floor : StaticBody3D = platform.instantiate()
		floor.global_transform = held_floor.global_transform
		
		get_tree().root.add_child(floor)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not get_child(0):
		return
	held_floor = get_child(0)
	held_floor.global_transform.origin = get_collision_point()
