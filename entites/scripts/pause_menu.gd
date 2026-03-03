extends CanvasLayer

@onready var continue_button: Button = $Panel/VBoxContainer/ContinueButton
@onready var restart_button: Button = $Panel/VBoxContainer/RestartButton
@onready var exit_button: Button = $Panel/VBoxContainer/ExitButton

var is_paused: bool = false


func _ready():
	visible = false
	
	# Garante que o menu funcione mesmo com o jogo pausado
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Conecta os botões por código (evita erro do editor)
	continue_button.pressed.connect(_on_continue_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	exit_button.pressed.connect(_on_exit_pressed)


func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		toggle_pause()


func toggle_pause():
	is_paused = !is_paused
	get_tree().paused = is_paused
	visible = is_paused
	
	if is_paused:
		continue_button.grab_focus()


func _on_continue_pressed():
	resume_game()


func _on_restart_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_exit_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scene/TelaInicial.tscn")


func resume_game():
	is_paused = false
	get_tree().paused = false
	visible = false
