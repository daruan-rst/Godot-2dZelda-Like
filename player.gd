extends CharacterBody2D

var speed = 100
var last_direction = Vector2.ZERO
var animated_sprite
var enemy_in_range = false
var health = 100
var is_dead = false
var is_attacking = false
var attack_timer = 0.0
var attack_duration = 0.5 #Time in seconds

func _ready():
	animated_sprite = $AnimatedSprite2D
	add_to_group("Player")

func _physics_process(delta):
	update_health()
	die()
	update_animation()
	move_and_slide()
	
	if is_attacking:
		attack_timer += delta
	if attack_timer >= attack_duration:
		is_attacking = false
		attack_timer = 0.0
	
func update_animation():
	if is_dead:
		return
		
	if is_attacking:
		if last_direction.y < 0:
			animated_sprite.play("attack_up")
		elif last_direction.y > 0:
			animated_sprite.play("attack_down")
		elif last_direction.x != 0:
			animated_sprite.play("attack_right")
		return
	
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	velocity = direction * speed
	
	if direction != Vector2.ZERO:
		last_direction = direction.normalized()
		
	if direction.x != 0:
		animated_sprite.play("walk_right")
	elif direction.y < 0:
		animated_sprite.play("walk_up")
	elif direction.y > 0:
		animated_sprite.play("walk_down")
	else:
		
		if last_direction.x != 0:
			animated_sprite.play("idle_right")
		elif last_direction.y < 0 :
			animated_sprite.play("idle_up")
		elif last_direction.y > 0:
			animated_sprite.play("idle_down")
			

	animated_sprite.flip_h = last_direction.x < 0
	
func _input(event):
	if event.is_action_pressed("ui_select"):
		is_attacking = true
		attack_timer = 0.0	


func update_health():
	var healthbar = $healthbar
	healthbar.value = health
	if health >= 100:
		healthbar.visible = false
	else:
		healthbar.visible = true

func die():
	if health <= 0 and not is_dead:
		is_dead = true
		animated_sprite.play("die")
	
func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		enemy_in_range = true
		print("Getting swooped")


func _on_hitbox_body_exited(body: Node2D) -> void:
		if body.is_in_group("Enemy"):
			enemy_in_range = false
			print("Enemy exited the hitbox")
			



func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "die":
		queue_free()
