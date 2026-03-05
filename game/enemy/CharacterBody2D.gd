extends CharacterBody2D

# ---------------------------
# TUNING
# ---------------------------
@export var speed: float = 95.0
@export var accel: float = 900.0
@export var friction: float = 1000.0

@export var chase_range: float = 220.0
@export var stop_distance: float = 18.0

@export var attack_range: float = 22.0
@export var attack_cooldown: float = 0.9
@export var attack_duration: float = 0.45  # quanto dura la "fase" di attacco
@export var attack_damage: int = 25

# ---------------------------
# STATE
# ---------------------------
var player: Node2D = null
var has_target := false

var is_attacking := false
var can_attack := true

# ---------------------------
# NODES
# ---------------------------
@onready var detect_area: Area2D = get_node_or_null("DetectArea")
@onready var sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")

var attack_timer: Timer
var cooldown_timer: Timer


func _ready() -> void:
	if detect_area == null:
		push_error("Enemy: nodo 'DetectArea' non trovato. Rinomina il nodo o aggiorna lo script.")
		return

	if sprite == null:
		push_error("Enemy: nodo 'AnimatedSprite2D' non trovato. Rinomina il nodo o aggiorna lo script.")
		return

	if sprite.sprite_frames == null:
		push_error("Enemy: AnimatedSprite2D non ha SpriteFrames assegnato.")
		return

	# 👇 AGGIUNGI QUESTO QUI
	var p = get_tree().get_first_node_in_group("player")
	if p != null and p.has_method("get"):
		if p.get("speed") != null:
			speed = p.speed * 0.85
	
	
	# segnali detection
	detect_area.body_entered.connect(_on_detect_enter)
	detect_area.body_exited.connect(_on_detect_exit)

	# Timer attacco
	attack_timer = Timer.new()
	attack_timer.one_shot = true
	add_child(attack_timer)
	attack_timer.timeout.connect(_on_attack_finished)

	# Timer cooldown
	cooldown_timer = Timer.new()
	cooldown_timer.one_shot = true
	add_child(cooldown_timer)
	cooldown_timer.timeout.connect(_on_attack_cooldown_finished)

	# animazione iniziale (FIX: check su SpriteFrames)
	if sprite.sprite_frames.has_animation("idle"):
		sprite.play("idle")
	elif sprite.sprite_frames.has_animation("walk"):
		sprite.play("walk")


func _physics_process(delta: float) -> void:
	# Se il player non esiste più, reset
	if has_target and not is_instance_valid(player):
		has_target = false
		player = null

	var desired := Vector2.ZERO

	if has_target and is_instance_valid(player):
		var to_player: Vector2 = player.global_position - global_position
		var dist: float = to_player.length()

		# se troppo lontano, molla
		if dist > chase_range:
			has_target = false
		else:
			# prova attacco se vicino
			_try_attack(dist)

			# se non sta attaccando, insegue
			if not is_attacking:
				if dist > stop_distance:
					desired = to_player.normalized() * speed
				else:
					desired = Vector2.ZERO

	# movimento
	if is_attacking:
		velocity = Vector2.ZERO
	else:
		if desired != Vector2.ZERO:
			velocity = velocity.move_toward(desired, accel * delta)
		else:
			velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	move_and_slide()

	_update_flip()
	_update_animation()


# ---------------------------
# FLIP / ANIM
# ---------------------------
func _update_flip() -> void:
	if sprite == null:
		return
	if velocity.x != 0:
		sprite.flip_h = velocity.x < 0


func _update_animation() -> void:
	if sprite == null or sprite.sprite_frames == null:
		return

	# Se attacca: resta su attack
	if is_attacking:
		if sprite.sprite_frames.has_animation("attack") and sprite.animation != "attack":
			sprite.play("attack")
		return

	# Se si muove: walk
	if velocity.length() > 5.0:
		if sprite.sprite_frames.has_animation("walk") and sprite.animation != "walk":
			sprite.play("walk")
	else:
		# fermo: idle (se c'è)
		if sprite.sprite_frames.has_animation("idle") and sprite.animation != "idle":
			sprite.play("idle")


# ---------------------------
# ATTACK
# ---------------------------
func _try_attack(dist_to_player: float) -> void:
	if is_attacking:
		return
	if not can_attack:
		return
	if dist_to_player > attack_range:
		return

	is_attacking = true
	can_attack = false
	velocity = Vector2.ZERO

	# play attack (senza chiamare animazioni inesistenti)
	if sprite != null and sprite.sprite_frames != null and sprite.sprite_frames.has_animation("attack"):
		sprite.play("attack")

	attack_timer.start(attack_duration)
	cooldown_timer.start(attack_cooldown)

	# Infliggi danno al player
	if is_instance_valid(player) and player.has_method("take_damage"):
		player.take_damage(attack_damage)


func _on_attack_finished() -> void:
	is_attacking = false


func _on_attack_cooldown_finished() -> void:
	can_attack = true


# ---------------------------
# DETECTION
# ---------------------------
func _on_detect_enter(body: Node) -> void:
	if body != null and body.is_in_group("player"):
		player = body as Node2D
		has_target = true


func _on_detect_exit(body: Node) -> void:
	if body == player:
		has_target = false
		player = null
