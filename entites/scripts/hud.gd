extends CanvasLayer

@onready var health_bar: ProgressBar = $HealthBar
var player

func _ready():
	await get_tree().process_frame
	
	player = get_tree().get_first_node_in_group("Player")
	
	if player:
		health_bar.max_value = player.max_health
		health_bar.value = player.health
		player.health_changed.connect(update_health)

func update_health(new_health):
	health_bar.value = new_health
