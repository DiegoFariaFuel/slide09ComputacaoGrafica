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

# Padrões: 0 = Listas, 1 = Pontos
var current_pattern: int = 0

# Tiles
var tiles_x: float = 4.0
var tiles_y: float = 4.0

# -------------------------------------------------
# SHADER: LISTRAS e PONTOS (ALTERNA COM 1 e 2)
# -------------------------------------------------
const PATTERN_SHADER = """
shader_type canvas_item;

uniform int pattern : hint_range(0, 1) = 0;  // 0 = listras, 1 = pontos
uniform float tiles_x : hint_range(1.0, 20.0) = 4.0;
uniform float tiles_y : hint_range(1.0, 20.0) = 4.0;

void fragment() {
    vec2 uv = UV * vec2(tiles_x, tiles_y);
    
    vec3 col = vec3(0.0);  // fundo
    
    if (pattern == 0) {
        // LISTRAS HORIZONTAIS
        float stripe = mod(floor(uv.y), 2.0);
        col = vec3(stripe);
    } else {
        // PONTOS (grade de círculos)
        vec2 center = floor(uv) + 0.5;
        float dist = length(uv - center);
        float radius = 0.3;
        col = vec3(smoothstep(radius, radius - 0.1, dist));
    }
    
    COLOR.rgb = col;
    COLOR.a = 1.0;
}
"""

# -------------------------------------------------
# CRIAR POLÍGONO
# -------------------------------------------------
func create_polygon(poly_name: String, verts: PackedVector2Array, pos: Vector2) -> Node2D:
	var container = Node2D.new()
	container.name = poly_name
	container.position = pos
	add_child(container)
	
	# Polygon2D
	var poly = Polygon2D.new()
	poly.name = "Polygon"
	poly.polygon = verts
	poly.color = Color.WHITE
	
	# Shader com padrão
	var mat = ShaderMaterial.new()
	mat.shader = Shader.new()
	mat.shader.code = PATTERN_SHADER
	poly.material = mat
	
	# Atualiza parâmetros
	update_shader_params(mat)
	
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
	area.connect("input_event", _on_polygon_clicked.bind(container))
	container.add_child(area)
	
	return container

# -------------------------------------------------
# ATUALIZA PARÂMETROS DO SHADER
# -------------------------------------------------
func update_shader_params(mat: ShaderMaterial):
	mat.set_shader_parameter("pattern", current_pattern)
	mat.set_shader_parameter("tiles_x", tiles_x)
	mat.set_shader_parameter("tiles_y", tiles_y)

# -------------------------------------------------
# ATUALIZA TODOS OS SHADERS
# -------------------------------------------------
func update_all_shaders():
	for obj in [triangle, hexagon, star]:
		var poly = obj.get_node("Polygon") as Polygon2D
		if poly and poly.material is ShaderMaterial:
			update_shader_params(poly.material as ShaderMaterial)

# -------------------------------------------------
# CLIQUE → MUDA COR
# -------------------------------------------------
func _on_polygon_clicked(_viewport: Node, event: InputEvent, _shape_idx: int, container: Node2D):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		current_color_index = (current_color_index + 1) % colors.size()
		var new_color = colors[current_color_index]
		var poly = container.get_node("Polygon") as Polygon2D
		if poly:
			poly.modulate = new_color
		print("Cor: ", new_color.to_html(false))

# -------------------------------------------------
# INPUT: TECLAS 1 e 2
# -------------------------------------------------
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_1:
			current_pattern = 0
			print("Padrão: LISTRAS")
			update_all_shaders()
		elif event.keycode == KEY_2:
			current_pattern = 1
			print("Padrão: PONTOS")
			update_all_shaders()
		# Ajuste de tiles com + e -
		elif event.keycode == KEY_EQUAL:  # +
			tiles_x += 1.0
			tiles_y += 1.0
			print("Tiles: ", tiles_x, "x", tiles_y)
			update_all_shaders()
		elif event.keycode == KEY_MINUS:  # -
			tiles_x = max(1.0, tiles_x - 1.0)
			tiles_y = max(1.0, tiles_y - 1.0)
			print("Tiles: ", tiles_x, "x", tiles_y)
			update_all_shaders()

# -------------------------------------------------
# _READY
# -------------------------------------------------
func _ready():
	# Triângulo
	var tri_verts = PackedVector2Array([Vector2(-50,50), Vector2(50,50), Vector2(0,-50)])
	triangle = create_polygon("Triangulo", tri_verts, Vector2(-200, 0))
	
	# Hexágono
	var hex_verts = PackedVector2Array()
	for i in range(6):
		var a = i * PI * 2.0 / 6.0
		hex_verts.append(Vector2(cos(a) * 50, sin(a) * 50))
	hexagon = create_polygon("Hexagono", hex_verts, Vector2(0, 0))
	
	# Estrela
	var star_verts = PackedVector2Array()
	var outer = 50.0; var inner = 20.0
	for i in range(10):
		var r = outer if i % 2 == 0 else inner
		var a = i * PI * 2.0 / 10.0 - PI / 2.0
		star_verts.append(Vector2(cos(a) * r, sin(a) * r))
	star = create_polygon("Estrela", star_verts, Vector2(200, 0))
	
	print("TECLAS:")
	print("  1 → Listas")
	print("  2 → Pontos")
	print("  + → Mais tiles")
	print("  - → Menos tiles")
	print("  Clique → Muda cor")
