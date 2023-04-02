extends CharacterBody2D
class_name Enemy

const raycast_range = 200
const WALK_SPEED = 20.0
const MIN_DIST_TO_PLAYER = 40.0
const MAX_DIST_TO_PLAYER = 400.0

enum State {IDLE, WALK, ATK}

@onready var spritesheet : PlayerSpriteSheet = $PlayerSpriteSheet
@onready var ray : RayCast2D = $RayCast2D
@onready var line : Line2D = $Line2D
@onready var nav_agent : NavigationAgent2D = $NavigationAgent2D

var curr_state : State
var player_target

func _ready():
	spritesheet.set_fps(6)
	spritesheet.go_idle()
	
	spritesheet.set_fps(6)
	
	set_state(State.IDLE)


func _process(delta):
	if player_target == null or not is_instance_valid(player_target):
		return
	var offset = player_target.raycast_target.global_position - global_position
	ray.target_position = offset.normalized() * raycast_range
	
	match curr_state:
		State.IDLE:
			pass
		State.WALK:
			pass
		State.ATK:
			pass


func _physics_process(delta):
	line.default_color = Color.RED
	var collider = ray.get_collider()
	if ray.is_colliding():
		line.points[1] = line.to_local(ray.get_collision_point())
		if collider is Area2D:
			if curr_state == State.IDLE:
				set_state(State.WALK)
			line.default_color = Color.GREEN
	else:
		line.points[1] = ray.target_position
	
	if curr_state == State.WALK:
		if player_target == null or not is_instance_valid(player_target):
			return
		
		var dist_to_player = (player_target.global_position - global_position).length()
		if dist_to_player < MIN_DIST_TO_PLAYER:
			return
		
		nav_agent.target_position = player_target.global_position
		var next_path_pos := nav_agent.get_next_path_position()
		var new_vel = (next_path_pos - global_position).normalized() * WALK_SPEED
		velocity = new_vel
		
		if velocity.length() > 0.3:
			if (velocity.x < -0.1):
				flip_self(true)
			elif (velocity.x > 0.1):
				flip_self(false)
		
		spritesheet.set_y_coord(velocity, false)
		
		move_and_slide()


func set_state(value : State) -> void:
	curr_state = value
	match curr_state:
		State.IDLE:
			spritesheet.go_idle()
		State.WALK:
			spritesheet.do_walk_anim()
		State.ATK:
			pass


func flip_self(value: bool) -> void:
	if spritesheet.frame_coords.y < 2:
		spritesheet.flip_h = value
	else:
		spritesheet.flip_h = false

