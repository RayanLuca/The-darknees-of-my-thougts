extends Camera2D

var target: Node2D = null

@onready var spawn_point: Node2D = $"../SpawnPoint"

func _ready() -> void:
	make_current()
	
	if spawn_point:
		position = spawn_point.position
	else:
		push_error("SpawnPoint não encontrado")

func _process(_delta: float) -> void:
	# Se ainda não encontrou o player, tenta achar
	if target == null:
		get_target()
	
	# Se encontrou, segue ele
	if target:
		position = target.position

func get_target():
	var nodes = get_tree().get_nodes_in_group("Player")
	if nodes.size() > 0:
		target = nodes[0]
