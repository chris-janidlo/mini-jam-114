tool
extends Node2D

export var meter_push_accel: float
export var meter_push_cut_speed: float
export var meter_decel: float

export var overexert_stun_time: float

export(Array, Resource) var power_by_meter_position := [] setget _set_power_by_meter_position
export var fluctuation_amount_by_power: Curve
export var max_fluctuation: float

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
	randomize()

	left_meter_state = MeterState.new("left")
	right_meter_state = MeterState.new("right")


func _process(delta):
	if Engine.editor_hint: return

	_manage_meter(delta, left_meter_state)
	_manage_meter(delta, right_meter_state)
	
	_manage_beam(delta)


func _set_power_by_meter_position(value: Array) -> void:
	power_by_meter_position = []
	for element in value:
		var to_append := element as BeamPowerSpec
		if to_append == null:
			to_append = BeamPowerSpec.new()
		power_by_meter_position.append(to_append)


func _manage_meter(delta: float, meter: MeterState) -> void:
	meter.stun_timer -= delta
	if meter.stun_timer > 0:
		return

	if Input.is_action_just_pressed(input_action_prefix + meter.side):
		meter.velocity = max(
			meter_push_cut_speed,
			meter.velocity + meter_push_accel
		)
	else:
		meter.velocity -= meter_decel * delta

	meter.position += meter.velocity * delta
	meter.position = clamp(meter.position, 0, 100)

	if meter.position == 0 or meter.position == 100:
		meter.stun_timer = overexert_stun_time
		meter.position = 50
		meter.velocity = 0


func _manage_beam(delta: float) -> void:
	var power := get_overall_power()
	var fluctuation := _get_fluctuation(power)

	beam_position += (power + fluctuation) * delta
	beam_position = clamp(beam_position, 0, 100)

	if beam_position == 0:
		print("game over")
	if beam_position == 1:
		print("you win")


func get_overall_power() -> float:
	return (get_side_power(left_meter_state) + get_side_power(right_meter_state))/2


func get_side_power(meter: MeterState) -> float:
	for element in power_by_meter_position:
		if meter.position < element.max_position:
			return element.power
	
	assert(false, "shouldn't ever be here")
	return NAN


func _get_fluctuation(power: float) -> float:
	var amount := fluctuation_amount_by_power.interpolate_baked(power)
	amount *= max_fluctuation
	return rand_range(-amount, amount)
