extends Node2D
signal CardCanPlay
signal CardCannotPlay

@onready var PlayArea: Node = $PlayArea
@onready var PlayAreaHitbox: Node = $PlayArea/PlayAreaHitox
@onready var ParticleFX: Node = $GPUParticles2D
var rest_point
var card_size = Vector2(250,350)


func _ready() -> void:
	pass # Replace with function body.
	rest_point = self.global_position - card_size/2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
		


func _on_play_area_area_entered(area: Area2D) -> void: #whenever a card enters the area
	emit_signal("CardCanPlay")
	area.resting_place = rest_point
	ParticleFX.emitting = true
	#connect this signal to the main function
	#if node recieves this signal, activate a boolean in main functiion
	#if that boolean is true and mouse just released, card is inplay
		#inplay2 state that won't allow it to be dragged
	area.selected = true
	select()


func _on_play_area_area_exited(area: Area2D) -> void: #whenever a card exits the area
	emit_signal("CardCannotPlay")
	ParticleFX.emitting = false
	area.selected = false
	deselect()


func _on_play_area_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _draw():
	draw_circle(Vector2.ZERO,100,Color.BLANCHED_ALMOND)

func select():
	modulate = Color.WEB_MAROON
	
func deselect():
	modulate = Color.BLANCHED_ALMOND
