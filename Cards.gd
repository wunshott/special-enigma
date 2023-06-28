extends Node
signal move_token
signal free_movement
signal basic_movement
signal prompt
signal ghost

signal cards_to_be_shuffled
signal card_played

var freedom_of_movement = false
var CardsInPlay: Array = []
var cards_to_be_shuffled_array: Array[String] = []

	

func _on_child_entered_tree(node: Node) -> void: #whenever a card enters this node, connect its signal
	#get card ID
	# call card data from resoruce using ID
	_add_card_to_in_play(node)

	var movement_vector: Vector3i = node.send_movement(node.id)

	var x_movement: int = movement_vector.x
	var y_movement: int = movement_vector.y #need to track the negtive sign from y
	var z_movement: int = movement_vector.z #not used yet

	var card_movement:Vector2i = Vector2i(x_movement,y_movement)
	var movement_order_array: Array = node.movement_order
	var freedom_of_direction: bool = node.freedom_direction

#		Input:Vector2, movement_order: Array, freedom_direction:bool
	emit_signal("card_played", card_movement, movement_order_array, freedom_of_direction)
		#sebds al the cards information to the player token
		


#
func _add_card_to_in_play(node) -> void: # useless now but keeps a running array of all cards in play. main function does this better
	CardsInPlay.append(node.id)

# delete call cards in the discard
func _reshuffle_discard_in_play() -> void:
	if get_child_count() != 0:
		for child in self.get_children():
			if child as Card:
				var index = 0
				cards_to_be_shuffled_array.append(str(child.id))
				index += 1
				child.queue_free()
	
	
		cards_to_be_shuffled.emit(cards_to_be_shuffled_array)
		cards_to_be_shuffled_array.clear()
	
	elif get_child_count() == 0:
		print("there are no cards to reshuffle!")
