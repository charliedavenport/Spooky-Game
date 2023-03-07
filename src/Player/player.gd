extends CharacterBody2D
class_name Player

const move_speed = 65.0

const torch_scene = preload("res://src/Torch/torch.tscn")

@onready var self_light = $PlayerLight
@onready var torch_light = $Hand/Torch/TorchLight
@onready var flashlight = $Hand/Flashlight
@onready var sprite = $Sprite2D
@onready var anim = $AnimationPlayer
@onready var hand = $Hand
@onready var pickup_area = $PickUpArea
@onready var torch = $Hand/Torch

var has_torch : bool
var available_torch

signal torch_dropped(torch)

func _ready():
	self_light.show()
	pickup_area.connect("area_entered", on_pickup_area_entered)
	pickup_area.connect("area_exited", on_pickup_area_exited)
	
	set_has_torch(false)
	
	$Camera2D/ColorRect.show()


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
	
	if velocity.length() > 0.5:
		if (velocity.x < -0.1):
			flip_self(true)
		elif (velocity.x > 0.1):
			flip_self(false)
		
		
		if not anim.current_animation == "walk" or anim.current_animation == "walk_torch":
			anim.play("walk_torch" if has_torch else "walk")
	else:
		anim.play("idle_torch" if has_torch else "idle")


func flip_self(is_flipped: bool) -> void:
	sprite.flip_h = is_flipped
	if is_flipped:
		hand.position.x = abs(hand.position.x) * -1.0
	else:
		hand.position.x = abs(hand.position.x)


func _process(delta):
	flashlight.look_at(get_global_mouse_position())


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
	if anim.is_playing():
		var pos = anim.current_animation_position
		if anim.current_animation == "walk":
			anim.play("walk_torch")
		elif anim.current_animation == "idle":
			anim.play("idle_torch")
		anim.seek(pos)


func on_pickup_area_exited(area) -> void:
	if has_torch or not available_torch:
		return
	
	if not area.get_parent().can_be_picked_up:
		return
	
	available_torch.hide_label()
	available_torch = null

