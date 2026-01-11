extends Node

@onready var map = $NavigationRegion2D
var map_bounds

@onready var player = $Player

@export var fish_scene: PackedScene
@onready var fish_container = $FishSpawner
var fish_list : Array[Node] # GemArea scattered on the map
@export var max_fish = 5

@onready var clam = $Clam
@onready var clam_gem = $Clam/GemArea
@onready var chest_gem = $Chest/GemArea
var clam_open = true
var chest_open = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	map_bounds = map.get_bounds()
	for i in max_fish:
		spawn_fish()

func _process(_delta: float) -> void:
	for i in range(fish_list.size()):
		if fish_list[i] == null:
			fish_list.pop_at(i)
			spawn_fish()

func spawn_fish() -> void:
	var new_fish = fish_scene.instantiate()
	fish_container.add_child(new_fish)
	fish_list.append(new_fish)
	new_fish.global_position = fish_container.position + Vector2(randf_range(1,20),randf_range(1,20))
	new_fish.map_bounds = map_bounds


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
	if chest_gem:
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
