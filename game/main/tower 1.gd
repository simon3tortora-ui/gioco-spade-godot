extends Node2D

@onready var top: Sprite2D = $torre_alto
@onready var base: Sprite2D = $torre_base2

# quanto è alta la parte top in pixel (metà della png: 256/2 = 128)
@export var slice_h := 128

func _ready() -> void:
	# forza scale pulita (evita 1.008 e simili)
	top.scale = Vector2.ONE
	base.scale = Vector2.ONE
	
	# stessa origine
	top.centered = true
	base.centered = true
	
	# stesso offset
	top.offset = Vector2.ZERO
	base.offset = Vector2.ZERO
	
	_align()

func _process(_delta: float) -> void:
	# se sposti la torre in runtime o vuoi essere sicuro sempre:
	_align()

func _align() -> void:
	# snap della posizione del parent a pixel intero
	global_position = global_position.round()

	# allinea base e top sullo stesso pivot (0,0 locale)
	base.position = Vector2.ZERO
	top.position = Vector2.ZERO

	# snap dei figli (evita mezzi pixel)
	base.global_position = base.global_position.round()
	top.global_position = top.global_position.round()
