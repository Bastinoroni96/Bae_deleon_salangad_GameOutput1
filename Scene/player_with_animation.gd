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
		# play with animation
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
		
		var current_tile: Vector2i = tile_map.local_to_map(global_position)
		if Input.is_action_pressed("up"):
			move(current_tile,Vector2.UP)
			AnimDirection = 'UP'
		elif Input.is_action_pressed("down"):
			move(current_tile,Vector2.DOWN)
			AnimDirection = 'DOWN'
		elif Input.is_action_pressed("left"):
			move(current_tile,Vector2.LEFT)
			AnimDirection = 'LEFT'
		elif Input.is_action_pressed("right"):
			move(current_tile,Vector2.RIGHT)
			AnimDirection = 'RIGHT'
		
func move(current_tile: Vector2i, direction:Vector2i):
	# Get current tile Vector2i
	
	# Get target tile Vector2i
	var target_tile: Vector2i = Vector2i(
		current_tile.x + direction.x,
		current_tile.y + direction.y,
	)
	#prints(current_tile, target_tile)
	
	# Get custom data layer from target tile
	var target_tile_data: TileData = tile_map.get_cell_tile_data(target_tile)
	var slide_last_tile: Vector2i

		
	
	# forceMove the player
	# note: ice tiles and arrow tiles are both walkable and slidable
	if target_tile_data.get_custom_data("slidable") == true:
		if (target_tile_data.get_custom_data("direction") != ""):
			slide_last_tile = getSlideLastTile(target_tile, direction)
		target_tile = slide_last_tile
		# resets the player in the starting point (try not to change the map cuz i hard core the position)
		#target_tile = Vector2i(2,4)
		#current_tile = Vector2i(2,4)
		#global_position = tile_map.map_to_local(target_tile)
		#sprite_2d.global_position = tile_map.map_to_local(current_tile)

	if target_tile_data == null or target_tile_data.get_custom_data("walkable") == false:
		return
	
	# Move player 
	is_moving = true
	global_position = tile_map.map_to_local(target_tile)
	sprite_2d.global_position = tile_map.map_to_local(current_tile)
	
func getSlideLastTile(current_tile: Vector2i, direction:Vector2i):
	var slide_target_tile = current_tile
	var slide_tile_data: TileData = tile_map.get_cell_tile_data(slide_target_tile)
	
	while (slide_tile_data.get_custom_data("slidable") == true) and (slide_tile_data.get_custom_data("walkable") == true):
		if (slide_tile_data.get_custom_data("direction") == 'ICE'):
			slide_target_tile += Vector2i(direction)
			slide_tile_data = tile_map.get_cell_tile_data(slide_target_tile)
		elif (slide_tile_data.get_custom_data("direction") == 'DOWN'):
			slide_target_tile += Vector2i(0,1)
			slide_tile_data = tile_map.get_cell_tile_data(slide_target_tile)
		elif (slide_tile_data.get_custom_data("direction") == 'UP'):
			slide_target_tile += Vector2i(0,-1)
			slide_tile_data = tile_map.get_cell_tile_data(slide_target_tile)
		elif (slide_tile_data.get_custom_data("direction") == 'LEFT'):
			slide_target_tile += Vector2i(-1,0)
			slide_tile_data = tile_map.get_cell_tile_data(slide_target_tile)
		elif (slide_tile_data.get_custom_data("direction") == 'RIGHT'):
			slide_target_tile += Vector2i(1,0)
			slide_tile_data = tile_map.get_cell_tile_data(slide_target_tile)

	if slide_target_tile == null or slide_tile_data.get_custom_data("walkable") == false:
		slide_target_tile -= Vector2i(direction)
		
	if slide_tile_data.get_custom_data("dead") == true:
		global_position = tile_map.map_to_local(slide_target_tile)
		sprite_2d.global_position = tile_map.map_to_local(current_tile)
		while sprite_2d.global_position != global_position:
			print('')
		slide_target_tile = Vector2i(2,4)
		current_tile = Vector2i(2,4)
		global_position = tile_map.map_to_local(slide_target_tile)
		sprite_2d.global_position = tile_map.map_to_local(current_tile)
		
	return(slide_target_tile)

func movePlayer(target_tile, current_tile):
	is_moving = true
	global_position = tile_map.map_to_local(target_tile)
	sprite_2d.global_position = tile_map.map_to_local(current_tile)
