extends Node
signal move_token
signal free_movement
signal basic_movement
signal prompt
signal ghost

signal card_played

var freedom_of_movement = false
var CardsInPlay: Array = []

func _on_child_entered_tree(node: Node) -> void: #whenever a card enters this node, connect its signal
	#get card ID
	# call card data from resoruce using ID
	_add_card_to_deck(node)

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
		












## old code for PlayerToken Node
#	if node.freedom_order == true: # if node has freedom_order var
#		# send message to the token
#		emit_signal("prompt")
#		print("which movement direction should move first?")
#		freedom_of_movement = true
#		emit_signal("move_token",card_movement,freedom_of_movement)
#
#	elif node.freedom_direction == true:
#		emit_signal("free_movement",card_movement)
#
#
#	else: # both conditions are true or false, if both true card will prent error, if both false do this
#		var movement_order_array: Array = node.movement_order
#		emit_signal("basic_movement",card_movement,movement_order_array)
#
#
#	if node.ghosting == true:
#		emit_signal("ghost")
#
func _add_card_to_deck(node) -> void:
	CardsInPlay.append(node.id)
