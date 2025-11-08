extends RigidBody3D

@export var speed: float = 10.0
@onready var cam: Camera3D = $Camera3D

func _ready():
	cam.current = true

func _physics_process(delta):
	var dir = Vector3.ZERO
	if Input.is_action_pressed("ui_up"): dir += -cam.global_transform.basis.z
	if Input.is_action_pressed("ui_down"): dir += cam.global_transform.basis.z
	if Input.is_action_pressed("ui_left"): cam.rotate_y(2 * delta)
	if Input.is_action_pressed("ui_right"): cam.rotate_y(-2 * delta)
	
	if dir != Vector3.ZERO:
		dir.y = 0
		dir = dir.normalized()
		apply_central_force(dir * speed)
