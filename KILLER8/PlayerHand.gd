extends Node2D


## test


const DeckDatabase = preload("res://Cards/CardBase.tscn")

## Array that represents the current hand. Each element is a string that corresponds to the card ID.
## You should ensure to call the right functions to convert from string to carddatabaseresourcearray
@onready var Hand: Array[String] = []
@onready var destination = Vector2(50,0)
@onready var destination_origin = Vector2(180,350)


@export var spread_curve: Curve
@export var height_curve: Curve
@export var rotation_curve: Curve


@export var max_width: float #Need to make an algorthm that changes hand width based on hand size with limits
@export var max_height: float #same as above
@export var rotation_magnitude: float # same as above
var deck_position: Vector2 = Vector2(50,50)

enum{ # card states
	InHand,
	InPlay,
	InMouse,
	FousInHand,
	MoveDrawnCardToHand,
	ReOrganiseHand
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_displayhand(Hand)



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
		
		if get_child_count() > 1:
			hand_ratio = float(card.get_index())/float(self.get_child_count()-1)
		var destination = destination_origin
		destination.x += spread_curve.sample(hand_ratio) * max_width
		destination.y -=  height_curve.sample(hand_ratio) * max_height
		card.start_pos = deck_position
		card.target_pos.x = destination.x
		card.target_pos.y = destination.y

		card.position.x = destination.x
		card.position.y = destination.y
		card.rotation = rotation_curve.sample(hand_ratio) * rotation_magnitude
#		print(deck_position)
		
#		print(card.start_pos)
#		print(Deck.position)
		
		
		#var card_index: int = new_card.search_card_from_input(Hand[card.get_index()])
		var card_index: int = card.search_card_from_input(Hand[card.get_index()])
		card.populate_card(card_index)
		#print(destination)


func _on_playspace_hand_change() -> void:
	_displayhand(Hand)

func _remove_card_from_hand(hand_index) -> void:
	Hand.remove_at(hand_index) # removes card from hand array
	
	# verify this works^
#	var card_to_be_removed = get_children()
#	card_to_be_removed[hand_index].reparent(cards_in_play)
	# ^ works and moves card from hand to cards_in_play
	
#	get_parent().remove_child(self)
#	cards_in_play.add_child(self)

	
	#if card has InPlay state, do the following:
		#make new var that stores the card from the Hand array using index as input
		#that element gets removed from the playerhand array
		#that child gets reparented to the cards_in_play node, thus removing it that child gets removed from the PlayerHand parent node
		#make new array that tracks cards_in_play
		#add that element to this new cards_in_play array
		#once removed, it should not have its state reassigned once drawing a card
	

func _on_deck_card_drawn(current_deck_position) -> void:
	#print(" this is the deck position before overridng " + str(deck_position))
	deck_position = current_deck_position
	#print(" the signal passed value is " + str(current_deck_position))
	#print(" the current deck position is " + str(deck_position))



func _on_child_exiting_tree(node: Node) -> void:
	#remove card from array when the node exits - no, can't control it well
	pass

	


func _on_child_entered_tree(node: Node) -> void:
	#append the matrix when a card exits
	pass
	#node.state = InHand
	#node.card_in_play_signal.connect(_custom_signal_test_func)
	#should add the card to the hand array
	#change the draw function?


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
	



