extends Node2D

# RAM 4Kb [4096]  <<<<<<<<<<<<<<<
var RAM = PackedByteArray()
var ROM = PackedByteArray()

# Registers & Stack       <<<<<<<<<<<<<<<
var V = PackedByteArray() # 16 8-bit Registers V0 to VF
var I = 0   # Address Register [16-bit]
var DT = 0  # Delay Timer Register  [8-bit]
var ST = 0  # Sound Timer Register  [8-bit]

var PC = 0x200 # [16-bit] Program Counter, programs start at 0x200
var SP = 0 # [8-bit] Stack Pointer
var Stack = PackedByteArray() # 16 [16-bit] Values to store the address that the interpreter shoud return to when finished with a subroutine.

var opcode = 0
var op
var x
var y
var n
var addr
var nn

var KeyEvent = -1

# Display Data >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
var displayImage = Image.new()
var displayImageTexture = ImageTexture.new()
var bm = BitMap.new()
var im = Image.new()
var imt = ImageTexture.new()

func renderToScreen():
	im = bm.convert_to_image()
	im.resize($Screen.texture.get_width(), $Screen.texture.get_height(), Image.INTERPOLATE_NEAREST)
	imt = imt.create_from_image(im)
	
	$Screen.texture = imt
	pass

func init_RAM_And_Registers():
	RAM.resize(4096)
	RAM.fill(0)
	
	V.resize(12)
	V.fill(0)
	
	Stack.resize(32)
	Stack.fill(0)
	
	# Font Data <<<<<<<<<<<<<<<<<
	RAM.encode_u8(0x10, 0xF0)
	RAM.encode_u8(0x11, 0x90)
	RAM.encode_u8(0x12, 0x90)
	RAM.encode_u8(0x13, 0x90)
	RAM.encode_u8(0x14, 0xF0)
	
	RAM.encode_u8(0x15, 0x20)
	RAM.encode_u8(0x16, 0x60)
	RAM.encode_u8(0x17, 0x20)
	RAM.encode_u8(0x18, 0x20)
	RAM.encode_u8(0x19, 0x70)
	
	RAM.encode_u8(0x1A, 0xF0)
	RAM.encode_u8(0x1B, 0x10)
	RAM.encode_u8(0x1C, 0xF0)
	RAM.encode_u8(0x1D, 0x80)
	RAM.encode_u8(0x1E, 0xF0)
	
	RAM.encode_u8(0x1F, 0xF0)
	RAM.encode_u8(0x20, 0x10)
	RAM.encode_u8(0x21, 0xF0)
	RAM.encode_u8(0x22, 0x10)
	RAM.encode_u8(0x23, 0xF0)
	
	RAM.encode_u8(0x24, 0x90)
	RAM.encode_u8(0x25, 0x90)
	RAM.encode_u8(0x26, 0xF0)
	RAM.encode_u8(0x27, 0x10)
	RAM.encode_u8(0x28, 0x10)
	
	RAM.encode_u8(0x29, 0xF0)
	RAM.encode_u8(0x2A, 0x80)
	RAM.encode_u8(0x2B, 0xF0)
	RAM.encode_u8(0x2C, 0x10)
	RAM.encode_u8(0x2D, 0xF0)
	
	RAM.encode_u8(0x2E, 0xF0)
	RAM.encode_u8(0x2F, 0x80)
	RAM.encode_u8(0x30, 0xF0)
	RAM.encode_u8(0x31, 0x90)
	RAM.encode_u8(0x32, 0xF0)
	
	RAM.encode_u8(0x33, 0xF0)
	RAM.encode_u8(0x34, 0x10)
	RAM.encode_u8(0x35, 0x20)
	RAM.encode_u8(0x36, 0x40)
	RAM.encode_u8(0x37, 0x40)
	
	RAM.encode_u8(0x38, 0xF0)
	RAM.encode_u8(0x39, 0x90)
	RAM.encode_u8(0x3A, 0xF0)
	RAM.encode_u8(0x3B, 0x90)
	RAM.encode_u8(0x3C, 0xF0)
	
	RAM.encode_u8(0x3D, 0xF0)
	RAM.encode_u8(0x3E, 0x90)
	RAM.encode_u8(0x3F, 0xF0)
	RAM.encode_u8(0x40, 0x10)
	RAM.encode_u8(0x41, 0xF0)
	
	RAM.encode_u8(0x42, 0xF0)
	RAM.encode_u8(0x43, 0x90)
	RAM.encode_u8(0x44, 0xF0)
	RAM.encode_u8(0x45, 0x90)
	RAM.encode_u8(0x46, 0x90)
	
	RAM.encode_u8(0x47, 0xE0)
	RAM.encode_u8(0x48, 0x90)
	RAM.encode_u8(0x49, 0xE0)
	RAM.encode_u8(0x4A, 0x90)
	RAM.encode_u8(0x4B, 0xE0)
	
	RAM.encode_u8(0x4C, 0xF0)
	RAM.encode_u8(0x4D, 0x80)
	RAM.encode_u8(0x4E, 0x80)
	RAM.encode_u8(0x4F, 0x80)
	RAM.encode_u8(0x50, 0xF0)
	
	RAM.encode_u8(0x51, 0xE0)
	RAM.encode_u8(0x52, 0x90)
	RAM.encode_u8(0x53, 0x90)
	RAM.encode_u8(0x54, 0x90)
	RAM.encode_u8(0x55, 0xE0)
	
	RAM.encode_u8(0x56, 0xF0)
	RAM.encode_u8(0x57, 0x80)
	RAM.encode_u8(0x58, 0xF0)
	RAM.encode_u8(0x59, 0x80)
	RAM.encode_u8(0x5A, 0xF0)
	
	RAM.encode_u8(0x5B, 0xF0)
	RAM.encode_u8(0x5C, 0x80)
	RAM.encode_u8(0x5D, 0xF0)
	RAM.encode_u8(0x5E, 0x80)
	RAM.encode_u8(0x5F, 0x80)
	
	pass

func initDisplay():
	bm.create(Vector2i(64,32))
	
	#for x in 64:
	#	for y in 32:
	#		bm.set_bit(x,y, x%4 != 0 && y%3 != 0)
	
	#cmd_00E0()
	pass

func loadProgram():
	#var file = FileAccess.open("user://save_game.dat", FileAccess.WRITE)
	ROM = FileAccess.get_file_as_bytes("res://ROMS/Zero Demo [zeroZshadow, 2007].ch8")
	for i in ROM.size():
		RAM.encode_u8(0x200 + i, ROM.decode_u8(i))
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	# Initialize 
	init_RAM_And_Registers()
	initDisplay()
	loadProgram()
	
	renderToScreen()
	pass # Replace with function body.

func Fetch():
	opcode = (RAM.decode_u8(PC) << 8) | (RAM.decode_u8(PC+1))
	PC += 2
	
	# Decode
	op = opcode >> 12
	x = (opcode & 0xF00) >> 8 
	y = (opcode & 0xF0) >> 4
	n = (opcode & 0xF)
	addr = (x << 4) | y
	addr = (addr << 4) | n
	nn = (y << 4) | n
	
	match op:
		0x0:
			if addr == 0x0E0:
				cmd_00E0()
			elif  addr == 0x0EE:
				cmd_00EE()
			else:
				print("WARNING : call for 0NNN machine code subroutine!")
		0x1:
			cmd_1NNN()
		0x2:
			cmd_2NNN()
		0x3:
			cmd_3XNN()
		0x4:
			cmd_4XNN()
		0x5:
			cmd_5XY0()
		0x6:
			cmd_6XNN()
		0x7:
			cmd_7XNN()
		0x8:
			match n:
				0x0:
					cmd_8XY0()
				0x1:
					cmd_8XY1()
				0x2:
					cmd_8XY2()
				0x3:
					cmd_8XY3()
				0x4:
					cmd_8XY4()
				0x5:
					cmd_8XY5()
				0x6:
					cmd_8XY6()
				0x7:
					cmd_8XY7()
				0xE:
					cmd_8XYE()
		0x9:
			cmd_9XY0()
		0xA:
			cmd_ANNN()
		0xB:
			cmd_BNNN()
		0xC:
			cmd_CXNN()
		0xD:
			cmd_DXYN()
		0xE:
			pass
		0xF:
			match nn:
				0x07:
					cmd_FX07()
				0x0A:
					cmd_FX0A()
				0x15:
					cmd_FX15()
				0x18:
					cmd_FX18()
				0x1E:
					cmd_FX1E()
				0x29:
					cmd_FX29()
				0x33:
					cmd_FX33()
				0x55:
					cmd_FX55()
				0x65:
					cmd_FX65()
		
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var TicksPerFrame = 12 # ~720 instructions per second [60FPS]
	for t in TicksPerFrame:
		Fetch()
		pass
	if DT > 0: DT -= 1
	if ST > 0: ST -= 1
	pass



# Instruction Set SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS
func cmd_00E0(): # Clear the display
	bm.create(Vector2i(64,32))
	pass

func cmd_00EE(): # Return From subroutine
	PC = Stack.decode_u16(SP)
	SP -= 2
	pass

func cmd_1NNN(): # Jump to Address NNN
	PC = addr
	pass

func cmd_2NNN(): # Call Subroutine at NNN
	SP += 2
	Stack.encode_u16(SP,PC)
	PC = addr
	pass

func cmd_3XNN():
	if V.decode_u8(x) == nn:
		PC += 2
	pass

func cmd_4XNN():
	if V.decode_u8(x) != nn:
		PC += 2
	pass

func cmd_5XY0():
	if V.decode_u8(x) == V.decode_u8(y):
		PC += 2
	pass

func cmd_6XNN():
	V.encode_u8(x,nn)
	pass

func cmd_7XNN():
	var temp = V.decode_u8(x)
	V.encode_u8(x,temp + nn)
	pass

func cmd_8XY0():
	V.encode_u8(x,V.decode_u8(y))
	pass

func cmd_8XY1():
	V.encode_u8(x, V.decode_u8(x) | V.decode_u8(y))
	pass

func cmd_8XY2():
	V.encode_u8(x, V.decode_u8(x) & V.decode_u8(y))
	pass

func cmd_8XY3():
	V.encode_u8(x, V.decode_u8(x) ^ V.decode_u8(y))
	pass

func cmd_8XY4():
	if(V.decode_u8(x) + V.decode_u8(y) > 255):
		V.encode_u8(0xF, 1)
	V.encode_u8(x, V.decode_u8(x) + V.decode_u8(y))
	pass

func cmd_8XY5():
	if(V.decode_u8(x) > V.decode_u8(y)):
		V.encode_u8(0xF, 1)
	V.encode_u8(x, V.decode_u8(x) - V.decode_u8(y))
	pass

func cmd_8XY6():
	V.encode_u8(0xF, int(V.decode_u8(y) & 1 != 0))
	V.encode_u8(x, V.decode_u8(y) >> 1)
	pass

func cmd_8XY7():
	if V.decode_u8(y) > V.decode_u8(x):
		V.encode_u8(0xF, 1)
	V.encode_u8(x, V.decode_u8(y) - V.decode_u8(x))
	pass

func cmd_8XYE():
	V.encode_u8(0xF, int(V.decode_u8(y) & 128 != 0))
	V.encode_u8(x, V.decode_u8(y) << 1)
	pass

func cmd_9XY0():
	if V.decode_u8(x) != V.decode_u8(y): PC += 2
	pass

func cmd_ANNN():
	I = addr
	pass

func cmd_BNNN():
	PC = addr + V.decode_u8(0)
	pass

func cmd_CXNN():
	var rb = randi_range(0,255)
	V.encode_u8(x, rb & nn)
	pass

func cmd_EX9E(): # Key stuff, todo
	var key = V.decode_u8(x)
	if Input.is_action_pressed(str(key)):
		PC += 2
	pass

func cmd_EXA1(): # Key stuff, todo
	var key = V.decode_u8(x)
	if not Input.is_action_pressed(str(key)):
		PC += 2
	pass

func cmd_FX07():
	V.encode_u8(x, DT)
	pass

func cmd_FX0A(): # Key Stuff, Todo!
	KeyEvent = -1
	
	if Input.is_action_just_pressed("0"):
		KeyEvent = 0
	elif Input.is_action_just_pressed("1"):
		KeyEvent = 1
	elif Input.is_action_just_pressed("2"):
		KeyEvent = 2
	elif Input.is_action_just_pressed("3"):
		KeyEvent = 3
	elif Input.is_action_just_pressed("4"):
		KeyEvent = 4
	elif Input.is_action_just_pressed("5"):
		KeyEvent = 5
	elif Input.is_action_just_pressed("6"):
		KeyEvent = 6
	elif Input.is_action_just_pressed("7"):
		KeyEvent = 7
	elif Input.is_action_just_pressed("8"):
		KeyEvent = 8
	elif Input.is_action_just_pressed("9"):
		KeyEvent = 9
	elif Input.is_action_just_pressed("10"):
		KeyEvent = 0xA
	elif Input.is_action_just_pressed("11"):
		KeyEvent = 0xB
	elif Input.is_action_just_pressed("12"):
		KeyEvent = 0xC
	elif Input.is_action_just_pressed("13"):
		KeyEvent = 0xD
	elif Input.is_action_just_pressed("14"):
		KeyEvent = 0xE
	elif Input.is_action_just_pressed("15"):
		KeyEvent = 0xF

	if KeyEvent == -1:
		PC -= 2
	else:
		V.encode_u8(x, KeyEvent)
	pass

func cmd_FX15():
	DT = V.decode_u8(x)
	pass

func cmd_FX18():
	ST = V.decode_u8(x)
	pass

func cmd_FX1E():
	I += V.decode_u8(x)
	pass

func cmd_FX29():
	var F = V.decode_u8(x) & 0xF
	I = (F*5) + 0x10
	pass

func cmd_FX33():
	var bcd = V.decode_u8(x)
	RAM.encode_u8(I, int(bcd / 100))     # todo: Fix this casting accuracy when rounding
	RAM.encode_u8(I+1, (bcd / 10) % 10)
	RAM.encode_u8(I+2, (bcd % 10))
	pass

func cmd_FX55():
	for xi in x+1:
		RAM.encode_u8(I+xi, V.decode_u8(xi))
	I = I+x+1
	pass

func cmd_FX65():
	for xi in x+1:
		V.encode_u8(xi, RAM.decode_u8(I+xi))
	I = I+x+1
	pass

func cmd_DXYN():
	var xp = V.decode_u8(x)
	var yp = V.decode_u8(y)
	
	V.encode_u8(0xF, 0)
	for row in n:
		var spriteByte = RAM.decode_u8(I+row)
		for bit_index in 8:
			var bit = spriteByte & int(pow(2,7-bit_index)) != 0
			var oldBit = bm.get_bit(xp+bit_index % 64, yp+row % 32)
			var newBit = int(oldBit) ^ int(bit)
			if oldBit && newBit == 0:
				V.encode_u8(0xF, 1)
			bm.set_bit(xp+bit_index % 64, yp+row % 32, newBit)
			pass
		pass
	
	renderToScreen()
	pass
