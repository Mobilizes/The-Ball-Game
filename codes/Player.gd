extends KinematicBody2D

signal health_changed(new_health)
signal stamina_change(stamina_change)

export var speed : int = 50
export var jumpmultiplier : Vector2 = Vector2(27, 50)
export var speedlimit : int = 5
export var gravity : float = 4000.0
export var health = 100
export var stamina = 100
export var stamina_regen = 0.4
export var health_def = 0
export var voidshard = 0

var friction = speedlimit
var velocity : Vector2 = Vector2()
var boostpower : bool = true
var boostspeed = 4
var interact : bool = false
var jump_interrupt
var checkpoint = Vector2(226, 365)

onready var sprite : Sprite = get_node("Sprite")

func _ready():
	add_to_group("Player")

# warning-ignore:unused_argument
func _physics_process(delta):
	jump_interrupt = Input.is_action_just_released("jump") and velocity.y < 0.0
	var direction = get_direction()
	velocity = calculate_move_velocity(velocity, direction, speed, jump_interrupt, jumpmultiplier.y)
	
	velocity.x = min(velocity.x, speedlimit * speed)
	velocity.x = max(velocity.x, -speedlimit * speed)
	
	move()
	stamina_change(-stamina_regen)
	
	if velocity.x > 0:
		velocity.x -= friction
	if velocity.x < 0:
		velocity.x += friction
	
	sprite.rotation_degrees += velocity.x / 10
	if self.position.y >= 574:
		take_damage(20)
		self.position = checkpoint
	
	if self.position.y <= -2700:
		get_tree().change_scene("res://scenes/sky.tscn")
	
	velocity = move_and_slide(velocity, Vector2.UP)
	
	if voidshard >= 6:
		win()

func move():
	if Input.is_action_pressed("move_right"):
		velocity.x += speed
	if Input.is_action_pressed("move_left"):
		velocity.x -= speed
	if Input.is_action_pressed("boost") and boostpower:
		speedlimit = 5 + boostspeed
		stamina_change(1)
	if Input.is_action_pressed("slow_down"):
		speedlimit = 1
	if Input.is_action_just_released("boost") or Input.is_action_just_released("slow_down"):
		speedlimit = 5
	if Input.is_action_pressed("lock"):
		velocity.x = 0 

func get_direction() -> Vector2:
	return Vector2(
		Input.get_action_strength("move_right") - 
		Input.get_action_strength("move_left"),
		-1.0 if Input.is_action_just_pressed("jump") and is_on_floor() else 1.0
	)

func calculate_move_velocity(
		linear_velocity: Vector2,
		direction: Vector2,
		speed: int,
		jump_interrupt: bool,
		height_multiplier: int
	) -> Vector2:
	var new_velocity: = linear_velocity
	new_velocity.y += gravity * get_physics_process_delta_time()
	if direction.y == -1.0:
		if height_multiplier == 50:
			$Jump.play()
		new_velocity.y = jumpmultiplier.y * jumpmultiplier.x * direction.y
	if jump_interrupt:
		new_velocity.y = 0
	return new_velocity

func take_damage(amount):
	health -= amount - health_def
	if amount > 0:
		$TakeDamage.play()
	if amount < 0:
		health -= health_def
	if health <= 0:
		get_tree().change_scene("res://scenes/youlose.tscn")
	health = min(health, 100)
	
	emit_signal("health_changed", health)

func stamina_change(amount):
	stamina -= amount
	stamina = max(0, stamina)
	stamina = min(stamina, 100)
	
	if stamina == 0:
		boostpower = false
		speedlimit = 5
	else:
		boostpower = true
	
	emit_signal("stamina_change", stamina)

func voidshard_collect():
	voidshard += 1
	match voidshard:
		1:
			jumpmultiplier.x = 30
		2:
			speed = 55
		3:
			speedlimit = 7
		4:
			stamina_regen = 0.5
		5:
			health_def = 5
		6:
			pass
	
	Input.action_release("move_left")
	Input.action_release("move_right")
	take_damage(-20)
	return voidshard

func teleport():
	var destination : Vector2
	if get_tree().current_scene.name == "sky":
		get_tree().change_scene("res://scenes/world.tscn")
	else:
		destination = Vector2(5172, -1320)
	return destination

func bounce():
	jumpmultiplier.y = 100
	velocity = calculate_move_velocity(velocity, Vector2(Input.get_action_strength("move_right") - Input.get_action_strength("move_left"), -1.0), speed, false, jumpmultiplier.y)
	jumpmultiplier.y = 50

func hurt(var enemypos):
	velocity = calculate_move_velocity(velocity, Vector2(Input.get_action_strength("move_right") - Input.get_action_strength("move_left"), -1.0), speed, false, 25)
	velocity.y = velocity.y / 2
	take_damage(25)
	
	if position.x < enemypos.x:
		velocity.x = -800
	if position.x > enemypos.x:
		velocity.x = 800
	
	Input.action_release("move_left")
	Input.action_release("move_right")

func win():
	get_tree().change_scene("res://scenes/credits.tscn")
