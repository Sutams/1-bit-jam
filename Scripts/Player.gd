extends CharacterBody2D

# Movement
const SPEED = 75.0
const HALT = 2
var weights = 2.3

# Lights
var rotation_speed = 30

# HP
@export var heart_scene: PackedScene
@onready var hearts_container = $HealthUI/HeartsContainer
var hearts_list : Array[Node]
var HP = 3
var took_damage = false

# Scoring system, but now that i think about it its weird that 
# its here in the player script instead of the game one
var score = 0


func _ready() -> void:
	if !heart_scene:
		return
	# Add hearts
	for i in range(HP):
		var new_heart = heart_scene.instantiate()
		hearts_container.add_child(new_heart)
		hearts_list.append(new_heart)

func add_score():
	score +=1
	print(score)
	if score >= 6:
		print("Win")

func take_damage():
	HP -=1
	for i in range(hearts_list.size()):
		var heart_sprite = hearts_list[i].get_node("HeartSprite")
		if i < HP:
			heart_sprite.play("Full")
		if i == HP:
			heart_sprite.play("Damage")
	await get_tree().create_timer(1.5).timeout
	if HP > 0:
		took_damage = false
		return
	print("Game over")
	get_tree().call_deferred("reload_current_scene")


func _physics_process(delta: float) -> void:
	for i in get_slide_collision_count():
		var coll = get_slide_collision(i)
		if coll.get_collider().name == "Spikes":
			if !took_damage:
				took_damage = !took_damage
				take_damage()
	
	if Input.is_action_just_pressed("drop"):
		if weights > 1:
			weights -= 1
			print(weights)
	if Input.is_action_just_pressed("interact"):
		if weights < 3:
			weights += 1
	
	var move_x := Input.get_axis("left", "right")
	if move_x:
		velocity.x = move_x * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, HALT)
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var move_y := Input.get_axis("up", "down")
	if move_y:
		velocity.y = move_y * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, HALT)
	
	# Add the gravity.
	if not is_on_floor():
		velocity += (get_gravity() * delta * weights)/3
	
	if velocity.length() > 0:
		$AnimatedSprite2D.play("Walk")
	else:
		$AnimatedSprite2D.play("Idle")
	
	var target_angle = velocity.angle()+PI
	if velocity.x > 0:
		$AnimatedSprite2D.flip_h = false
	if velocity.x < 0:
		$AnimatedSprite2D.flip_h = true
	if velocity == Vector2.ZERO:
		if $AnimatedSprite2D.flip_h:
			target_angle = 0
		else:
			target_angle = PI
	
	$PointLight2D.rotation = lerp_angle($PointLight2D.rotation, target_angle, delta * rotation_speed)
	
	move_and_slide()
