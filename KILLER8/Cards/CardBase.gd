extends Control
signal card_in_play_signal
signal card_in_hand_signal


# This provides a place to drop in the resource file
# These resource files correspond to each card
@export var CardData: Array[CardAttributes]


#@onready var ManueverDatabase := preload("res://manipulation/Manuevers/ManueverDatabase.gd")
#Edit so card base loads up card based on ID
@onready var CardColor: Node = $ColorRect
@onready var CardTitleLabel: Node = $GridContainer/CardLayout/VBoxContainer/TopBar/Name/CardTitleLabel
@onready var CardCost: Node = $GridContainer/CardLayout/VBoxContainer/TopBar/CardCost/CardCostLabel
@onready var FlavorText: Node = $GridContainer/CardLayout/VBoxContainer/FlavorText/DescriptionContainer/FlavorTextLabel
@onready var IDText: Node = $GridContainer/CardLayout/VBoxContainer/MovementValues/IDContainer/CenterContainer/IDText

@onready var CardStackName: Node = $GridContainer/CardLayout/VBoxContainer/ManueverDescription/MarginContainer/ManeuverName
@onready var CardStackValue: Node = $GridContainer/CardLayout/VBoxContainer/ManueverDescription/DescriptionContainer/ManeuverValue
@onready var CardMovementValue: Node = $GridContainer/CardLayout/VBoxContainer/MovementValues/DescriptionContainer/CenterContainer/MovementDescription

@onready var BodyLanguageName: Node = $GridContainer/CardLayout/VBoxContainer/BodyLanguageSignal/DescriptionContainer/BodyLanguageName

@onready var CardBorder: Node = $CardBorder
@onready var CardArt: Node = $CardArt

@onready var CardHitBox: Node = $Area2D


@onready var start_pos: Vector2 = Vector2.ZERO
@onready var target_pos: Vector2 = Vector2.ZERO
@onready var time: float = 0
@onready var draw_time: float = 1
@onready var state = InHand
@onready var orig_scale = scale
@onready var old_state = INF
@export var zoom_time = 1.2
var mouse_time: float = 0.1
#var INMOUSETIME

@export var card_can_be_played: bool = false
@export var card_return_to_hand: bool = false
@export var id: String

@onready var test_movement: Vector2 = Vector2(50,50) #override this variable with the carddata xyz value
#enum the states. telling godot, when I say state1 I mean 0 and state2 = 1 {state1, state2}
enum{
	InHand, #0
	InPlay, #1
	InPlay2, #2
	InMouse, #3 
	FocusInHand, #4
	MoveDrawnCardToHand, #5
	ReOrganiseHand #6
}

var startscale = Vector2.ZERO

var card_selected: bool = false

# card variables
@export var x_movement: int
@export var y_movement: int
@export var z_movement: int
@export var freedom_order: bool = false
@export var movement_order:Array[int] #direction you have 
@export var freedom_direction: bool = false #if true, pool all your movement together and prompt player input
@export var diagonal: bool = false # if true, player can use any movement to move diag
@export var ghosting: bool = false # if true, player won't collide through walls
@export var hover: bool = false # if true, player can walk over gaps


func _input(event: InputEvent) -> void: # make it so this function only procs when over card
	match state:
		FocusInHand, InHand, InPlay:
			if event.is_action_pressed("left_click") and card_selected == true: # pick up card
				old_state = state
				state = InMouse
				#CARD_SELECT = false
	match state:
		InMouse:
			if event.is_action_released("left_click") and card_can_be_played: # if you release the mouse while this bool is true (bool that activates when card enters body
				#print("1")
				state = InPlay
				emit_signal("card_in_play_signal")
				emit_signal("move_token")
				
			elif event.is_action_released("left_click"):
				#print("2")
				state = ReOrganiseHand
				emit_signal("card_in_play_signal") # connected to the _make_card_unsortable in playspace. removes it from the deck
			
	match state:
		InMouse:
			if event.is_action_pressed("right_click") and card_selected == true:
				state = ReOrganiseHand
				
				#state = # add state so that if the card is hovering over area, it goes back to hand

#fix: mouse only grabs cards that the mouse has entered - kinda 
#fix: drawing card doesn't reset the cards. Remove played card from the hand array!
func _ready() -> void:
	
	pass
	#print(state)
	
func _physics_process(delta: float) -> void:
	#print(state)
	match state: # fix and understand the statemachine # splie into state machine nodes?
		InHand:
			scale = orig_scale
			pass
#			print(state)
		InPlay:
			scale = orig_scale
			CardHitBox.monitorable = false # turns off hitbox so playspace stops glittering
		InPlay2:
			scale = orig_scale	
			
		InMouse: # fix so the mouse grabs the card at the current mouse spot, instead of jumping to its center
			scale = orig_scale
			if time <= 1:
				position = start_pos.lerp(get_global_mouse_position() - size/2,time)
				time += delta/mouse_time
#				print(state)
			else:
				position = get_global_mouse_position() - size/2
#				print(state)
		FocusInHand:
			scale = orig_scale*zoom_time
		MoveDrawnCardToHand: #animate from deck to the player hand
			if time <= 1:
				position = start_pos.lerp(target_pos,time)
				time += delta/draw_time
#				print(state)
			else:
				position = target_pos
				state = InHand
				time = 0 # possible error location
#				print(state)
		ReOrganiseHand:
			position = target_pos
			scale = orig_scale
			state = InHand
#			print(state)

func populate_card(index) -> String:
	#card text, costs
	CardTitleLabel.text = CardData[index].title
	CardCost.text = str(CardData[index].Cost)
	FlavorText.text = str(CardData[index].CardDesc)
	id = CardData[index].id
	IDText.text = str(id)

	
	#card movements
	CardMovementValue.text =  "X" + str(CardData[index].Movement[0]) \
	+ " " + "Y" + str(CardData[index].Movement[1]) \
	+ " " + "Z" + str(CardData[index].Movement[2])
	if CardData[index].FreedomDirection == true: #pool all movement together and disperse as you like
		freedom_direction = true
		CardColor.color = Color("DARK_RED")
		#direction you have 
	if CardData[index].FreedomDirection == false:	
		movement_order = CardData[index].MovementOrder # basic card
		
	if CardData[index].Diagonal == true: # can choose to swap 1 movement for diagonal
		diagonal = false # if true, player can use any movement to move diag
		# add signal for diagonal movement
	if CardData[index].Ghost == true: # can move through obstacles
		ghosting = true
		# add signal for ghosting
	if CardData[index].Hover == true: # can move over gaps
		hover = false 
		# add signal for hovering
	
	#body language checks
	if CardData[index].BodyLanguage.is_empty():
		#print("card does not have body language")
		pass
	else:
		BodyLanguageName.text = CardData[index].BodyLanguage
		#activate the information of the bodylanguage on the card. maybe symbol? text?
	
	
	if CardData[index].StackTitle.size() == 1: # if statement to determine how many manuevers to populate card with
		CardStackName.text = CardData[index].StackTitle[0]
		CardStackValue.text = str(CardData[index].StackValue[0])
	elif CardData[index].StackTitle.size() == 2: # if there are 2 different stack types on the card
		#print("Card has 2 different stack types")
		pass
	else:
		#print("card has 0 or >3 stack types")
		pass
		
	#returns the CardData's ID
	
	
	
	return str(id)

func send_movement(id) -> Vector3i:
	var index = search_card_from_input(id)
	var x_movement = CardData[index].Movement[0]
	var y_movement = CardData[index].Movement[1]
	var z_movement = CardData[index].Movement[2]
	
	return Vector3i(x_movement,y_movement,z_movement)
		
func search_card_from_input(ID: String):
	var index: int = 0
	for card in CardData:
		if card.id == ID:
			return index
		else:
			index += 1
	# want this function to return that card's index to fill in the template.
#	for card in testcardarray:
#		if card.id == "GL":
#			print("GL CARD FOUND")
#		if card.id == "GP":
#			print("GP CARD FOUND")

# State machine for cards
# card can be in hand
# card be moving from deck to hand
# card can be in play



# make signal for mouse entering - hover over card


func _on_focus_mouse_entered() -> void:
	match state:
		InHand:
			#target_pos = Vector2()
			card_selected = true
			top_level = true
			state = FocusInHand
			#makes the card clickable

#	match state:
#		InPlay:
#			card_selected = true
#			#state = FocusInHand


func _on_focus_mouse_exited() -> void:
	match state:
		InHand, InPlay:
			card_selected = false #makes the card unclickable
			#print("false")
	match state:
		FocusInHand:
			card_selected = false
			top_level = false
			state = InHand





