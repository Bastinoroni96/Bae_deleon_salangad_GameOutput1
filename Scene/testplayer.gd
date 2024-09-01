extends CharacterBody2D

@onready var tile_map = $"../TileMapLayer"
@onready var sprite_2d = $AnimatedSprite2D
@onready var playerRef = $"."
@onready var rayCast = $RayCast2D
#export var walk_speed = 4.0
var walk_speed = 4.0
const TILE_SIZE = 16

var initial_position = Vector2(0,0)
var input_direction = Vector2(0,0)
var is_moving = false
var percent_moved_to_next_tile = 0.0
var prev_input_direction = Vector2(0,0)


var isWall = false

func _ready():
	initial_position = position


func _physics_process(delta):
	if is_moving == false:
		process_player_input()
	elif input_direction != Vector2.ZERO:
		move(delta)
	else:
		is_moving = false
func process_player_input():
	var current_tile: Vector2i = tile_map.local_to_map(global_position)
	var currennt_tile_data: TileData = tile_map.get_cell_tile_data(current_tile)
	

	
	#check if the player is in dead tilesa
	if currennt_tile_data.get_custom_data("dead") == true:
		playerRef.global_position = Vector2(0,0)
		
	#check if the player is in forced tiles
	#print(checkRayCast)
	isWall = false
	if currennt_tile_data.get_custom_data("slidable") == true:
		if currennt_tile_data.get_custom_data("direction") == "ICE":
			input_direction = prev_input_direction
				#Do RayCast
			var desired_step : Vector2 = input_direction * TILE_SIZE / 2
			var checkRayCast = rayCastCheck(desired_step)
			
			if checkRayCast:
				input_direction.x =  0
				input_direction.y =  0
				isWall = true
	
		
		elif currennt_tile_data.get_custom_data("direction") == "LEFT":
			input_direction.y =  0
			input_direction.x =  -1
			prev_input_direction = input_direction
		elif currennt_tile_data.get_custom_data("direction") == "RIGHT":
			input_direction.y =  0
			input_direction.x =  1
			prev_input_direction = input_direction
		elif currennt_tile_data.get_custom_data("direction") == "UP":
			input_direction.y =  -1
			input_direction.x =  0
			prev_input_direction = input_direction
		elif currennt_tile_data.get_custom_data("direction") == "DOWN":
			input_direction.y =  1
			input_direction.x =  0
			prev_input_direction = input_direction
		
		if !isWall:
			initial_position = position
			is_moving = true
			return
	
	# check for the user input
	if input_direction.y == 0:
		input_direction.x = int(Input.is_action_just_pressed("right")) - int(Input.is_action_just_pressed("left"))
	if input_direction.x == 0:
		input_direction.y = int(Input.is_action_just_pressed("down")) - int(Input.is_action_just_pressed("up"))
	if input_direction != Vector2.ZERO:
		prev_input_direction = input_direction
		initial_position = position
		is_moving = true

func move(delta):
	var desired_step : Vector2 = input_direction * TILE_SIZE / 2
	var checkRayCast = rayCastCheck(desired_step)
	if !checkRayCast:
		percent_moved_to_next_tile += walk_speed * delta
		if percent_moved_to_next_tile >= 1.0:
			position = initial_position + (TILE_SIZE * input_direction)
			percent_moved_to_next_tile = 0.0
			is_moving = false 
		else:
			if input_direction.x < 0:
				sprite_2d.flip_h = false
				sprite_2d.play("left")
			elif input_direction.x > 0:
				sprite_2d.flip_h = true
				sprite_2d.play("left")
			elif input_direction.y < 0:
				sprite_2d.flip_h = false
				sprite_2d.play("up")
			elif input_direction.y > 0:
				sprite_2d.flip_h = false
				sprite_2d.play("down")
			position = initial_position + (TILE_SIZE * input_direction * percent_moved_to_next_tile)
	else:
		percent_moved_to_next_tile = 0.0
		is_moving = false
func rayCastCheck(desired_step):
	rayCast.target_position = desired_step
	rayCast.force_raycast_update()
	return (rayCast.is_colliding())
