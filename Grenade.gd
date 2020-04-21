"""
The grenade implements physics movement and goes boom after the timer runs out.
"""
extends Node2D

const GRAVITY = 0.1	# Some random guess

var _dir: Vector2	# The direction we're currently headed

func init(dir: Vector2) -> void:	# Sets the initial direction
	# normalize and multiply by a new length (either `2` or 1% of the length)
	_dir = dir.normalized() * max(2, dir.length() * 0.01)

func _process(_delta: float) -> void:
	# Every frame we update the label with the time left (rounded, since it's a float)
	$Label.text = str(ceil($Timer.time_left))

func _physics_process(_delta) -> void:
	if $Timer.time_left <= 0:
		# We're exploding. Don't move.
		return
	# Apply gravity
	# `max(_, 1)` to avoid devision by `0`
	_dir.y += GRAVITY / max(_dir.length(), 1)
	# Do the actual movement
	# This could get coupled to the frame rate if you
	# calculate the number of steps allowed this frame based on `delta`
	do_steps()

# See which movement is valid
func do_steps() -> void:
	# `velocity` is the steps we (try to) move this frame
	var velocity = _dir
	while abs(velocity.y) > 0: # Let's start by doing all the movement on the y-Axis
		# Either move 1 pixel or the rest we want on the y-Axis (if it's < 1.0)
		var new_position = position + (Vector2.DOWN * sign(velocity.y) * min(abs(velocity.y), 1.0))
		var normal = $"../Map".collision_normal(new_position)      # Get the normal of the new position
		velocity.y -= min(1.0, abs(velocity.y)) * sign(velocity.y) # Update `velocity` to the remaining steps
		if normal == Vector2.ONE:
			# We are inside a wall; Don't move more
			break
		if sign(normal.y) != 0 and sign(_dir.y) != sign(normal.y):
			# We bounce on the y-Axis
			_dir.y *= -0.5   # Use `-0.5` instead of `-1` to simulate friction
			velocity.y *= -0.5
		if sign(normal.x) != 0 and sign(_dir.x) != sign(normal.x):
			# We bounce on the x-Axis
			_dir.x *= -0.8
			velocity.x *= -0.8
		position = new_position
	# Movement on the x-Axis is the same as on the y-Axis above
	while abs(velocity.x) > 0:
		var new_position = position + (Vector2.RIGHT * sign(velocity.x) * min(abs(velocity.x), 1.0))
		var normal = $"../Map".collision_normal(new_position)
		velocity.x -= min(1.0, abs(velocity.x)) * sign(velocity.x)
		if normal == Vector2.ONE:
			break
		if sign(normal.y) != 0 and sign(_dir.y) != sign(normal.y):
			_dir.y *= -0.5
			velocity.y *= -0.5
		if sign(normal.x) != 0 and sign(_dir.x) != sign(normal.x):
			_dir.x *= -0.8
			velocity.x *= -0.8
		position = new_position

# Explode!
func _on_Timer_timeout() -> void:
	# Tell the map to make a hole
	$"../Map".explosion(position, 30)
	# Hide ourselves
	$Label.visible = false
	$Sprite.visible = false
	# Show the explosioin animation
	$Explosion.visible = true
	$Explosion.play("default")

# Exploded.
func _on_Explosion_animation_finished() -> void:
	# Remove this grenade
	queue_free()
