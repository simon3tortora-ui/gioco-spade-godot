extends CharacterBody2D

@export var speed: float = 200.0
@export var max_hp: int = 100
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var shadow: AnimatedSprite2D = $shadow
@onready var hp_bar: ProgressBar = $CanvasLayer/ProgressBar

var is_attacking := false
var is_dead := false
var current_hp: int

func _ready() -> void:
	current_hp = max_hp
	hp_bar.max_value = max_hp
	hp_bar.value = current_hp
	shadow.play("fermo")

func _physics_process(_delta: float) -> void:
	if is_dead:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if is_attacking:
		velocity = Vector2.ZERO
		move_and_slide()
		if shadow.animation != "fermo":
			shadow.play("fermo")
		return

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

	if Input.is_action_just_pressed("attack"):
		start_attack()
		if shadow.animation != "fermo":
			shadow.play("fermo")
		return

	if direction != Vector2.ZERO:
		if anim.animation != "walk":
			anim.play("walk")
		if shadow.animation != "camminata":
			shadow.play("camminata")
		if direction.x != 0:
			anim.flip_h = direction.x < 0
	else:
		if anim.animation != "fermo":
			anim.play("fermo")
		if shadow.animation != "fermo":
			shadow.play("fermo")


func start_attack() -> void:
	is_attacking = true
	anim.play("attack")


func take_damage(amount: int) -> void:
	if is_dead:
		return
	current_hp -= amount
	if current_hp < 0:
		current_hp = 0
	hp_bar.value = current_hp
	if current_hp <= 0:
		die()


func die() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	anim.play("death")
	shadow.play("fermo")


func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation == "attack":
		is_attacking = false
		anim.play("fermo")
		if shadow.animation != "fermo":
			shadow.play("fermo")
	elif anim.animation == "death":
		anim.stop()
