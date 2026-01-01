extends PlayerState

func EnterState():
	Name = "Jump"
	player.velocity.y = player.jumpspeed * player.JUMPAIR
	

func ExitState():
	pass

func Draw():
	pass

func Update(delta: float):
	player.HandleGravity(delta)
	player.HorizontalMovement()
	player.HandleFalling()
	HandleJumpToFall()
	HandleAnimations()

func HandleJumpToFall() -> void:
	if (player.velocity.y >= 0):
		player.ChangeState(States.Fall)
	if (!player.keyjump) or (player.currentState == States.Run):
		player.velocity.y *= player.VARIABLEJUMPMULTIPLIER
		player.JumpCooldownTimer.Start(player.JUMPCOOLDOWN)
		if player.jumps == player.MAXJUMPS:
			player.coyotestart = false
		player.ChangeState(States.Fall)
	
		
func HandleAnimations():
	player.Player_Animation.play("Jump")
	player.HandleFlipH()
