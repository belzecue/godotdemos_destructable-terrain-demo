"""
This Script manages the map/terrain.
"""
extends Node2D

onready var fg = $FG

const TRANSPARENT := Color(0,0,0,0)

#  Save the initial ground height
var line := []

func _ready() -> void:
	randomize()		# Generate a new random seed
	_generate_map() # Generate a "map"
	$Collision.init_map(line) # Initialize the "map" for collision

# Returns the surface normal for a position
func collision_normal(pos: Vector2) -> Vector2:
	return $Collision.collision_normal(pos) # $Collision implements this

# Generates a random map
func _generate_map() -> void:
	# Get the texture data and lock it (to allow editing)
	var fg_data = fg.texture.get_data()
	fg_data.lock()
	# Generate some Noise for the height map
	var noise = OpenSimplexNoise.new()
	noise.seed = randi()
	noise.octaves = 2
	noise.period = 180.0
	noise.persistence = 0.8
	for x in range(fg_data.get_width()): # loop over the whole x-Axis
		# Get the height for this x position
		# Since the noise is between -1 and 1 we add 1 to not get negative numbers
		# We then multiply by 40% of the map height such that the height can cover 80% of the screen
		# Finally we add 8% of the map height to kinda center the terrain
		var high = ((noise.get_noise_1d(x) + 1) * fg_data.get_height() * 0.4) + fg_data.get_height() * 0.08
		line.append(high)
		for y in range(high):
			# All pixels between 0 and `high` get set to TRANSPARENT
			fg_data.set_pixelv(Vector2(x,y), TRANSPARENT)
	fg_data.unlock() # Unlock the data since we're done with editing it
	fg.texture.set_data(fg_data) # Set the new data as the texture
