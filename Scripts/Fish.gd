extends CharacterBody2D

const speed = 50
const flee_speed = 100

@export var goal: Node = null
@export var _rotation_speed : float = TAU * 2 
var player = Vector2.ZERO

# Called every frame. 'delta' is tdhe elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	 # Get global navigation and direction to move
	var target_global = $NavigationAgent2D.get_next_path_position()
	var direction_global = (target_global - global_position).normalized()
	# Run away from player
	if player != Vector2.ZERO:
		direction_global = global_position - player
	# Get and apply rotation
	var desired_angle = atan2(direction_global.y, direction_global.x)
	var angle_diff = wrapf(desired_angle - rotation, -PI, PI)
	var max_turn = _rotation_speed * delta
	var actual_turn = clamp(angle_diff, -max_turn, max_turn)
	rotation += actual_turn
	# Move local direction (converted to global)
	var local_forward = Vector2.RIGHT
	var global_forward = local_forward.rotated(rotation)
	if player != Vector2.ZERO:
		velocity = global_forward * flee_speed
	else:
		velocity = global_forward * speed
	move_and_slide()
	#queue_redraw()

func run_from_player(dir: Vector2) -> void:
	player = dir

func rest() -> void:
	player = Vector2.ZERO

func make_path() -> void:
	$NavigationAgent2D.target_position = goal.global_position

func _on_timer_timeout() -> void:
	make_path()

#func _draw():
	# Draw current facing direction (GREEN)
	#var facing = Vector2.RIGHT.rotated(rotation)
	#draw_line(Vector2.ZERO, (global_position-player), Color.DARK_RED, 2.0)
	#draw_circle(,10,Color.BLUE,)
