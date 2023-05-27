extends Sprite2D


const DIRECTION_TO_FRAME := {
	Vector2.DOWN: 0,
	Vector2.DOWN + Vector2.RIGHT:1,
	Vector2.RIGHT: 2,
	Vector2.UP + Vector2.RIGHT: 3,
	Vector2.UP: 4,
	
}
# Will use input to determine which sprite sheet to grab

# sprite leans forward when moving. This limits its angle
const MAX_LEANING_ANGLE := PI / 12.0

@onready var _animation_player := $AnimationPlayer

func _physics_process(delta: float) -> void: # fix so the sprite moves with card movement
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction_key := direction.round()
	direction_key.x = abs(direction_key.x)
	if direction_key in DIRECTION_TO_FRAME:
		frame = DIRECTION_TO_FRAME[direction_key]
		flip_h = sign(direction.x) == -1
#
	rotation = lerp(rotation, direction.x * MAX_LEANING_ANGLE, 20.0 * delta)
	pass
