extends CharacterBody2D
class_name Enemy

# ⚙️ CONFIGURACIONES EXPORTADAS DESDE EL EDITOR
@export_category("⚙️ Config")

@export_group("Options")
#@export var score = 100           # Puntos al morir
@export var score = randf_range(80, 100)           # Puntos al morir
@export var health = 20           # Vida

@export_group("Motion")
@export var salto = 168           # No usado (podés eliminar si no lo usás)
@export var gravity = 10          # Gravedad
@export var jump_strength = 500   # Fuerza del salto hacia arriba

# ⚙️ VARIABLES INTERNAS
var death : bool = false
var jump_timer = 1.0              # Tiempo hasta el próximo salto

# Se ejecuta al iniciar la escena
func _ready():
	jump_timer = randf_range(1.0, 3.0)

# Se ejecuta cada frame de física
func _physics_process(delta):
	if death:
		death_ctrl()
		return

	# Aplicar gravedad
	velocity.y += gravity

	# Contador de salto aleatorio
	jump_timer -= delta
	if jump_timer <= 0:
		jump()
		jump_timer = randf_range(1.0, 3.0)
	# Mover al enemigo
	move_and_slide()

# Función de salto
func jump():
	velocity.y = -jump_strength
	$Sprite.play("Jump")
	# Podés agregar animación o sonido aquí

# Movimiento en estado de muerte
func death_ctrl():
	velocity.x = 0
	velocity.y += gravity
	move_and_slide()

# Lógica de daño recibido
func damage_ctrl(damage : int):
	health -= damage
	if health <= 0 and not death:
		death = true
		$Sprite.play("Death")
		$Collision.set_deferred("disabled", true)
		gravity = 0
		GLOBAL.score += score
		print("Puntaje Obtenido: ", score)
		die()
# randf_range(1.0, 3.0) score
func take_damage(damage: int):
	print("Salud restante Slime: ", health - damage)
	damage_ctrl(damage)

#func take_damage(damage: int):
#	health -= damage
#	print("Salud restante Slime: ", health)
#	if health <= 0:
#		die()  # Llama a un método para manejar la muerte

signal hit(value)

var damage : int

func die():
	queue_free()  # Elimina el nodo del juego

# Detección de colisión con el jugador
func _on_hit_point_body_entered(body: Node2D):
	if body is Player and velocity.y >= 0:
		#$Audio/Hit.play()
		body.take_damage(10)
		emit_signal("hit", damage)

# Se llama cuando termina la animación de muerte
func _on_sprite_animation_finished():
	if $Sprite.animation == "Death":
		queue_free()
