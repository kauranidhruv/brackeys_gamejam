extends PlayerState
func EnterState():
	Name = "JumpPeak"

func ExitState():
	pass

func Draw():
	pass

func Update(delta: float):
	player.ChangeState(States.Fall)
	HandleAnimations()


func HandleAnimations():
	player.Player_Animation.play("Jump")
