extends Control

export var left_progress_bar: NodePath
export var right_progress_bar: NodePath

onready var _left_bar := get_node(left_progress_bar) as Range
onready var _right_bar := get_node(right_progress_bar) as Range

func _process(_delta):
	_left_bar.value = BeamManager.left_meter_state.position
	_right_bar.value = BeamManager.right_meter_state.position
