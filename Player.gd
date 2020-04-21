"""
Player Character.
This one uses janky physics :)
"""
extends Node2D

var jump = 0 	 # int to keep track of how many frames we're in the air
var jump_dir = 0 # direction of the jump on the x-Axis (-1, 0, 1)

# Called every physics frame.
func _physics_process(_delta: float) -> void:
	if jump > 0:
		# We jumped. Should move up
		var valid_pos = position # We are currently on a valid position
		# Here we define possible pixels we could move to.
		# The first one has the lowest priority (jump_dir, 0)
		# The last one has highest priority (jump_dir, -5)
		for dir in [Vector2(jump_dir, 0), Vector2(jump_dir, -1), Vector2(jump_dir, -2), Vector2(jump_dir, -3), Vector2(jump_dir, -4), Vector2(jump_dir, -5)]:
			var pos = position + dir
			if $"../Map".collision_normal(pos) == Vector2.ZERO:
				# new position doesn't habe a normal -> it's valid to move to
				valid_pos = pos
		jump -= 1 # reduce the jump counter
		position = valid_pos # move to the next valid position
		return # No other controls allowed while in the air
	var walk = jump_dir # set walk to jump_dir in case we are falling
	if $"../Map".collision_normal(position + Vector2.DOWN) != Vector2.ZERO:
		# the pixel below us is solid.
		jump_dir = 0 # reset jump_dir (we're not jumping)
		if Input.is_action_just_pressed("jump"):
			# we are trying to jump
			if jump == 0: # currently not rising
				jump_dir = Input.get_action_strength("right") - Input.get_action_strength("left")
				jump = 10 # We'll be rising for 10 frames
		# `Input.get_action_strength("right/left")` returns 0 or 1 depending on whether the button is pressed
		# If none or both are pressed we get `0 - 0 = 1 - 1 = 0`
		# If one is pressed we get `-1` or `1`
		walk = Input.get_action_strength("right") - Input.get_action_strength("left")
	var valid_pos = position # current position is valid and our fallback
	# Just like above we get possible next positions.
	# We give highest priority to the position 3 pixels above ourselves. This is done so we can walk up slopes.
	for dir in [Vector2(walk, -3), Vector2(walk, -2), Vector2(walk, -1), Vector2(walk, 0), Vector2(walk, 1), Vector2(walk, 2), Vector2(walk, 3)]:
		var pos = position + dir
		if $"../Map".collision_normal(pos) == Vector2.ZERO:
			valid_pos = pos
	position = valid_pos
