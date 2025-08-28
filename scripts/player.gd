class_name Player
extends CharacterBody2D

#region Player Variables

#nodes
@export var Player_Animation: AnimatedSprite2D
@export var Collider:CollisionShape2D

#physics variables
@export var RUNSPEED:int = 150
@export var ACCELARATION:int = 30
@export var DECELARATION:int = 25
@export var GRAVITY:int = 300
@export var JUMPVELOCITY:int = -200
@export var MAXJUMPS:int = 1

var movespeed:int = RUNSPEED
var jumpspeed:int = JUMPVELOCITY
var movedirectionX:int = 0
var jumps: int = 0
var facing = 1

#input variables
var keyup:bool = false
var keydown:bool = false
var keyright:bool = false
var keyleft:bool = false
var keyjump:bool = false
var keyjumppressed:bool = false




#endregion



func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	# GetInputStates
	GetInputStates()
	
	# Handle movements
	HandleGravity(delta)
	HorizontalMovement(ACCELARATION, DECELARATION)
	HandleJump() 

	# commit movement
	move_and_slide()
	
	# aniamtions
	HandleAnimation()

func GetInputStates():
	keyup = Input.is_action_pressed("up")
	keydown = Input.is_action_pressed("down")
	keyright = Input.is_action_pressed("right")
	keyleft = Input.is_action_pressed("left")
	keyjump = Input.is_action_pressed("jump")
	keyjumppressed = Input.is_action_just_pressed("jump")
	
	if (keyright): facing = 1
	if (keyleft): facing = -1

func HorizontalMovement(accelaration:float,decelaration:float):
	movedirectionX = Input.get_axis("left","right")
	velocity.x = move_toward(velocity.x, movedirectionX * movespeed, accelaration)

func HandleGravity(delta):
	if (!is_on_floor()):
		velocity.y += GRAVITY * delta
	else:
		jumps = 0

func HandleJump():
	if (keyjumppressed):
		if (jumps < MAXJUMPS):
			velocity.y = JUMPVELOCITY
			jumps += 1

func HandleAnimation():
	Player_Animation.flip_h = (facing < 0)
	
	if (is_on_floor()):
		if (velocity.x != 0):
			Player_Animation.play("Run")
		else:
			Player_Animation.play("Idle")

	else:
		if (facing > 0): 
			Player_Animation.play("Jump")
		else:
			Player_Animation.play("Jump")
			
