extends CharacterBody2D

# --- EXPORTED VARIABLES ---
@export var roam_speed: float = 50.0 # Adjusted speed for platformer movement
@export var chase_speed: float = 100.0 # Adjusted speed for platformer movement
@export var health: int = 10
@export var damage: int = 3


# --- NODE REFERENCES ---
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $attack_hitbox
@onready var roaming_timer: Timer = $RoamingTimer
@onready var player_detection_ray: RayCast2D = $RayCast2D # Replaces DetectionArea for player sight


# --- STATE MACHINE ---
enum State { ROAM, CHASE, ATTACK, DEATH ,HURT}
var current_state: State = State.ROAM
var player: CharacterBody2D = null # Store reference to the detected player

# --- INTERNAL VARIABLES ---
var roam_direction: Vector2 = Vector2.LEFT # Enemy will roam horizontally (starts left)
var can_attack: bool = true
var is_acting: bool = false # Action lock to prevent interruption
signal died(points)

const GRAVITY: float = 900.0 # Gravity constant for platformer physics (adjust as needed)


func _ready() -> void:
	_choose_new_roam_direction()
	# Initialize raycast target positions (can also be set in the editor)
	# PlayerDetectionRay: Longer horizontal ray to detect the player.
	player_detection_ray.target_position = Vector2(-150, 0) # X length, Y 0 for horizontal


func _physics_process(delta: float) -> void:
	# --- 0. Apply Gravity ---
	
	if Input.is_action_just_pressed("test1"):
		take_damage(1)
	
	
	
	
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0 # Reset vertical velocity when on the floor

	# --- Update RayCasts directions based on sprite flip ---
	# Ensure rays point in the direction the enemy is facing.
	if animated_sprite.flip_h: # Now means facing RIGHT
		player_detection_ray.target_position.x = abs(player_detection_ray.target_position.x)
	else: # Now means facing LEFT
		player_detection_ray.target_position.x = -abs(player_detection_ray.target_position.x)
	player_detection_ray.force_raycast_update()


	# --- 1. STATE DETERMINATION ---
	# Only change state if we are not locked in an action (e.g., mid-attack, death animation).
	if not is_acting and current_state != State.DEATH:
		var player_detected_by_ray = false
		var detected_collider = player_detection_ray.get_collider()
		
		# Check if the player detection raycast hits the 'Player'
		if player_detection_ray.is_colliding() and detected_collider != null and detected_collider.name == "Player":
			player = detected_collider as CharacterBody2D
			player_detected_by_ray = true
			roaming_timer.stop() # Stop roaming timer if player is detected
		else:
			# If raycast doesn't detect the player, and the player reference was based on raycast, clear it.
			# This also handles cases where player moves out of raycast range.
			if is_instance_valid(player) and not attack_area.overlaps_body(player):
				player = null
				
		# State transitions based on player presence and range
		if is_instance_valid(player):
			if attack_area.overlaps_body(player):
				current_state = State.ATTACK
			elif player_detected_by_ray:
				current_state = State.CHASE
			else: # Player valid but not in attack_area or player_detection_ray range anymore
				current_state = State.ROAM
				_choose_new_roam_direction() # Re-initiate roaming
		else: # No player reference or player became invalid
			current_state = State.ROAM
			if roaming_timer.is_stopped(): # Ensure roaming timer is active if no player is found
				_choose_new_roam_direction()


	# --- 2. STATE ACTION ---
	match current_state:
		State.ROAM:
			animated_sprite.play("walk") # Play walking animation for roaming
			velocity.x = roam_direction.x * roam_speed
			
		State.CHASE:
			animated_sprite.play("walk")
			if is_instance_valid(player):
				# Calculate horizontal direction to player
				var direction_to_player_x = (player.global_position.x - global_position.x)
				# Move horizontally towards the player, with a small threshold to prevent jittering
				if abs(direction_to_player_x) > 5:
					velocity.x = sign(direction_to_player_x) * chase_speed
				else:
					velocity.x = 0 # Stop if very close horizontally
			else:
				current_state = State.ROAM # Fallback if player becomes invalid during chase
				_choose_new_roam_direction()
				
		State.ATTACK:
			velocity.x = 0 # Stop horizontal movement during attack
			if can_attack:
				_perform_attack()
				
		State.DEATH:
			velocity.x = 0 # Stop all movement when dead

	# Flip the sprite horizontally to match movement direction
	if velocity.x != 0:
		animated_sprite.flip_h = velocity.x > 0
	
	move_and_slide() # Apply movement and collision detection


# --- ATTACK AND DAMAGE FUNCTIONS ---

func hurt():
	health




func _perform_attack():
	if not can_attack: return

	is_acting = true
	can_attack = false
	
	animated_sprite.play("attack")
	
	var bodies_in_area = attack_area.get_overlapping_bodies()
	for body in bodies_in_area:
		if body == player and body.has_method("take_damage"): # Ensure it's the player and has the method
			body.take_damage(damage)
			break
			
	await animated_sprite.animation_finished
	await get_tree().create_timer(0.5).timeout # Cooldown before next attack
	can_attack = true
	is_acting = false

func take_damage(amount: int):
	if current_state == State.DEATH: return
	health -= amount
	animated_sprite.play("hurt")
	print("Enemy took ", amount, " damage. Health is now ", health)
	if health <= 0:
		_die()

func _die():
	is_acting = true # Lock state machine during death
	current_state = State.DEATH
	
	# Disable collisions and detection elements
	player_detection_ray.enabled = false # Disable player detection raycast
	attack_area.monitoring = false # Stop monitoring for attack targets
	
	died.emit(3) # Emit signal death score
	animated_sprite.play("death")
	await animated_sprite.animation_finished
	queue_free() # Remove the enemy from the scene


# --- ROAMING FUNCTIONS ---

func _choose_new_roam_direction():
	# For a platformer, roam purely horizontally
	if randf() < 0.5:
		roam_direction = Vector2.LEFT
	else:
		roam_direction = Vector2.RIGHT
	roaming_timer.start()


func _on_roaming_timer_timeout():
	# If still in ROAM state, choose a new direction after timer expires
	if current_state == State.ROAM:
		_choose_new_roam_direction()



# Removed the old _on_detection_area_body_entered/exited functions as they are replaced by raycast logic.
# Removed the old _on_attack_area_body_entered/exited for TileMapLayer and the `hitwall` variable,
# as `wall_check_ray` now handles wall detection for roaming direction changes.
