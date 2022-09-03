extends Node2D

export var meter_push_increase_amount: float
export var meter_decrease_acceleration: float
export var overexert_stun_time: float

export var power_by_meter_position: Curve
export var power_multiplier: float

export var input_action_prefix: String

var beam_position := 50.0

class MeterState:
	var side: String
	var position: float
	var velocity: float
	var stun_timer: float

	func _init(i_side: String) -> void:
		side = i_side
		position = 50.0
		velocity = 0.0
		stun_timer = 0.0

	func to_s() -> String:
		return (
			"MeterState(side: %s, position: %f, velocity: %f, stun_timer: %f)" %
			[side, position, velocity, stun_timer]
		)

var left_meter_state: MeterState
var right_meter_state: MeterState


func _ready():
	left_meter_state = MeterState.new("left")
	right_meter_state = MeterState.new("right")


func _process(delta):
	_manage_meter(delta, left_meter_state)
	_manage_meter(delta, right_meter_state)
	
	beam_position += get_overall_power() * delta
	beam_position = clamp(beam_position, 0, 100)

	if beam_position == 0:
		print("game over")
	if beam_position == 1:
		print("you win")


func _manage_meter(delta: float, meter: MeterState) -> void:
	meter.stun_timer -= delta
	if meter.stun_timer > 0:
		return

	if Input.is_action_just_pressed(input_action_prefix + meter.side):
		meter.position += meter_push_increase_amount
		meter.velocity = 0
	else:
		meter.velocity += meter_decrease_acceleration * delta
		meter.position -= meter.velocity * delta

	meter.position = clamp(meter.position, 0, 100)
	if meter.position == 100:
		meter.stun_timer = overexert_stun_time


func get_overall_power() -> float:
	return (get_side_power(left_meter_state) + get_side_power(right_meter_state))/2


func get_side_power(meter: MeterState) -> float:
	return power_by_meter_position.interpolate_baked(meter.position)
