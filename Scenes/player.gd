class_name Player
extends CharacterBody2D

#region Player Variables


#nodes
@export var Player_Animation: AnimatedSprite2D
@export var Collider:CollisionShape2D
@onready var States: Node = $StateMachine
@onready var Camera: Camera2D = $Camera2D
@onready var JumpBufferTimer: Timer = $Timers/JumpBuffer
@onready var CoyoteTimer: Timer = $Timers/CoyoteTimer
@onready var JumpCooldownTimer: Timer = $Timers/JumpCooldownTimer


#physics variables
@export var RUNSPEED:int = 150	
@export var ACCELARATION:int = 40
@export var DECELARATION:int = 50
@export var GRAVITYJUMP:int = 600
@export var GRAVITYFALL: int = 500
@export var JUMPVELOCITY:int = -500
@export var MAXJUMPS:int = 1
@export var VARIABLEJUMPMULTIPLIER:float = 2
@export var JUMPBUFFERTIME:float = 0.1
@export var COYOTETIME:float = 0.1
@export var JUMPAIR:float = 0.8
@export var MAXFALLVELOCITY:float = 350
@export var JUMPCOOLDOWN:float = 0.1

var movespeed:int = RUNSPEED
var jumpspeed:int = JUMPVELOCITY
var movedirectionX = 0
var jumps: int = 0
var facing: int
var coyotestart: float = false

#input variables
var keyup:bool = false
var keydown:bool = false
var keyright:bool = false
var keyleft:bool = false
var keyjump:bool = false
var keyjumppressed:bool = false

#StateMachine variables
var currentState = null
var previousState = null


#endregion


#region main loop functions


func _ready() -> void:
	for state in States.get_children():
		state.States = States
		state.player = self
	previousState = States.Fall
	currentState = States.Fall

func _draw() -> void:
	currentState.Draw()

func ChangeState(newState):
	if (newState != null and newState != currentState or newState != previousState ):
		previousState = currentState
		currentState = newState
		previousState.ExitState()
		currentState.EnterState()
		print("State Change From: ", previousState.Name, "To: ", currentState.Name)
		return


	
func _physics_process(delta: float) -> void:
	# GetInputStates
	GetInputStates()
	
	# Update Current state
	currentState.Update(delta)
	
	# Handle movements
	var space:float = 60
	HandleGravity(delta)
	HandleMaxFallVelocity()
	HorizontalMovement(ACCELARATION, DECELARATION)
	HandleJump()
	if CoyoteTimer.time_left>0:
		print(CoyoteTimer.time_left)
	
	# commit movement
	move_and_slide()
	
	

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

func is_movement():
	if keydown or keyright or keyup or keyleft:
		return true

func HorizontalMovement(accelaration:float = ACCELARATION,decelaration:float = DECELARATION):
	movedirectionX = Input.get_axis("left","right")
	if (movedirectionX != 0):
		velocity.x = move_toward(velocity.x, movedirectionX * movespeed, accelaration)
		if currentState != States.Run and currentState!= States.Jump:
			ChangeState(States.Run)
	else:
		velocity.x = move_toward(velocity.x, movedirectionX * movespeed, accelaration)
		if currentState != States.Idle and velocity.x == 0 and velocity.y == 0 and currentState != States.Jump: #and currentState != States.Jump and currentState != States.Fall:
			ChangeState(States.Idle)

func HandleFlipH():
	Player_Animation.flip_h = (facing < 0)
	
	
func HandleFalling():
	if (!is_on_floor()):
		if currentState != States.Fall and currentState != States.Idle and currentState!= States.Run:
			ChangeState(States.Fall)
		if (jumps == 0 and velocity.y > 0 and JumpCooldownTimer.time_left <= 0 and (currentState in [States.Fall,States.Run] and previousState not in [States.Jump, States.Run])): 
			if coyotestart:
				CoyoteTimer.start(COYOTETIME)
			coyotestart = false
			
func HandleMaxFallVelocity():
	if (velocity.y > MAXFALLVELOCITY): velocity.y = MAXFALLVELOCITY

func HandleJumpBuffer():
	if (keyjumppressed):
		JumpBufferTimer.start(JUMPBUFFERTIME)

func HandleLanding():
	if(is_on_floor()):
		if (currentState != States.Idle and velocity == Vector2.ZERO):
			ChangeState(States.Idle)
		coyotestart = true
		jumps = 0
		CoyoteTimer.stop()

func HandleGravity(delta, Gravity: float = GRAVITYJUMP): #GravityAir: float = JUMPAIR+(JUMPAIR*0.5)
	if (!is_on_floor()):
		velocity.y += Gravity * delta  # * GravityAir
	
#func HandleReset() -> void:
	#if (is_on_floor()):
		#JumpBufferTimer.stop()
		#jumps = 0
		
		
	
func HandleJump():
	#if ((keyjumppressed) and (jumps <  MAXJUMPS)):
		#if !is_on_floor():
			#if (JumpBufferTimer.time_left > 0 and is_on_floor()):
				#ChangeState(States.Jump)
		#jumps += 1
		#ChangeState(States.Jump)
	if (is_on_floor()):
		if (jumps < MAXJUMPS and currentState != States.Jump):
			if (keyjumppressed or  JumpBufferTimer.time_left > 0):
				JumpBufferTimer.stop()
				jumps += 1
				ChangeState(States.Jump)
			#if JumpBufferTimer.time_left > 0:
				#jumps += 1
				#JumpBufferTimer.stop()
				#ChangeState(States.Jump)
	else:
		if ((jumps<MAXJUMPS) and (jumps > 0) and (keyjumppressed)):
			jumps += 1
			ChangeState(States.Jump)
			
		if ((CoyoteTimer.time_left > 0) and (keyjumppressed) and (jumps < MAXJUMPS) and velocity.y > 0):
			CoyoteTimer.stop()
			jumps += 1
			ChangeState(States.Jump)
		
			
			
#endregion
 
