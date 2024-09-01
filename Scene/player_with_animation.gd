extends CharacterBody2D

@onready var tile_map = $"../TileMapLayer"
@onready var sprite_2d = $AnimatedSprite2D

var is_moving = false
var AnimDirection = ''

func _physics_process(_delta):
	if is_moving == false:
		return
		
	if global_position == sprite_2d.global_position:
		is_moving = false
		return
	
	sprite_2d.global_position = sprite_2d.global_position.move_toward(global_position, 1)
	
	if AnimDirection == 'UP':
		sprite_2d.flip_h = false
		sprite_2d.play('up')
	elif AnimDirection == 'DOWN':
		sprite_2d.flip_h = false
		sprite_2d.play('down')
	elif AnimDirection == "LEFT":
		sprite_2d.flip_h = false
		sprite_2d.play('left')
	elif AnimDirection == "RIGHT":
		sprite_2d.flip_h = true
		sprite_2d.play('right')
func _process(_delta):
	if is_moving:
		return
	
	if Input.is_action_pressed("up"):
		move(Vector2.UP)
		AnimDirection = 'UP'
	elif Input.is_action_pressed("down"):
		move(Vector2.DOWN)
		AnimDirection = 'DOWN'
	elif Input.is_action_pressed("left"):
		move(Vector2.LEFT)
		AnimDirection = 'LEFT'
	elif Input.is_action_pressed("right"):
		move(Vector2.RIGHT)
		AnimDirection = 'RIGHT'
		
func move(direction:Vector2i):
	# Get current tile Vector2i
	var current_tile: Vector2i = tile_map.local_to_map(global_position)
	# Get target tile Vector2i
	var target_tile: Vector2i = Vector2i(
		current_tile.x + direction.x,
		current_tile.y + direction.y,
	)
	prints(current_tile, target_tile)
	
	# Get custom data layer from target tile
	var tile_data: TileData = tile_map.get_cell_tile_data(target_tile)
	
	if tile_data == null or tile_data.get_custom_data("walkable") == false:
		return
		
	# Move player 
	is_moving = true
	
	global_position = tile_map.map_to_local(target_tile)
	
	sprite_2d.global_position = tile_map.map_to_local(current_tile)
	
