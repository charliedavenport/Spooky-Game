extends CharacterBody2D
class_name Enemy

const RAYCAST_RANGE = 200
const CHASE_SPEED = 20.0
const MIN_DIST_TO_PLAYER = 40.0

enum State {IDLE, CHASE, ATK}

@onready var spritesheet : PlayerSpriteSheet = $PlayerSpriteSheet
@onready var nav_agent : NavigationAgent2D = $NavigationAgent2D
@onready var raycasts = [
	$Raycasts/RayCast2D  as RayCast2D,
	$Raycasts/RayCast2D2 as RayCast2D,
	$Raycasts/RayCast2D3 as RayCast2D
]
@onready var lines = [
	$Lines/Line2D,
	$Lines/Line2D2,
	$Lines/Line2D3
]

var curr_state : State
var player_target : Player
var raycast_targets : Array[Node2D]

func _ready():
	spritesheet.set_fps(6)
	spritesheet.go_idle()
	
	spritesheet.set_fps(6)
	
	set_state(State.IDLE)
	
	$Lines.hide()


func set_player_target(p_target) -> void:
	player_target = p_target
	raycast_targets = player_target.get_raycast_targets()

func _process(delta):
	if player_target == null or not is_instance_valid(player_target):
		return
	
	# point raycasts to player raycast targets
	for i in range(3):
		var offset = raycast_targets[i].global_position - raycasts[i].global_position
		raycasts[i].target_position = offset.normalized() * RAYCAST_RANGE
	
	match curr_state:
		State.IDLE:
			pass
		State.CHASE:
			pass
		State.ATK:
			pass


func check_raycasts() -> bool:
	var can_see_player = false
	for i in range(3):
		var line : Line2D = lines[i]
		line.default_color = Color.RED
		var ray : RayCast2D = raycasts[i]
		if ray.is_colliding():
			line.points[1] = line.to_local(ray.get_collision_point())
			var collider = ray.get_collider()
			if collider is Area2D:
				can_see_player = true
				line.default_color = Color.GREEN
		else:
			line.points[1] = ray.target_position
	
	return can_see_player


func _physics_process(delta):
	if player_target == null or not is_instance_valid(player_target):
		return
	
	var dist_to_player = (player_target.global_position - global_position).length()
	
	var can_see_player = check_raycasts()
	
	if curr_state == State.IDLE:
		if can_see_player:
			set_state(State.CHASE)
			return
	
	if curr_state == State.CHASE:
		if dist_to_player < MIN_DIST_TO_PLAYER:
			return
		if dist_to_player > RAYCAST_RANGE or not can_see_player:
			set_state(State.IDLE)
			return
		
		nav_agent.target_position = player_target.global_position
		var next_path_pos := nav_agent.get_next_path_position()
		var new_vel = (next_path_pos - global_position).normalized() * CHASE_SPEED
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
		State.CHASE:
			spritesheet.do_walk_anim()
		State.ATK:
			pass


func flip_self(value: bool) -> void:
	if spritesheet.frame_coords.y < 2:
		spritesheet.flip_h = value
	else:
		spritesheet.flip_h = false

func toggle_debug() -> void:
	$Lines.visible = not $Lines.visible
