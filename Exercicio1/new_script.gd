extends Node2D

# -------------------------------------------------
# CONFIGURAÇÕES
# -------------------------------------------------
var colors: Array[Color] = [
	Color.RED, Color.GREEN, Color.BLUE, Color.YELLOW,
	Color.MAGENTA, Color.CYAN, Color.ORANGE
]
var current_color_index: int = 0

var triangle: Node2D
var hexagon: Node2D
var star: Node2D

# -------------------------------------------------
# SHADER: TEXTURA TILEADA (CHECKERBOARD)
# -------------------------------------------------
const CHECKER_SHADER = """
shader_type canvas_item;

uniform float tile_scale : hint_range(1.0, 20.0) = 4.0;

void fragment() {
    vec2 uv = UV * tile_scale;
    float checker = mod(floor(uv.x) + floor(uv.y), 2.0);
    COLOR.rgb = vec3(checker);
    COLOR.a = 1.0;
}
"""

# -------------------------------------------------
# CRIAR POLÍGONO (SEM AVISOS)
# -------------------------------------------------
func create_polygon(poly_name: String, verts: PackedVector2Array, pos: Vector2) -> Node2D:
	var container = Node2D.new()
	container.name = poly_name  # Agora OK: não conflita com parâmetro
	container.position = pos
	add_child(container)
	
	# Polygon2D
	var poly = Polygon2D.new()
	poly.name = "Polygon"
	poly.polygon = verts
	poly.color = Color.WHITE
	
	# Shader tileado
	var mat = ShaderMaterial.new()
	mat.shader = Shader.new()
	mat.shader.code = CHECKER_SHADER
	poly.material = mat
	
	poly.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	poly.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	
	container.add_child(poly)
	
	# Contorno
	var line = Line2D.new()
	line.name = "Contour"
	line.points = verts
	line.width = 3.0
	line.default_color = Color.BLACK
	line.closed = true
	line.joint_mode = Line2D.LINE_JOINT_ROUND
	container.add_child(line)
	
	# Área de clique
	var collision = CollisionPolygon2D.new()
	collision.polygon = verts
	var area = Area2D.new()
	area.add_child(collision)
	# Parâmetros não usados: prefixo com _
	area.connect("input_event", _on_polygon_clicked.bind(container))
	container.add_child(area)
	
	return container

# -------------------------------------------------
# CLIQUE → MUDA COR (SEM AVISOS)
# -------------------------------------------------
func _on_polygon_clicked(_viewport: Node, event: InputEvent, _shape_idx: int, container: Node2D):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		current_color_index = (current_color_index + 1) % colors.size()
		var new_color = colors[current_color_index]
		
		var poly = container.get_node("Polygon") as Polygon2D
		if poly:
			poly.modulate = new_color
		
		print("Cor mudada para: ", new_color.to_html(false))

# -------------------------------------------------
# _READY: CRIAR OBJETOS
# -------------------------------------------------
func _ready():
	# Triângulo
	var tri_verts = PackedVector2Array([
		Vector2(-50, 50),
		Vector2(50, 50),
		Vector2(0, -50)
	])
	triangle = create_polygon("Triangulo", tri_verts, Vector2(-200, 0))
	
	# Hexágono
	var hex_verts = PackedVector2Array()
	for i in range(6):
		var angle = i * PI * 2.0 / 6.0
		hex_verts.append(Vector2(cos(angle) * 50, sin(angle) * 50))
	hexagon = create_polygon("Hexagono", hex_verts, Vector2(0, 0))
	
	# Estrela (5 pontas)
	var star_verts = PackedVector2Array()
	var outer = 50.0
	var inner = 20.0
	for i in range(10):
		var radius = outer if i % 2 == 0 else inner
		var angle = i * PI * 2.0 / 10.0 - PI / 2.0
		star_verts.append(Vector2(cos(angle) * radius, sin(angle) * radius))
	star = create_polygon("Estrela", star_verts, Vector2(200, 0))
