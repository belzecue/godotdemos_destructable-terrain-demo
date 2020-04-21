"""
Implements the collision functionality of the map.
"""
extends Node


# This should not be hardcoded, but it works here
const WIDTH := 1024  # Width of the map
const HEIGHT := 600  # Height of the map

# We keep track of the collision shape of the map with a 2D Array.
# The elements are boolean with `true = solid` and `false = air`
var collision := []

# Initialize the collision Array (with the noise line generated in $Map)
func init_map(line: Array) -> void:
	for x in range(WIDTH):
		# Every line is a column
		collision.append([])
		for y in range(HEIGHT):
			if line[x] > y:
				# if we are above the line (lower y), then we set this pixel to air (false)
				collision[x].append(false)
			else:
				# else we are below the line (higher y). Then we set this pixel to solid (true)
				collision[x].append(true)

# Returns the surface normal for a position
func collision_normal(pos: Vector2) -> Vector2:
	# This implementation is incomplete and will be finished in an upcoming commit
	if pos.x <= 0:
		# Left edge of the map; Normal points right
		return Vector2.RIGHT
	if pos.x >= WIDTH:
		# Right edge of the map; Normal points left
		return Vector2.LEFT
	if pos.y <= 0:
		# Top edge of the map; Normal points down
		return Vector2.DOWN
	if pos.y >= HEIGHT:
		# Bottom edge of the map; Normal points up
		return Vector2.UP
	if collision[pos.x][pos.y]:
		# Solid pixel, return random non-zero Vector
		return Vector2.ONE
	# Air pixel, return no normal.
	return Vector2.ZERO
