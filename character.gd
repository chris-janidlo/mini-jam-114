extends Sprite


#false = player, true = enemy
export var enemy : bool


func _ready():
	if enemy == false:
		self.texture = preload("res://art/player_sprite_sheet.png")
	elif enemy == true:
		self.texture = preload("res://art/enemy_sprite_sheet.png")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func beam_spawn():
	if enemy == false:
		var beam = load("res://beam.tscn")
		var beam_instance = beam.instance()
		get_parent().add_child(beam_instance)
		get_parent().get_node("beam").position = Vector2(56.5, 28.5)
#		get_parent().get_node("beam").started = true
