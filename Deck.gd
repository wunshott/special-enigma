extends Node2D

signal _reshuffle_discard_into_deck
signal card_drawn(current_deck_position:Vector2)#signal to pass deck position to the playerhand node

var Deck: Array[String] = ["GL"] # Represent the cards in the deck
var Temp_deck: Array = Deck

func _ready() -> void:
	emit_signal("card_drawn",self.position)
	pass




func _reshuffle_deck(cards_to_shuffle: Array[String]) -> void:
	for card in cards_to_shuffle:
		Temp_deck.append(card)
	_reshuffle_discard_into_deck.emit()
