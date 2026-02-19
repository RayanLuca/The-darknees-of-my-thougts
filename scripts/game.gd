extends Node2D

func _ready():
	print("Personagem recebido:", Global.personagem_escolhido)

	var spawn_point = get_node_or_null("SpawnPoint")

	if spawn_point == null:
		print("ERRO: SpawnPoint não existe na cena!")
		return

	var caminhos = {
		"player": "res://entites/player.tscn",
		"walter": "res://entites/Walter.tscn"
	}

	if not caminhos.has(Global.personagem_escolhido):
		print("ERRO: personagem inválido ou não selecionado")
		return

	var cena = load(caminhos[Global.personagem_escolhido])

	if cena == null:
		print("ERRO: caminho da cena está errado!")
		return

	var personagem = cena.instantiate()

	if personagem == null:
		print("ERRO: não conseguiu instanciar personagem!")
		return

	personagem.position = spawn_point.position
	add_child(personagem)

	print("Personagem spawnado com sucesso")
