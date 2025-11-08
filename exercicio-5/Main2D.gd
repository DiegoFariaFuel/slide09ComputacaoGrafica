extends Node2D

# -------------------------------------------------
# _READY: Configura UI
# -------------------------------------------------
func _ready():
	# Fundo
	var bg = ColorRect.new()
	bg.color = Color(0.1, 0.1, 0.2)
	bg.size = get_viewport().size
	add_child(bg)
	
	# Container central
	var vbox = VBoxContainer.new()
	vbox.anchor_left = 0.5
	vbox.anchor_top = 0.5
	vbox.anchor_right = 0.5
	vbox.anchor_bottom = 0.5
	vbox.offset_left = -150
	vbox.offset_top = -100
	vbox.offset_right = 150
	vbox.offset_bottom = 100
	add_child(vbox)
	
	# Título
	var label = Label.new()
	label.text = "Jogo 2D + 3D"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 32)
	vbox.add_child(label)
	
	# Botão
	var button = Button.new()
	button.text = "Iniciar Cena 3D"
	button.size = Vector2(300, 80)
	button.pressed.connect(_on_start_pressed)
	vbox.add_child(button)

# -------------------------------------------------
# BOTÃO CLICADO → CARREGA CENA 3D
# -------------------------------------------------
func _on_start_pressed():
	get_tree().change_scene_to_file("res://Level.tscn")
