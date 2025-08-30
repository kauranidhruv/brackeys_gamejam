class_name Player
extends CharacterBody2D

#region Player Variables
@warning_ignore("unused_signal")
signal transition 
#nodes
@export var Player_Animation: AnimatedSprite2D
@export var Collider:CollisionShape2D

#physics variables
@export var RUNSPEED:int = 150
@export var ACCELARATION:int = 30
@export var DECELARATION:int = 25
@export var GRAVITY:int = 300
@export var JUMPVELOCITY:int = -200
@export var MAXJUMPS:int = 2


var movespeed:int = RUNSPEED
var jumpspeed:int = JUMPVELOCITY
var movedirectionX = 0
var jumps: int = 0
var facing: int

#input variables
var keyup:bool = false
var keydown:bool = false
var keyright:bool = false
var keyleft:bool = false
var keyjump:bool = false
var keyjumppressed:bool = false




#endregion
#region main loop functions


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
#endregion

#region custom functions
func GetInputStates():
	keyup = Input.is_action_pressed("up")
	keydown = Input.is_action_pressed("down")
	keyright = Input.is_action_pressed("right")
	keyleft = Input.is_action_pressed("left")
	keyjump = Input.is_action_pressed("jump")
	keyjumppressed = Input.is_action_just_pressed("jump")
	
	if (keyright): facing = 1
	if (keyleft): facing = -1

func HorizontalMovement(accelaration:float = ACCELARATION,decelaration:float = DECELARATION):
	movedirectionX = Input.get_axis("left","right")
	if (movedirectionX != 0):
		velocity.x = move_toward(velocity.x, movedirectionX * movespeed, accelaration)
		transition.emit("Run")
	else:
		velocity.x = move_toward(velocity.x, movedirectionX * movespeed, accelaration)
		transition.emit("Idle")

func HandleFlipH():
	Player_Animation.flip_h = (facing < 0)
	
func HandleFalling():
	if (!is_on_floor()):
		transition.emit("Fall")

func HandleLanding():
	if(is_on_floor()):
		jumps = 0
		transition.emit("Idle")

func HandleGravity(delta, Gravity: float = GRAVITY):
	if (!is_on_floor()):
		velocity.y += Gravity * delta
	

func HandleJump():
	if ((keyjumppressed) and (jumps < MAXJUMPS)):
		velocity.y = JUMPVELOCITY
		jumps += 1

func HandleAnimation():
	if (is_on_floor()):
		if (velocity.x != 0):
			Player_Animation.play("Run")
		else:
			Player_Animation.play("Idle")

	else:
		if (velocity.y < 0): 
			Player_Animation.play("Jump")
		else:
			Player_Animation.play("Fall")
			
#endregion
