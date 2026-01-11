extends CharacterBody2D

# Movement
const MAXSPEED = 75.0
var acc = 1.0
const HALT = 2
@onready var player_sprite = $AnimatedSprite2D

# Lights
var rotation_speed = 30
@onready var flashlight = $PointLight2D

# HP
@export var heart_scene: PackedScene
@onready var hearts_container = $UI/HeartsContainer
@onready var hit_flash_anim = $HitAnimationPlayer
var hearts_list : Array[Node]
var HP = 3
var took_damage = false

# Scoring system, but now that i think about it its weird that 
# its here in the player script instead of the game one
@export var gem_scene: PackedScene
@onready var gems_container = $UI/GemsContainer
var gems_list : Array[Node] # GemArea scattered on the map
var gemsUI_list : Array[Node] # Gem UI element
var score = 0

# I know i should make this separate but dont have the time
@onready var menu_panel = $UI/Menu
@onready var start_button = $UI/Menu/Panel/Button
var restart = false


func _ready() -> void:
	gems_list = get_tree().get_nodes_in_group("Gem")
	if !gem_scene:
		return
	
	for i in range(gems_list.size()):
		var new_gem = gem_scene.instantiate()
		gems_container.add_child(new_gem)
		gemsUI_list.append(new_gem)
	if !heart_scene:
		return
	# Add hearts
	for i in range(HP):
		var new_heart = heart_scene.instantiate()
		hearts_container.add_child(new_heart)
		hearts_list.append(new_heart)


func show_menu(msg : String)-> void:
	menu_panel.set_deferred("visible", true)
	$UI/Menu/Panel/Label.text = msg
	restart = true


func reset_scene()-> void:
	get_tree().call_deferred("reload_current_scene")


func add_score(gem: Node):
	score +=1
	for i in range(gems_list.size()):
		if gem == gems_list[i]:
			var gem_sprite = gemsUI_list[i].get_node("GemSprite")
			gem_sprite.set_deferred("modulate", Color.WHITE)
	if score >= gems_list.size():
		show_menu("Thanks for playing Delve!")


func take_damage():
	HP -=1
	for i in range(hearts_list.size()):
		var heart_sprite = hearts_list[i].get_node("HeartSprite")
		if i < HP:
			heart_sprite.play("Full")
		if i == HP:
			heart_sprite.play("Damage")
	hit_flash_anim.play("hit_flash")
	await get_tree().create_timer(1).timeout
	hit_flash_anim.stop()
	if HP > 0:
		took_damage = false
		return
	reset_scene()


func _physics_process(delta: float) -> void:
	for i in get_slide_collision_count():
		var coll = get_slide_collision(i)
		if coll.get_collider().name == "Spikes":
			if !took_damage:
				took_damage = !took_damage
				take_damage()
	
	var move_x := Input.get_axis("left", "right")
	var move_y := Input.get_axis("up", "down")
	
	if move_x or move_y:
		if acc < MAXSPEED:
			acc += 1
		velocity.x = move_x * acc
	else:
		if acc > 1:
			acc -= 1
	
	if move_x:
		velocity.x = move_x * acc
	else:
		velocity.x = move_toward(velocity.x, 0, HALT)
	
	if move_y:
		velocity.y = move_y * acc
	else:
		velocity.y = move_toward(velocity.y, 0, HALT)
	
	# Add the gravity.
	if not is_on_floor():
		velocity += (get_gravity() * delta * score/2)/3
	
	if velocity.length() > 0:
		player_sprite.play("Walk")
	else:
		player_sprite.play("Idle")
	
	var target_angle = velocity.angle()+PI
	if velocity.x > 0:
		player_sprite.flip_h = false
	if velocity.x < 0:
		player_sprite.flip_h = true
	if velocity == Vector2.ZERO:
		if player_sprite.flip_h:
			target_angle = 0
		else:
			target_angle = PI
	
	flashlight.rotation = lerp_angle(flashlight.rotation, target_angle, delta * rotation_speed)
	
	move_and_slide()


func _on_button_button_down() -> void:
	menu_panel.set_deferred("visible", false)
	if restart:
		reset_scene()
