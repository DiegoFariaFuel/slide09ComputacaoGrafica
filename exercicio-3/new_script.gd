extends RigidBody3D

# -------------------------------------------------
# CONFIGURAÇÕES
# -------------------------------------------------
@export var move_speed: float = 10.0
@export var rotation_speed: float = 3.0  # radianos por segundo

# Referências
@onready var camera: Camera3D = $Camera3D

# Variáveis de estado
var rotation_y: float = 0.0  # rotação horizontal da câmera

# -------------------------------------------------
# _READY
# -------------------------------------------------
func _ready():
	# Torna a câmera ativa
	camera.current = true

# -------------------------------------------------
# _PHYSICS_PROCESS (60 FPS fixo)
# -------------------------------------------------
func _physics_process(delta):
	handle_camera_rotation(delta)
	handle_movement(delta)

# -------------------------------------------------
# ROTAÇÃO DA CÂMERA (← / →)
# -------------------------------------------------
func handle_camera_rotation(delta):
	var rotate_input = 0.0
	
	if Input.is_action_pressed("ui_left"):
		rotate_input -= 1.0
	if Input.is_action_pressed("ui_right"):
		rotate_input += 1.0
	
	# Acumula rotação
	rotation_y += rotate_input * rotation_speed * delta
	
	# Aplica rotação apenas no eixo Y (horizontal)
	camera.rotation.y = rotation_y

# -------------------------------------------------
# MOVIMENTO RELATIVO À CÂMERA
# -------------------------------------------------
func handle_movement(delta):
	var input_dir = Vector2.ZERO
	
	if Input.is_action_pressed("ui_up"):
		input_dir.y -= 1.0
	if Input.is_action_pressed("ui_down"):
		input_dir.y += 1.0
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1.0
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1.0
	
	# Normaliza para evitar diagonal mais rápida
	if input_dir.length() > 0:
		input_dir = input_dir.normalized()
	
	# Direção da câmera no plano XZ (ignora pitch)
	var camera_forward = -camera.global_transform.basis.z
	var camera_right = camera.global_transform.basis.x
	
	# Projeta no plano XZ
	camera_forward.y = 0
	camera_right.y = 0
	camera_forward = camera_forward.normalized()
	camera_right = camera_right.normalized()
	
	# Calcula direção final do movimento
	var move_direction = (camera_forward * input_dir.y) + (camera_right * input_dir.x)
	
	if move_direction.length() > 0:
		move_direction = move_direction.normalized()
		var velocity = move_direction * move_speed
		# Aplica força (física realista)
		apply_central_force(velocity - linear_velocity * Vector3(1, 0, 1))  # só XZ
		# Ou use linear_velocity diretamente (sem inércia):
		# linear_velocity.x = velocity.x
		# linear_velocity.z = velocity.z
