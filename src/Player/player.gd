extends CharacterBody2D
class_name Player

const move_speed = 65.0

const torch_scene = preload("res://src/Torch/torch.tscn")

@onready var self_light = $PlayerLight
@onready var torch_light = $Hand/Torch/TorchLight
@onready var flashlight = $Hand/Flashlight
@onready var anim = $AnimationPlayer
@onready var hand = $Hand
@onready var pickup_area = $PickUpArea
@onready var torch = $Hand/Torch
@onready var spritesheet : PlayerSpriteSheet = $PlayerSpriteSheet
@onready var raycast_target : Node2D = $RaycastTarget
@onready var anim_tree : AnimationTree = $MixamoSpriteSheet/AnimationTree

var has_torch : bool
var available_torch

signal torch_dropped(torch)
signal toggle_debug()

func _ready():
	self_light.show()
	pickup_area.connect("area_entered", on_pickup_area_entered)
	pickup_area.connect("area_exited", on_pickup_area_exited)
	
	set_has_torch(false)
	
	$PlayerCamera.target = self
	
	spritesheet.set_fps(6)
	spritesheet.go_idle()


func _physics_process(delta):
	var last_vel = velocity
	var new_vel = Vector2.ZERO
	if Input.is_action_pressed("move_down"):
		new_vel.y += 1
	if Input.is_action_pressed("move_up"):
		new_vel.y -= 1
	if Input.is_action_pressed("move_left"):
		new_vel.x -= 1
	if Input.is_action_pressed("move_right"):
		new_vel.x += 1
	
	new_vel = new_vel.normalized() * move_speed
	velocity = last_vel.lerp(new_vel, 0.25)
	
	move_and_slide()
	
	spritesheet.set_y_coord(velocity, has_torch)
	
	if new_vel != Vector2.ZERO:
		var anim_vec = Vector2(abs(velocity.x), velocity.y)
		anim_tree.set("parameters/idle/blend_position", anim_vec)
		anim_tree.set("parameters/walk/blend_position", anim_vec)
		anim_tree.set("parameters/walkTorch/blend_position", anim_vec)
	
	if velocity.length() > 0.5:
		if (velocity.x < -0.1):
			flip_self(true)
		elif (velocity.x > 0.1):
			flip_self(false)
		
		anim_tree.get("parameters/playback").travel("walkTorch" if has_torch else "walk")
		if not spritesheet.is_walking():
			spritesheet.do_walk_anim()
	else:
		anim_tree.get("parameters/playback").travel("idle")
		spritesheet.go_idle(velocity, has_torch)


func flip_self(is_flipped: bool) -> void:
	$MixamoSpriteSheet.flip_h = is_flipped
	
	if spritesheet.frame_coords.y >= 2:
		spritesheet.flip_h = false
		hand.position.x = abs(hand.position.x)
	else:
		spritesheet.flip_h = is_flipped
		if is_flipped:
			hand.position.x = abs(hand.position.x) * -1.0
		else:
			hand.position.x = abs(hand.position.x)


func _process(delta):
	var mouse_pos = get_viewport().get_final_transform().basis_xform_inv(get_global_mouse_position())
	flashlight.look_at(mouse_pos)


func _input(event):
	if event.is_action_pressed("flashlight"):
		flashlight.enabled = not flashlight.enabled
	
	if event.is_action_pressed("pickup"): 
		if available_torch:
			set_has_torch(true)
			available_torch.queue_free()
			available_torch = null
		elif has_torch:
			drop_torch()
	
	if event.is_action_pressed("toggle_debug"):
		toggle_debug.emit()


func on_pickup_area_entered(area) -> void:
	if available_torch or has_torch:
		return
	
	available_torch = area.get_parent()
	available_torch.show_label()


func drop_torch() -> void:
	if not has_torch:
		printerr("drop_torch() should not be called if has_torch is false")
	
	set_has_torch(false)
	
	var dropped_torch : Torch = torch_scene.instantiate()
	emit_signal("torch_dropped", dropped_torch)
	
	dropped_torch.global_position = hand.global_position
	dropped_torch.can_be_picked_up = false
	
	var tween = get_tree().create_tween()
	var target_loc = hand.global_position + Vector2(0, 33)
	tween.tween_property(dropped_torch, "global_position", target_loc, 0.5)\
		.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(dropped_torch.get_node("Sprite2D"), "rotation", TAU/4.0, 0.2)
	tween.tween_property(dropped_torch, "can_be_picked_up", true, 0.0)


func set_has_torch(value : bool) -> void:
	has_torch = value
	torch.visible = value
	torch_light.visible = value


func on_pickup_area_exited(area) -> void:
	if has_torch or not available_torch:
		return
	
	if not area.get_parent().can_be_picked_up:
		return
	
	available_torch.hide_label()
	available_torch = null

func get_raycast_targets() -> Array[Node2D]:
	return [
		$RaycastTarget/Target_01 as Node2D,
		$RaycastTarget/Target_02 as Node2D,
		$RaycastTarget/Target_03 as Node2D
	]
	
