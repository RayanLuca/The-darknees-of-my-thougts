extends Control

var personagem_selecionado: String = ""

@onready var player_button = $PlayerButton
@onready var walter_button = $WalterButton

@onready var player_label = $PlayerButton/Label
@onready var player_label2 = $PlayerButton/Label2
@onready var walter_label = $WalterButton/Label
@onready var walter_label2 = $WalterButton/Label2


func _ready() -> void:
	print("Tela de seleção carregada")
	
	# Esconde todos os labels no início
	_esconder_todos_labels()


func _on_player_button_pressed() -> void:
	personagem_selecionado = "player"
	print("Player selecionado")
	
	_esconder_todos_labels()
	player_label.visible = true
	player_label2.visible = true


func _on_walter_button_pressed() -> void:
	personagem_selecionado = "walter"
	print("Walter selecionado")
	
	_esconder_todos_labels()
	walter_label.visible = true
	walter_label2.visible = true


func _on_confirmation_button_pressed() -> void:
	print("Confirmar clicado")

	if personagem_selecionado == "":
		personagem_selecionado = "player"
		print("Nenhum personagem escolhido. Usando Player padrão.")

	Global.personagem_escolhido = personagem_selecionado
	get_tree().change_scene_to_file("res://scene/game.tscn")


func _esconder_todos_labels():
	player_label.visible = false
	player_label2.visible = false
	walter_label.visible = false
	walter_label2.visible = false
	



func _on_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/TelaInicial.tscn")
