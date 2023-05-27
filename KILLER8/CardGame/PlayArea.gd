extends Node2D
signal CardCanPlay
signal CardCannotPlay

@onready var PlayArea: Node = $PlayArea
@onready var PlayAreaHitbox: Node = $PlayArea/PlayAreaHitox
@onready var ParticleFX: Node = $GPUParticles2D


func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_area_area_entered(area: Area2D) -> void: #whenever a card enters the area
	emit_signal("CardCanPlay")
	ParticleFX.emitting = true
	#connect this signal to the main function
	#if node recieves this signal, activate a boolean in main functiion
	#if that boolean is true and mouse just released, card is inplay
		#inplay2 state that won't allow it to be dragged
	#first test with printing 


func _on_play_area_area_exited(area: Area2D) -> void: #whenever a card exits the area
	emit_signal("CardCannotPlay")
	ParticleFX.emitting = false


func _on_play_area_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
