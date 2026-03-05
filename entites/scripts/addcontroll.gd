extends Control

@onready var controle = $controle
@onready var pause_menu = $pause_menu


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	print("Script carregado")


func _on_controleadd_pressed() -> void:
	if controle and controle.has_method("alternar_controle"):
		controle.alternar_controle()
	print("controleadd pressionado")


func _on_pause_pressed() -> void:
	if pause_menu and pause_menu.has_method("toggle_pause"):
		pause_menu.toggle_pause()
	print("start pressionado")
