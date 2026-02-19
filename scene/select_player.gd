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

	if personagem_selecionado == "":
		print("Nenhum personagem escolhido")
		return

	Global.personagem_escolhido = personagem_selecionado
	get_tree().change_scene_to_file("res://scene/game.tscn")
