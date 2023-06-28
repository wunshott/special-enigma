extends Node2D
signal HandChange
signal ShuffleDiscard

@onready var Cards: Node = $Cards
@onready var DeckDrawButton: Node = $Deck/DeckDraw
@onready var PlayerDeck: Node = $Deck
@onready var PlayerHandNode: Node = $PlayerHand
@onready var PlayArea: Node = $PlayAreaTop
@onready var Player: Node = $PlayerToken
@onready var ViewportContainer: Node = $SubViewportContainer
@onready var FocusCardWindow: Node = $SubViewportContainer/SubViewport
@onready var ViewportCamera: Node = $SubViewportContainer/SubViewport/Camera2D
@onready var beam = load("res://assets/Textures/I-Beam.png")


#const PlayerDeck = preload("res://Deck.gd")
const CardBase = preload("res://Cards/CardBase2.tscn")

var hand_ratio = []

enum{ # card states
	InHand,
	InPlay,
	InPlay2,
	InMouse,
	FousInHand,
	MoveDrawnCardToHand,
	ReOrganiseHand
}


func _ready() -> void:
	randomize()
#	CURSOR_CROSS 
	Input.set_custom_mouse_cursor(beam,Input.CURSOR_CROSS)
	
	#print("The player's deck is currently " +  str(PlayerDeck.Deck))
	#print("The player's hand is currently " + str(PlayerHandNode.Hand))
	
	var progressbar_group: Array[Node] = get_tree().get_nodes_in_group("ResourceBars")
	var progressbar_1 = progressbar_group[0]
	progressbar_1.connect("resourcebarA_filled",_progressbarA_filled)
	
	self.connect("ShuffleDiscard",Cards._reshuffle_discard_in_play)
#	self.connect("ShuffleDiscard",PlayerDeck._reshuffle_discard_deck)
	Cards.connect("cards_to_be_shuffled",PlayerDeck._reshuffle_deck)
	PlayerDeck.connect("_reshuffle_discard_into_deck",draw_from_deck)

	
	#PlayArea.CardCanPlay.connect(_is_card_playable)
	#print(PlayerHandNode.Hand)
	#PlayerHandNode._displayhand(PlayerHandNode.Hand)
func draw_from_deck() -> void:
	if PlayerDeck.Temp_deck.size() > 0:
		var new_card = CardBase.instantiate()
		PlayerHandNode.card_location.add_child(new_card)
		var random_card_index: int = randi() % PlayerDeck.Temp_deck.size()
		var card_ID: String = PlayerDeck.Temp_deck[random_card_index]
		var card_index: int = new_card.search_card_from_input(card_ID)
		new_card.populate_card(card_index)
		PlayerDeck.Temp_deck.erase(card_ID)
		new_card.state = MoveDrawnCardToHand
		new_card.state = InHand
		PlayerHandNode._reorganize_hand()
		
	elif PlayerDeck.Temp_deck.size() == 0:
		ShuffleDiscard.emit()
		print("no more cards")


func draw() -> void: #This function should only transfer info from deck array to hand array
	
	
	if PlayerDeck.Deck.size() > 0:
		
		var new_card = CardBase.instantiate()
		PlayerHandNode.add_child(new_card)
		
		
#		new_card.state = MoveDrawnCardToHand
	

		#var card_ID = new_card.populate_card(randi() % CardPoolSize) # update this line as you add more cards
		#1. pick random number from deck
		#2. feed ID from deck into the card template to populate card
		#3. remove that card from the deck
		#4. add that card into the player hand
		
		var random_card_index: int = randi() % PlayerDeck.Deck.size() # generates number to use as index to pull card from deck
		var card_ID: String = PlayerDeck.Deck[random_card_index] # uses that index to access the element in the array. That is the card ID to search
		var card_index: int = new_card.search_card_from_input(card_ID) # calls the function in the new_card to search for this card's index based on the ID
		new_card.populate_card(card_index) #populate the card based on index
		PlayerHandNode.Hand.append(card_ID) #adds the card ID to the playerhand array
		PlayerDeck.Deck.erase(card_ID) #removes card ID from the deck array
		
		var tween = get_tree().create_tween()
		tween.tween_property(new_card, "global_position", Vector2(180,320), 1.0).set_trans(Tween.TRANS_SINE)
		new_card.state = MoveDrawnCardToHand
		await tween.finished
		new_card.state = InHand
#		new_card._move_card_to_hand()
		# revamp and control position
		
		#var card_ID = new_card.populate_card(randi() % CardPoolSize)
	
			#print("The player's deck is currently " +  str(PlayerDeck.Deck)) 
		
		# you may need to queue free on new_card
		#new_card.queue_free()
		
		
	if PlayerDeck.Deck.size() == 0:
		DeckDrawButton.disabled = true
		#print("The player currently has " + str(PlayerHandNode.Hand)) #returns player hand as an array of the card IDs
		#print("The player's deck is currently " +  str(PlayerDeck.Deck))

	HandChange.emit()

func _process(delta: float) -> void:
	pass

			#print("signal worked 1")

# draw cards and place them on the curve
# called with draw function
# click on deck
# search deck for card
# populates the card with info
# 
# place card function. input = amount of cards to draw
# appends the player hand with that card
# adjusts the hand ratio with new card
# adjusts the hand ratio of all the cards
# places latest card at the end of the hand

func _progressbarA_filled(cardid) -> void:
#	print(cardid)
#	draw2(cardid)
	draw_from_deck()

func _on_deck_draw_pressed() -> void:
	draw()
	#draw2("GL")
	#print("the hand after drawing is " + str(PlayerHandNode.Hand))
	for node in PlayerHandNode.get_children():
		if node.is_connected("card_in_play_signal",_make_card_unsortable) != true and node is Card:
			node.card_in_play_signal.connect(_make_card_unsortable)
		
		#connect signal with deck draw, so each card gets connected on press?



# function to transfer nodes from hand to deck
# function to transfer nodes from deck to hand
# general node transfer function?



func _make_card_unsortable() -> void: # removes the just played card from the playerhand node and assigns to card node.
	
	for card in PlayerHandNode.get_children():
		if card.state == InPlay2:
			#print(card.CardTitleLabel.text)
			card.reparent(Cards) 
			var temp_card_id = card.id
			var temp_index = PlayerHandNode.Hand.find(temp_card_id)
			PlayerHandNode.Hand.remove_at(temp_index)
			HandChange.emit()
			print(PlayerHandNode.Hand)
			#Cards.CardsInPlay.append(temp_card_id)
			#print(temp_index)
			#print("Hand after playing card is " + str(PlayerHandNode.Hand))
			
		


func _on_play_area_top_card_can_play() -> void: #while card is in Inplay2 state, it can't be picked up again. 
	#print("area detected by playarea")
	for node in PlayerHandNode.get_children():
		if node as Card:
			node.card_can_be_played = true
# go to card and flip a switch
# only happens after node switches to Cards. So you have to trigger the switch to card node BEFORE this

func _on_play_area_top_card_cannot_play() -> void:
	#print("area exited by card")
	for node in PlayerHandNode.get_children():
		if node as Card:
			node.card_can_be_played = false


func _on_token_token_death() -> void:
	for card_ID in PlayerHandNode.Hand: # adds cards back into the deck
		PlayerDeck.Deck.append(card_ID)
	for card_ID in Cards.CardsInPlay:
		PlayerDeck.Deck.append(card_ID)
	PlayerHandNode.Hand.clear() # delete all elements from playerHand
	Cards.CardsInPlay.clear() # delete all elements from cardsinplay
	for node in PlayerHandNode.get_children():
		node.queue_free() # delete the cards in play
	for node in Cards.get_children():
		node.queue_free() # delete the cards in play
	print("the deck is " + str(PlayerDeck.Deck))
	print("the hand is " + str(PlayerHandNode.Hand) + ". should be empty")
	print("the cards in play are " + str(Cards.CardsInPlay) + ". should be empty")



func draw2(card_id) -> void:
	var new_card = CardBase.instantiate()
	PlayerHandNode.card_location.add_child(new_card)
	var card_index: int = new_card.search_card_from_input(card_id)
	new_card.populate_card(card_index)
#	PlayerHandNode.Hand.append(card_id)
	new_card.position = Vector2(400,400)
	new_card.state = InHand
	PlayerHandNode._reorganize_hand()



func _on_template_dialogue_card_draw_2(meta) -> void:  #when the meta tag is clicked, draw a card
	draw2(meta)
	PlayerHandNode._reorganize_hand()




func _on_player_hand_card_is_played(card: Card) -> void:
	card.reparent(Cards)




func _on_player_hand_card_is_focused(card: Card, hover_state: bool) -> void: # adds card to viewport or deletes it from viewport
	if hover_state == true:
		focus_on_card(card)
	else:
		unfocus_on_card(card)
	
	

	
func focus_on_card(card: Card) -> void: # creates dupe of current card and displays it inside the viewport
	ViewportContainer.show()
	var focused_view = card.duplicate(DUPLICATE_USE_INSTANTIATION)
	FocusCardWindow.add_child(focused_view)
	ViewportCamera.position = focused_view.global_position + Vector2(250.5/2,350.5/2)

func unfocus_on_card(card: Card) -> void: # hides viewport and deletes its chidlren if they're a card
	ViewportContainer.hide()
	for node in FocusCardWindow.get_children():
		if node is Card:
			node.queue_free()


func _on_button_pressed() -> void: # Test Button
#	get_tree().call_group("ResourceBars","_group_test")
	pass
