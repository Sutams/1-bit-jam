extends Node

var rect
var clam_open = true
var chest_open = true

# Do this for the other variables!
@onready var fog_sprite = $FogSprite
@onready var map = $NavigationRegion2D
@onready var player = $Player
var fog_image : Image
var vision_image : Image

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rect = $NavigationRegion2D.get_bounds()
	#generate_fog()
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _physics_process(_delta: float) -> void:
	##if player.velocity.length():
		##update_fog()
	#pass
#
#
#func generate_fog()-> void:
	##var fog_size = 16
	#var map_size_x = (rect.end.x-rect.position.x)*16
	#var map_size_y = (rect.end.y-rect.position.y)*16
	#
	#fog_image = Image.create(map_size_x, map_size_y, false, Image.Format.FORMAT_RGBAH)
	#fog_image.fill(Color.DIM_GRAY)
	#
	#fog_sprite.texture = ImageTexture.create_from_image(fog_image)
	#
	#vision_image = player.vision_sprite.texture.get_image()
	#vision_image.convert(Image.Format.FORMAT_RGBAH)
#
#func update_fog()-> void:
	#var vision_rect = Rect2(Vector2.ZERO, vision_image.get_size())
	#fog_image.blend_rect(fog_image,vision_rect, player.global_position)
	#var fog_texture = ImageTexture.create_from_image(fog_image)
	#fog_sprite.texture = fog_texture

func fish_path(body: Node2D) -> void:
	if body.name == "Fish":
		$Goal.global_position = Vector2(randf_range(rect.position.x,rect.end.x),
										randf_range(rect.position.y,rect.end.y))
		body.make_path()


func _on_goal_body_entered(body: Node2D) -> void:
	fish_path(body)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		$Fish.run_from_player(body.global_position)


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		await get_tree().create_timer(1.0).timeout
		$Fish.rest()
		fish_path($Fish)


func _on_clam_timer_timeout() -> void:
	if $Clam/GemArea:
		if clam_open:
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
