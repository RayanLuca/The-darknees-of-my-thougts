extends Control

var personagem_selecionado: String = ""

@onready var player_button = $PlayerButton
@onready var walter_button = $WalterButton

func _ready():
	print("Tela de seleção carregada")

func _on_player_button_toggled(button_pressed: bool) -> void:
	if button_pressed:
		walter_button.button_pressed = false
		personagem_selecionado = "player"
		print("Player selecionado")

func _on_walter_button_toggled(button_pressed: bool) -> void:
	if button_pressed:
		player_button.button_pressed = false
		personagem_selecionado = "walter"
		print("Walter selecionado")

func _on_confirmation_button_pressed() -> void:
	print("Confirmar clicado")

	if personagem_selecionado == "":
		personagem_selecionado = "player"
		print("Nenhum personagem escolhido. Usando Player padrão.")

	Global.personagem_escolhido = personagem_selecionado
	get_tree().change_scene_to_file("res://scene/game.tscn")
