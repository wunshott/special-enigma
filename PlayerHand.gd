extends Node2D


## test


const CardBase = preload("res://Cards/CardBase2.tscn")
signal card_is_played
signal card_is_focused

## Array that represents the current hand. Each element is a string that corresponds to the card ID.
## You should ensure to call the right functions to convert from string to carddatabaseresourcearray
@onready var Hand: Array[String] = ["OP","OP","GL","GL"]
@onready var destination = Vector2(50,0)
@onready var destination_origin = Vector2(180,350)
@onready var state
@onready var card_location = $Cards
@onready var HandAreaCollisionShape = $HandExpandArea/CollisionShape2D

@export var spread_curve: Curve
@export var height_curve: Curve
@export var rotation_curve: Curve

	
@export	var card_x_gap: float = 70
@export var max_width: float #Need to make an algorthm that changes hand width based on hand size with limits
@export var max_height: float #same as above
@export var rotation_magnitude: float # same as above
var deck_position: Vector2 = Vector2(50,50)
var card_width: int = 250
var card_height: int = 350
var card_height_placement: int = 350*2.5

enum{
	InHand, #0
	InPlay, #1
	InPlay2, #2
	InMouse, #3 
	FocusInHand, #4
	MoveDrawnCardToHand, #5
	ReOrganiseHand, #6
	PushedAside #7
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
#	_displayhand(Hand)
	_displayhand2(Hand)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass



#this script controls the player hand
#this script controls how the hand is displayed in-game

func _displayhand(CardIDs) -> void:
	#This function will update the hand placement to match the player hand array
	
	if CardIDs.is_empty() == true: # will quit out of the displayhand if there are no cards to display
		return
		
	if CardIDs.is_empty() == false: # intialize cards in hand. maybe don't need this?
		pass

	#var new_card = DeckDatabase.instantiate()
	#self.add_child(new_card)
	
	#populate card
	#new_card.state = MoveDrawnCardToHand # change this to reorganise hand?. This state should be drawing the card
	for card in self.get_children(): #reorganise hand\
#		card.state = MoveDrawnCardToHand
		var hand_ratio = 0.5 # if there is only 1 card
		card.state = InHand
		
		if get_child_count() > 1:
			hand_ratio = float(card.get_index())/float(self.get_child_count()-1)
		var destination = destination_origin
		destination.x += spread_curve.sample(hand_ratio) * max_width
		destination.y -=  height_curve.sample(hand_ratio) * max_height
		card.start_pos = deck_position
		card.target_pos.x = destination.x
		card.target_pos.y = destination.y

#		card.position.x = destination.x
#		card.position.y = destination.y
		#card.rotation = rotation_curve.sample(hand_ratio) * rotation_magnitude
		
		var tween = get_tree().create_tween()
		tween.tween_property(card, "position", card.target_pos, 0.1).set_trans(Tween.TRANS_SINE)
		await tween.finished

		card.test_index = get_card_index(card)
		print("why is this working")
		
		#var card_index: int = new_card.search_card_from_input(Hand[card.get_index()])
#		var card_index: int = card.search_card_from_input(Hand[card.get_index()])
#		card.populate_card(card_index)


func _displayhand2(CardIDs) -> void: # this function moves all cards from the hand array and spawns them as nodes

	
	for id in CardIDs:
		var new_card = CardBase.instantiate()
		card_location.add_child(new_card)
		var cardindex = new_card.search_card_from_input(id)
		new_card.populate_card(cardindex)
	
	
	var destination: Vector2 = Vector2.ZERO # sets the position of the left most card
	var screen_size = get_viewport().get_visible_rect().size
	destination.x = (screen_size.x - get_all_cards().size()*card_width - card_x_gap)/2
	destination.y = card_height_placement
	print(destination.y)
	for card in card_location.get_children():
		
		if card is Card:
			
			card.test_index = get_card_index(card)
			card.target_pos = destination
			destination.x += 250 + card_x_gap/2
			card.state = MoveDrawnCardToHand
			var tween = get_tree().create_tween()
			tween.tween_property(card, "position", card.target_pos, .5).set_trans(Tween.TRANS_EXPO)
			await tween.finished
			card.state = InHand
			
			#move signal connections to the node entered function once hand is cleaned up?
			card.connect("card_in_play_signal",_move_card_to_play) #connects signal for when card is played
			card.connect("card_hovered",_move_card_to_viewport) #connects signal for when card is zoomed in on

		
func _reorganize_hand() -> void: #this function will move all cards back together after one is played
	var destination: Vector2 = Vector2.ZERO # sets the position of the left most card
	var screen_size = get_viewport().get_visible_rect().size
	destination.x = (screen_size.x - get_all_cards().size()*card_width - card_x_gap)/2
	destination.y = card_height_placement
	
	for card in card_location.get_children():
		if card is Card:
			card.test_index = get_card_index(card)
			card.target_pos = destination
			destination.x += 250 + card_x_gap/2
			card.state = MoveDrawnCardToHand
			var tween = get_tree().create_tween()
			tween.tween_property(card, "position", card.target_pos, .1).set_trans(Tween.TRANS_QUAD)
			await tween.finished
			card.state = InHand
			#move signal connections to the node entered function once hand is cleaned up?
			card.connect("card_in_play_signal",_move_card_to_play) #connects signal for when card is played
			card.connect("card_hovered",_move_card_to_viewport) #connects signal for when card is zoomed in on


func _on_playspace_hand_change() -> void:
	_displayhand(Hand)

func _remove_card_from_hand(hand_index) -> void:
	Hand.remove_at(hand_index) # removes card from hand array
	

func _move_card_to_play(card: Card) -> void: #emits signal that a card was played so it can be reparented. Also reorganizes the hand
	emit_signal("card_is_played",card)
	_reorganize_hand()
	

func _move_card_to_viewport(card: Card, hover_state: bool) -> void:
	emit_signal("card_is_focused",card,hover_state)

	
	#if card has InPlay state, do the following:
		#make new var that stores the card from the Hand array using index as input
		#that element gets removed from the playerhand array
		#that child gets reparented to the cards_in_play node, thus removing it that child gets removed from the PlayerHand parent node
		#make new array that tracks cards_in_play
		#add that element to this new cards_in_play array
		#once removed, it should not have its state reassigned once drawing a card
	

func _on_deck_card_drawn(current_deck_position) -> void:
	deck_position = current_deck_position
	


#func move_card_to_in_play(card) -> void:
#	pass
#	card.card_in_play_signal.connect(move_card_to_in_play,card)
#	card should emit signal to some kind of node when played that tells it to reparent it to the card node

func _on_child_exiting_tree(node: Node) -> void:
	pass
	
func _on_child_entered_tree(node: Node, card_id: String) -> void: # won't work cause card_id is null. how to feed this info
	if node as Card:
		return
#		var card_index: int = node.search_card_from_input(card_id)
#		node.populate_card(card_index)


#func _custom_signal_test_func() -> void: # move this function to the playspace
#	pass
#	for card in self.get_children():
#		var index = 0
#		if card.state == InPlay:
#			card.reparent(cards_in_play)
#			#var temp_card_id = Hand[index]
#			#Hand.remove_at(index)
#			#print("test")
#			#cards_in_play.CardsInPlay.append(temp_card_id)
#		index += 1

func get_all_cards() -> Array:
	var hand_node_array:= []
	for obj in card_location.get_children():
		if obj as Card: hand_node_array.append(obj)
	return(hand_node_array)

func get_card_index(card: Card) -> int: #already have a card array
	return(get_all_cards().find(card))

func get_card_count() -> int:
	return(get_all_cards().size())
	
func get_card(idx: int) -> Card:
	return(get_all_cards()[idx])


func _on_hand_expand_area_mouse_entered() -> void:
	#raise entire node position
	var card_raise: Vector2 = Vector2(0,-200)
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(card_location, "position", card_raise, .01).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(HandAreaCollisionShape, "scale", Vector2(1,2.25), .1).set_trans(Tween.TRANS_EXPO)
	#	for card in get_all_cards():
#		if card as Card and card.state == InHand: # send signal to cardbase script and make card raise if you hover over box instead of this?
#			var hover_position: int = card.target_pos.y + -225
#			card.target_pos.y = hover_position
#			var tween = get_tree().create_tween()
#			tween.tween_property(card, "position", card.target_pos, .5).set_trans(Tween.TRANS_EXPO)

func _on_hand_expand_area_mouse_exited() -> void:
	var card_raise: Vector2 = Vector2(0,0)
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(card_location, "position", card_raise, .01).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(HandAreaCollisionShape, "scale", Vector2(1,1), .1).set_trans(Tween.TRANS_EXPO)
#	for card in get_all_cards():
#		if card as Card and card.state == InHand:
#			if card as Card:
#				var hover_position: int = get_all_cards().size()*card_height/1.4
#				card.target_pos.y = hover_position
#				var tween = get_tree().create_tween()
#				tween.tween_property(card, "position", card.target_pos, .5).set_trans(Tween.TRANS_EXPO)




