extends Node

for bit in 8:
			if bit == 0:
				bm.set_bit((iByte*8 + bit) % 64, (iByte*8 + bit) / 64, Byte&1 != 0)
			elif bit == 1:
				bm.set_bit((iByte*8 + bit) % 64, (iByte*8 + bit) / 64, Byte&2 != 0)
			elif bit == 2:
				bm.set_bit((iByte*8 + bit) % 64, (iByte*8 + bit) / 64, Byte&4 != 0)
			elif bit == 3:
				bm.set_bit((iByte*8 + bit) % 64, (iByte*8 + bit) / 64, Byte&8 != 0)
			elif bit == 4:
				bm.set_bit((iByte*8 + bit) % 64, (iByte*8 + bit) / 64, Byte&16 != 0)
			elif bit == 5:
				bm.set_bit((iByte*8 + bit) % 64, (iByte*8 + bit) / 64, Byte&32 != 0)
			elif bit == 6:
				bm.set_bit((iByte*8 + bit) % 64, (iByte*8 + bit) / 64, Byte&64 != 0)
			elif bit == 7:
				bm.set_bit((iByte*8 + bit) % 64, (iByte*8 + bit) / 64, Byte&128 != 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
