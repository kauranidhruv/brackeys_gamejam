extends NodeState

@export var player: Player
@export var animation: AnimatedSprite2D

func _on_process(_delta : float) -> void:
	pass


func _on_physics_process(_delta : float) -> void:
	player.GetInputStates()
	player.HandleFlipH()
	player.HandleFalling()
	player.HandleJump()
	player.HorizontalMovement()
	
func _on_next_transitions() -> void:
	if (player.movedirectionX != 0):
		transition.emit("Run")
	if ((!player.is_on_floor()) and player.velocity.y < 0):
		transition.emit("Jump")
	if ((!player.is_on_floor()) and player.velocity.y > 0):
		transition.emit("Fall")
	

func _on_enter() -> void:
	player.HandleFlipH()
	animation.play("Run")
	

func _on_exit() -> void:
	animation.stop()


	
