extends RigidBody3D

# -------------------------------------------------
# CONFIGURAÇÕES
# -------------------------------------------------
@export var light_colors: Array[Color] = [
	Color.RED, Color.GREEN, Color.BLUE,
	Color.YELLOW, Color.MAGENTA, Color.CYAN, Color.WHITE
]
var current_light_index: int = 0

# Referências
@onready var spotlight: SpotLight3D = $SpotLight3D
@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var area: Area3D = $ClickArea  # Área de clique

# -------------------------------------------------
# _READY
# -------------------------------------------------
func _ready():
	# Configura luz
	spotlight.light_color = light_colors[current_light_index]
	spotlight.spot_angle = 45
	spotlight.light_energy = 5.0
	
	# Posiciona luz (acima e atrás do cubo)
	spotlight.position = Vector3(0, 2, -3)
	spotlight.look_at(Vector3.ZERO, Vector3.UP)
	
	# Área de clique
	var collision = CollisionShape3D.new()
	collision.shape = BoxShape3D.new()
	collision.shape.extents = Vector3(0.6, 0.6, 0.6)
	area.add_child(collision)
	area.input_event.connect(_on_click)

	# Material PBR
	var material = StandardMaterial3D.new()
	material.albedo_color = Color.WHITE
	material.roughness = 0.5
	material.metallic = 0.0
	mesh.set_surface_override_material(0, material)

# -------------------------------------------------
# CLIQUE → MUDA COR DA LUZ
# -------------------------------------------------
func _on_click(camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		current_light_index = (current_light_index + 1) % light_colors.size()
		spotlight.light_color = light_colors[current_light_index]
		print("Luz: ", light_colors[current_light_index].to_html(false))

# -------------------------------------------------
# TESTE: MUDAR ROUGHNESS E METALLIC (pressione R/M)
# -------------------------------------------------
func _input(event):
	if event is InputEventKey and event.pressed:
		var mat = mesh.get_surface_override_material(0) as StandardMaterial3D
		if not mat: return
		
		match event.keycode:
			KEY_R:
				mat.roughness = wrapf(mat.roughness + 0.1, 0.0, 1.0)
				print("Roughness: ", mat.roughness)
			KEY_M:
				mat.metallic = wrapf(mat.metallic + 0.1, 0.0, 1.0)
				print("Metallic: ", mat.metallic)
