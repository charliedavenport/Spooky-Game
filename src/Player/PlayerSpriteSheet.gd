extends Sprite2D
class_name PlayerSpriteSheet

enum State {IDLE, WALK}
enum Dir {UP, DOWN, RIGHT, LEFT}

var curr_state : State

func _ready():
	$AnimTimer.timeout.connect(on_anim_timeout)

func set_fps(frames_per_second : int) -> void:
	var interval = 1.0 / float(frames_per_second)
	$AnimTimer.wait_time = interval

func is_walking() -> bool:
	return curr_state == State.WALK

func is_idle() -> bool:
	return curr_state == State.IDLE

func go_idle(vel = null, has_torch = null) -> void:
	set_state(State.IDLE)
	frame_coords.x = 0
	if vel != null and has_torch != null: 
		set_y_coord(vel, has_torch)
	else:
		set_y_coord(Vector2.RIGHT, false)

func do_walk_anim() -> void:
	set_state(State.WALK)
	frame_coords.x = 1
	$AnimTimer.start()

func on_anim_timeout() -> void:
	if curr_state != State.WALK:
		return
	frame_coords.x = wrapi(frame_coords.x + 1, 1, hframes)
	if frame_coords.x == 1 or frame_coords.x == 5:
		$FootstepAudio.play()

func set_state(value : State) -> void:
	match curr_state:
		State.IDLE:
			pass
		State.WALK:
			$AnimTimer.stop()
	curr_state = value

func set_y_coord(vel : Vector2, has_torch : bool) -> void:
	# rotate the vel.angle(), so that 0 deg is pointing up
	var rot = wrapf(vel.angle() + PI/2.0, -1 * PI, PI)
	var check_rot = abs(rot)
	
	if check_rot < 0.25 * PI:
		# UP
		frame_coords.y = 4
	elif check_rot < 0.75 * PI:
		# RIGHT
		frame_coords.y = 0
	else:
		# DOWN
		frame_coords.y = 2
	
	if has_torch:
		frame_coords.y += 1





