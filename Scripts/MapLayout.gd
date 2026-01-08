@tool
extends StaticBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not Engine.is_editor_hint():
		var coll := CollisionPolygon2D.new()
		coll.polygon = $Polygon2D.polygon
		add_child(coll)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		if $Polygon2D.polygon:
			var points := PackedVector2Array($Polygon2D.polygon)
			points.append($Polygon2D.polygon[0])
			$Line2D.points = points
			var points_occ := OccluderPolygon2D.new()
			points_occ.polygon = $Polygon2D.polygon
			$LightOccluder2D.occluder = points_occ
