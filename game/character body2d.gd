extends CharacterBody2D

@export var speed: float = 200.0
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var shadow: AnimatedSprite2D = $shadow   # <-- AGGIUNTO

var is_attacking := false

func _ready() -> void:
	shadow.play("fermo")  # <-- AGGIUNTO (default all'avvio)

func _physics_process(_delta: float) -> void:
	# Se sta attaccando, blocca movimento e NON cambiare animazioni
	if is_attacking:
		velocity = Vector2.ZERO
		move_and_slide()
		
		# <-- AGGIUNTO: mentre attacca, ombra ferma
		if shadow.animation != "fermo":
			shadow.play("fermo")
		return

	# Movimento 4 direzioni
	var direction := Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_down"):
		direction.y += 1
	if Input.is_action_pressed("move_up"):
		direction.y -= 1

	direction = direction.normalized()
	velocity = direction * speed
	move_and_slide()

	# ATTACK (deve stare qui, fuori dal blocco is_attacking)
	if Input.is_action_just_pressed("attack"):
		start_attack()
		
		# <-- AGGIUNTO: quando parte l'attacco, ombra ferma
		if shadow.animation != "fermo":
			shadow.play("fermo")
		return

	# Animazioni movimento
	if direction != Vector2.ZERO:
		if anim.animation != "walk":
			anim.play("walk")

		# <-- AGGIUNTO: ombra animata mentre cammini
		if shadow.animation != "camminata":
			shadow.play("camminata")

		# Flip solo orizzontale (sinistra/destra)
		if direction.x != 0:
			anim.flip_h = direction.x < 0
	else:
		if anim.animation != "fermo":
			anim.play("fermo")

		# <-- AGGIUNTO: ombra ferma quando sei fermo
		if shadow.animation != "fermo":
			shadow.play("fermo")


func start_attack() -> void:
	is_attacking = true
	anim.play("attack")


func _on_animated_sprite_2d_animation_finished() -> void:
	# Questa funzione viene chiamata SOLO se hai collegato il segnale animation_finished
	if anim.animation == "attack":
		is_attacking = false
		anim.play("fermo")

		# <-- AGGIUNTO: ombra ferma quando finisce l'attacco
		if shadow.animation != "fermo":
			shadow.play("fermo")
