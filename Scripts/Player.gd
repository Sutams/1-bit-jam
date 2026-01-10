extends CharacterBody2D

const speed = 75.0
const deacc = 2
const init_light_deg = 180
var light_deg = init_light_deg
var weights = 2.3
var health = 3
var took_damage = false
var rotation_speed = 30

@onready var vision_sprite = $VisionSprite

func _ready() -> void:
	$AnimatedSprite2D.flip_h = false
	$PointLight2D.rotation_degrees = 180

func damage():
	health -=1
	print("-1hp")
	if health > 0:
		await get_tree().create_timer(1.5).timeout
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
				damage()

	
	if Input.is_action_just_pressed("drop"):
		if weights > 1:
			weights -= 1
			print(weights)
	if Input.is_action_just_pressed("interact"):
		if weights < 3:
			weights += 1
	
	
	var move_x := Input.get_axis("left", "right")
	if move_x:
		velocity.x = move_x * speed
	else:
		velocity.x = move_toward(velocity.x, 0, deacc)
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var move_y := Input.get_axis("up", "down")
	if move_y:
		velocity.y = move_y * speed
		light_deg = move_toward(light_deg, 90, 30)
		#light_deg = move_toward(light_deg, light_deg+move_y, 1)
	else:
		velocity.y = move_toward(velocity.y, 0, deacc)
	
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
	
	#$PointLight2D.rotation_degrees = light_deg
	move_and_slide()
	#queue_redraw()

#func _draw():
	
	#var facing = Vector2.RIGHT.rotated(rotation)
	#draw_line(Vector2.ZERO, velocity*10, Color.AQUA, 3.0)
	
	#draw_circle(,10,Color.BLUE,)
