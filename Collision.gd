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
	var normal := Vector2.ZERO
	for direction in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
		# Check the 4 pixels directly adjecent.
		var observed_pixel = pos + direction
		if (observed_pixel.x < 0		  # Left edge
			or observed_pixel.x >= WIDTH  # Right edge
			or observed_pixel.y < 0		  # Top edge
			or observed_pixel.y >= HEIGHT # Bottom edge
			or collision[observed_pixel.x][observed_pixel.y]): # Solid terrain
			normal += direction * -1 # Point the normal the opposite way
	return normal.normalized() # Normalize the normal

# Create a circle-shaped hole at the position
func explosion(pos: Vector2, radius: int) -> void:
	for x in range(-radius, radius + 1):
		for y in range(-radius, radius + 1):
			# We're looping over a square
			if Vector2(x, y).length() > radius:
				# Filter out when we're too far from the center
				continue
			var pixel = pos + Vector2(x,y) # Move the circle to `pos`
			if pixel.x < 0 or pixel.x >= WIDTH:
				continue # Not on the map
			if pixel.y < 0 or pixel.y >= HEIGHT:
				continue # Not on the map
			collision[pixel.x][pixel.y] = false # Set the pixel to air
