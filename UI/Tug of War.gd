extends Control


export var progress_bar: NodePath

onready var _bar := get_node(progress_bar) as Range


func _process(_delta):
	_bar.value = BeamManager.beam_position * 100
