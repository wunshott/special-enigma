extends Node2D

signal card_drawn(current_deck_position:Vector2)#signal to pass deck position to the playerhand node

var Deck: Array = ["OP","GP","BP","CYT","GL"] # Represent the cards in the deck

func _ready() -> void:
	emit_signal("card_drawn",self.position)
	pass
	

