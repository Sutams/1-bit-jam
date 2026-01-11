extends Node

@onready var map = $NavigationRegion2D
var map_bounds

@onready var player = $Player
@onready var fish = $Fish

@onready var clam = $Clam
@onready var clam_gem = $Clam/GemArea
var clam_open = true
var chest_open = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	map_bounds = map.get_bounds()

func fish_new_path(body: Node2D) -> void:
	if body.is_in_group("Fish"):
		$Goal.global_position = Vector2(randf_range(map_bounds.position.x,map_bounds.end.x),
										randf_range(map_bounds.position.y,map_bounds.end.y))
		body.make_path()


func _on_goal_body_entered(body: Node2D) -> void:
	fish_new_path(body)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		fish.flee_from_player(body.global_position)


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		await get_tree().create_timer(1.0).timeout
		fish.rest()
		fish_new_path(fish)


func _on_clam_timer_timeout() -> void:
	if clam_gem:
		if clam_open:
			#clam.
			$Clam/CollisionShape2D.set_deferred("disabled", false)
			$Clam/AnimatedSprite2D.play("Close")
			$Clam/GemArea/Sprite2D.visible = false
			$Clam/GemArea/PointLight2D.enabled = false
			$Clam/GemArea/PointLight2D2.enabled = false
		else: #Open clam
			$Clam/CollisionShape2D.set_deferred("disabled", true)
			$Clam/AnimatedSprite2D.play("Open")
			$Clam/GemArea/Sprite2D.visible = true
			$Clam/GemArea/PointLight2D.enabled = true
			$Clam/GemArea/PointLight2D2.enabled = true
		clam_open = !clam_open
	else:
		$Clam/ClamTimer.stop()

func _on_chest_timer_timeout() -> void:
	if $Chest/GemArea:
		if chest_open:
			$Chest/CollisionShape2D.set_deferred("disabled", false)
			$Chest/AnimatedSprite2D.play("Close")
			$Chest/GemArea/Sprite2D.visible = false
			$Chest/GemArea/PointLight2D.enabled = false
			$Chest/GemArea/PointLight2D2.enabled = false
		else: #Open chest
			$Chest/CollisionShape2D.set_deferred("disabled", true)
			$Chest/AnimatedSprite2D.play("Open")
			$Chest/GemArea/Sprite2D.visible = true
			$Chest/GemArea/PointLight2D.enabled = true
			$Chest/GemArea/PointLight2D2.enabled = true
		chest_open = !chest_open
	else:
		$Chest/ChestTimer.stop()
