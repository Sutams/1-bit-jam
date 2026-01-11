extends CharacterBody2D

const SPEED = 50
const FLEE_SPEED = 100
@export var _rotation_speed : float = TAU * 2 

@onready var nav_agent = $NavigationAgent2D
@export var goal: Node = null
var player_position = Vector2.ZERO


func _physics_process(delta: float) -> void:
	 # Get global navigation and direction to move
	var target_global = nav_agent.get_next_path_position()
	var direction_global = (target_global - global_position).normalized()
	
	# Run away from player
	if player_position != Vector2.ZERO:
		direction_global = global_position - player_position
	
	# Get and apply rotation
	var desired_angle = atan2(direction_global.y, direction_global.x)
	var angle_diff = wrapf(desired_angle - rotation, -PI, PI)
	var max_turn = _rotation_speed * delta
	var actual_turn = clamp(angle_diff, -max_turn, max_turn)
	rotation += actual_turn
	
	# Move local direction (converted to global)
	var local_forward = Vector2.RIGHT
	var global_forward = local_forward.rotated(rotation)
	if player_position != Vector2.ZERO:
		velocity = global_forward * FLEE_SPEED
	else:
		velocity = global_forward * SPEED
	move_and_slide()


func flee_from_player(dir: Vector2) -> void:
	player_position = dir


func rest() -> void:
	player_position = Vector2.ZERO


func make_path() -> void:
	nav_agent.target_position = goal.global_position


func _on_timer_timeout() -> void:
	make_path()
