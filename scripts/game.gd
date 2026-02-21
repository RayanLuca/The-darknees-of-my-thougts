extends Node2D

func _ready():
	print("Personagem recebido:", Global.personagem_escolhido)

	var spawn_point = get_node_or_null("SpawnPoint")

	if spawn_point == null:
		print("ERRO: SpawnPoint não encontrado!")
		return

	var caminhos = {
		"player": "res://entites/player.tscn",
		"walter": "res://entites/Walter.tscn"
	}

	# Define padrão caso esteja vazio ou inválido
	if not caminhos.has(Global.personagem_escolhido):
		print("Personagem inválido ou não selecionado. Usando Player padrão.")
		Global.personagem_escolhido = "player"

	var cena = load(caminhos[Global.personagem_escolhido])

	if cena == null:
		print("ERRO: caminho da cena está errado!")
		return

	var personagem = cena.instantiate()

	personagem.position = spawn_point.position
	add_child(personagem)

	print("Personagem spawnado com sucesso")
