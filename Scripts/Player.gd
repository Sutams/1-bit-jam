extends CharacterBody2D

const SPEED = 70.0
const DEACC = 0.8
const init_light_deg = 180
var light_deg = init_light_deg
var weights = 2.3

func _ready() -> void:
	$AnimatedSprite2D.flip_h = false

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("drop"):
		if weights > 1:
			weights -= 1
			print(weights)
	if Input.is_action_just_pressed("interact"):
		if weights < 3:
			weights += 1
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var move_y := Input.get_axis("up", "down")
	if move_y:
		velocity.y = move_y * SPEED
		#light_deg = move_toward(light_deg, light_deg+move_y, 1)
	else:
		velocity.y = move_toward(velocity.y, 0, DEACC)
	
	var move_x := Input.get_axis("left", "right")
	if move_x:
		velocity.x = move_x * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, DEACC)
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta * 1/3
	
	if velocity.length() > 0:
		$AnimatedSprite2D.play("Walk")
	else:
		$AnimatedSprite2D.play("Idle")
		
	if velocity.x > 0:
		$AnimatedSprite2D.flip_h = false
		light_deg = move_toward(light_deg, 180, 30)
	if velocity.x < 0:
		$AnimatedSprite2D.flip_h = true
		light_deg = move_toward(light_deg, 360, 30)
	
	$PointLight2D.rotation_degrees = light_deg
	$LightOccluder2D.rotation_degrees = light_deg
	
	move_and_slide()
