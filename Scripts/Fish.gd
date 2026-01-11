extends CharacterBody2D

const SIZE = 10
const SPEED = 50
const FLEE_SPEED = 100
var _rotation_speed : float = TAU * 2 

@onready var nav_agent = $NavigationAgent2D
@export var map_bounds : Rect2
var player_position = Vector2.ZERO
var goal : Vector2


func _ready() -> void:
	await get_tree().create_timer(1).timeout
	new_path()

func _physics_process(delta: float) -> void:
	 # Get global navigation and direction to move
	var target_global = nav_agent.get_next_path_position()
	var direction_global = (target_global - global_position).normalized()
	
	# Check if at goal yet
	if global_position.distance_to(goal) < 100:
		new_path()
	
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


func new_path() -> void:
	goal = Vector2(randf_range(map_bounds.position.x,map_bounds.end.x),
					randf_range(map_bounds.position.y,map_bounds.end.y))
	nav_agent.target_position = goal


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_position = body.global_position


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		await get_tree().create_timer(1.0).timeout
		player_position = Vector2.ZERO
		new_path()
