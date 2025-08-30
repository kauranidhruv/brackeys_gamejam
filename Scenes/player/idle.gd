extends NodeState

@export var player: Player
@export var animation: AnimatedSprite2D

func _on_process(_delta : float) -> void:
	pass


func _on_physics_process(_delta : float) -> void:
	player.HandleFalling()
	player.HandleJump()
	player.HorizontalMovement()
	player.GetInputStates()
	
	
	

func _on_exit() -> void:
	if (player.movedirectionX != 0):
		transition.emit("Run")
		animation.stop()
	if ((!player.is_on_floor()) and player.velocity.y < 0):
		transition.emit("Jump")
		animation.stop()
	if ((!player.is_on_floor()) and player.velocity.y > 0):
		transition.emit("Fall")
		animation.stop()
	

func _on_enter() -> void:
	animation.play("Idle")
	player.HandleFlipH()




	
