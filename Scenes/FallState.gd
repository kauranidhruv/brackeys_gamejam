extends PlayerState

func EnterState():
	Name= "Fall"

func ExitState():
	pass

func Draw():
	pass

func Update(delta: float):
	player.HandleGravity(delta, player.GRAVITYFALL)
	player.HandleFalling()
	player.HandleJump()
	player.HandleJumpBuffer()
	HandleAnimations()
	player.HandleLanding()
	
func HandleAnimations():
	player.Player_Animation.play("Fall")
	player.HandleFlipH()
