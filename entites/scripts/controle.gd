extends CanvasLayer

func _ready():
	visible = false


func alternar_controle():
	visible = !visible

@onready var baixo: TouchScreenButton = $baixo
@onready var cima: TouchScreenButton = $cima
@onready var direita: TouchScreenButton = $direita
@onready var esquerda: TouchScreenButton = $esquerda
@onready var pular: TouchScreenButton = $pular
@onready var ataque: TouchScreenButton = $ataque


func _simular_acao(acao: String, pressionado: bool):
	var evento = InputEventAction.new()
	evento.action = acao
	evento.pressed = pressionado
	Input.parse_input_event(evento)


func _on_baixo_pressed() -> void:
	baixo.modulate.a = 0.5
	_simular_acao("duck", true)
	

func _on_baixo_released() -> void:
	baixo.modulate.a = 1.0
	_simular_acao("duck", false)


func _on_cima_pressed() -> void:
	cima.modulate.a = 0.5
	_simular_acao("jump", true)

func _on_cima_released() -> void:
	cima.modulate.a = 1.0
	_simular_acao("jump", false)


func _on_direita_pressed() -> void:
	direita.modulate.a = 0.5
	_simular_acao("right", true)
	print("RIGHT funcionando")
func _on_direita_released() -> void:
	direita.modulate.a = 1.0
	_simular_acao("right", false)


func _on_esquerda_pressed() -> void:
	esquerda.modulate.a = 0.5
	_simular_acao("left", true)

func _on_esquerda_released() -> void:
	esquerda.modulate.a = 1.0
	_simular_acao("left", false)


func _on_pular_pressed() -> void:
	pular.modulate.a = 0.5
	_simular_acao("jump", true)

func _on_pular_released() -> void:
	pular.modulate.a = 1.0
	_simular_acao("jump", false)


func _on_ataque_pressed() -> void:
	ataque.modulate.a = 0.5
	_simular_acao("attack", true)

func _on_ataque_released() -> void:
	ataque.modulate.a = 1.0
	_simular_acao("attack", false)
