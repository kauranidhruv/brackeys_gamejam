extends PlayerState

func EnterState():
	Name = "Idle"

func ExitState():
	pass

func Draw():
	pass

func Update(delta:float):
	player.HandleFalling()
	player.HorizontalMovement()
	if ((player.movedirectionX != 0) and player.currentState != States.Run and player.is_movement() and player.is_on_floor()):
		player.ChangeState(States.Run)
	player.HandleJump()
	player.HandleLanding()
	HandleAnimations()

func HandleAnimations():
	player.Player_Animation.play("Idle")
	player.HandleFlipH()
