extends CharacterBody2D

var speed = 100
var last_direction = Vector2.ZERO
var animated_sprite
var enemy_in_range = false
var health = 100
var is_dead = false

func _ready():
	animated_sprite = $AnimatedSprite2D
	add_to_group("Player")

func _physics_process(delta):
	update_health()
	die()
	update_animation()
	move_and_slide()
	
func update_animation():
	if is_dead:
		return

	
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	velocity = direction * speed
	
	if direction != Vector2.ZERO:
		last_direction = direction
		
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
