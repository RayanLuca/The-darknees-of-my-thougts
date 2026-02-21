extends Control

var personagem_selecionado: String = ""

func _ready():
	print("Tela de seleção carregada")

func _on_player_button_pressed() -> void:
	print("Player clicado")
	personagem_selecionado = "player"

func _on_walter_button_2_pressed() -> void:
	print("Walter clicado")
	personagem_selecionado = "walter"

func _on_confirmation_button_pressed() -> void:
	print("Confirmar clicado")

	# Define player como padrão se nada foi escolhido
	if personagem_selecionado == "":
		print("Nenhum personagem escolhido. Usando Player padrão.")
		personagem_selecionado = "player"

	Global.personagem_escolhido = personagem_selecionado

	# Forma segura de trocar de cena
	var tree = Engine.get_main_loop() as SceneTree
	if tree:
		tree.change_scene_to_file("res://scene/game.tscn")
	else:
		print("ERRO: SceneTree não encontrado")
