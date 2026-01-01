extends PlayerState

func EnterState():
	Name = "Run"

func ExitState():
	player.Player_Animation.play("JumpFrame")

func Draw():
	pass

func Update(delta:float):
	player.HorizontalMovement()
	player.HandleJump()
	player.HandleFalling()
	player.HandleGravity(delta)
	player.HandleLanding()
	HandleAnimations()
	HandleIdle()
	
func HandleAnimations() -> void:
	if (player.is_on_floor()):
		player.Player_Animation.play("Run")
	elif (!player.is_on_floor()):
		if (player.velocity.y > 0):
			player.Player_Animation.play("Fall")
		else:
			player.Player_Animation.play("JumpFrame")
	player.HandleFlipH()
	
func HandleIdle()-> void:
	if player.movedirectionX == 0 and player.velocity == Vector2.ZERO and player.currentState != States.Idle and player.currentState != States.Fall :
		player.ChangeState(States.Idle)
	
