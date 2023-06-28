class_name Card
extends Area2D
signal card_in_play_signal
signal card_in_hand_signal
signal card_hovered


# This provides a place to drop in the resource file
# These resource files correspond to each card
@export var CardData: Array[CardAttributes]

#@onready var ManueverDatabase := preload("res://manipulation/Manuevers/ManueverDatabase.gd")
#Edit so card base loads up card based on ID
@onready var CardColor: Node = $ColorRect
@onready var CardTitleLabel: Node = $ColorRect/MarginContainer/VBoxContainer/HBoxContainer/CardTitle
@onready var CardCost: Node = $ColorRect/MarginContainer/VBoxContainer/HBoxContainer/CardCost

@onready var FlavorText: Node # assign to drop down label
@onready var CardStackName: Node = $ColorRect/MarginContainer/VBoxContainer/HBoxContainer2/RichTextLabel
@onready var CardStackValue: Node = $ColorRect/MarginContainer/VBoxContainer/HBoxContainer2/Label
@onready var CardMovementValue: Node = $ColorRect/MarginContainer/VBoxContainer/HBoxContainer4/Movement
@onready var CardArt: Node = $CardArt
@onready var CardHitBox: Node = $CollisionShape2D

@onready var Ghost_Sprite: Node = $ColorRect/MarginContainer/VBoxContainer/HBoxContainer4/GhostSprite
@onready var Hover_Sprite: Node = $ColorRect/MarginContainer/VBoxContainer/HBoxContainer4/HoverSprite
@onready var Freedom_Sprite: Node = $ColorRect/MarginContainer/VBoxContainer/HBoxContainer4/FreedomSprite

@onready var Debug_Box_id: Node = $Debug/id
@onready var Debux_Box_state: Node = $Debug/state
@onready var Debux_Box_parent: Node = $Debug/parent
@onready var Debux_Box_index: Node = $Debug/handspot

var card_size: Vector2 = Vector2(250,350)

@onready var start_pos: Vector2 = Vector2.ZERO
@onready var target_pos: Vector2 = Vector2.ZERO
@onready var time: float = 0
@onready var draw_time: float = 1
@onready var state = InHand
@onready var orig_scale = .75*scale
var zoom_scale 
@onready var old_state = INF
@export var zoom_time = 1.2
var mouse_time: float = 0.1
var test_index: int = 99

var selected = false
var this_card_in_hand: bool = false
var this_card_is_hovered: bool = false
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
	ReOrganiseHand, #6
	PushedAside #7
}

var startscale = Vector2.ZERO
var current_mouse_position : Vector2
var card_selected: bool = false
var resting_place: Vector2 = Vector2.ZERO

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

func _ready() -> void:
	pass

	
func _physics_process(delta: float) -> void:

	match state: # fix and understand the statemachine # splie into state machine nodes?
		InHand:
			pass
		InPlay:
			pass
		InPlay2:
			global_position = lerp(global_position, resting_place, 10 * delta)
			CardHitBox.disabled = true
		InMouse: # fix so the mouse grabs the card at the current mouse spot, instead of jumping to its center
			global_position = lerp(global_position - Vector2(90,100),get_global_mouse_position(),25*delta) 
		FocusInHand:
			pass
		MoveDrawnCardToHand: #animate from deck to the player hand
			pass
#			if time <= 1:
#				position = start_pos.lerp(target_pos,time)
#				time += delta/draw_time
##				print(state)
#			else:
#				position = target_pos
#				state = InHand
#				time = 0 # possible error location
##				print(state)
		ReOrganiseHand:
			position = target_pos
			state = InHand
#			print(state)
		
		PushedAside:
			pass
	Debux_Box_state.text = str(state)
	Debux_Box_index.text = str(test_index)
	Debug_Box_id.text = self.id
	Debux_Box_parent.text = str(this_card_is_hovered)

func populate_card(index) -> String:
	#card text, costs
	CardTitleLabel.text = CardData[index].title
	CardCost.text = str(CardData[index].Cost)
#	FlavorText.text = str(CardData[index].CardDesc) move to another label
	id = CardData[index].id
	#card movements

	if CardData[index].FreedomDirection == true: #pool all movement together and disperse as you like
		freedom_direction = true
		Freedom_Sprite.visible = true
		#direction you have 
		CardMovementValue.text =  "X" + str(CardData[index].Movement[0]) \
		+ " " + "Y" + str(CardData[index].Movement[1]) \
		+ " " + "Z" + str(CardData[index].Movement[2])
	if CardData[index].FreedomDirection == false:	
		movement_order = CardData[index].MovementOrder # basic card
		if movement_order.find(1) == 0: # x goes first
			CardMovementValue.text =  "X" + str(CardData[index].Movement[0]) \
			+ " " + "y" + str(CardData[index].Movement[1]) \
			+ " " + "z" + str(CardData[index].Movement[2])
		elif movement_order.find(1) == 1: # y goes first
			CardMovementValue.text =  "x" + str(CardData[index].Movement[0]) \
			+ " " + "Y" + str(CardData[index].Movement[1]) \
			+ " " + "z" + str(CardData[index].Movement[2])
		
		elif movement_order.find(1) == 2: # z goes first
			pass
		
		else:
			print("card error at movement order")
	if CardData[index].Diagonal == true: # can choose to swap 1 movement for diagonal
		diagonal = false # if true, player can use any movement to move diag
		# add signal for diagonal movement
	if CardData[index].Ghost == true: # can move through obstacles
		ghosting = true
		Ghost_Sprite.visible = true
		# add signal for ghosting
	if CardData[index].Hover == true: # can move over gaps
		Hover_Sprite.visible = true
		hover = false 
		# add signal for hovering
	
	#body language checks
	if CardData[index].BodyLanguage.is_empty():
		#print("card does not have body language")
		pass
	else:
		pass
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

func change_state(card: Node,input_state) -> void:
	card.state = input_state
	#connect signal to this function?

func send_movement(id) -> Vector3i:
	var index = search_card_from_input(id)
	print(id)
	
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

func _move_card_to_hand() -> void:
	match state:
		MoveDrawnCardToHand:
			var tween = get_tree().create_tween()
			tween.tween_property(self, "position", target_pos, draw_time).set_trans(Tween.TRANS_SINE)
			await tween.finished
			state = InHand


	
func _on_mouse_entered() -> void:
#	match state:
#		InHand:
#
##			var areas = get_overlapping_areas()
##			var is_on_top = true
##			for area in areas:
##				if area.this_card_in_hand == true:
##					area.move_to_front()
##				elif area.this_card_in_hand == false:
##					move_to_front()
##					# DO SOMETHIng with is_on_top
##					# if card is on top = false when mouse enters, set to true if just exiting another card
##					# if card is on top = true when 
#			var hover_position: int = -25
#			self.target_pos.y += hover_position
#			var tween = get_tree().create_tween()
#			tween.tween_property(self, "position", self.target_pos, .1).set_trans(Tween.TRANS_EXPO)
#			emit_signal("card_hovered",self,true) 
#	match state:
#		InPlay:
#
#			emit_signal("card_hovered",self,true) # fix so only 1 signal is needed to toggle between them
	pass

			
			
func _on_mouse_exited() -> void:
#	match state:
#		InHand:
#			var hover_position: int = -25
#			self.target_pos.y -= hover_position
#			var tween = get_tree().create_tween()
#			tween.tween_property(self, "position", self.target_pos, .1).set_trans(Tween.TRANS_EXPO)
#			emit_signal("card_hovered",self,false)
#	match state:
#		FocusInHand:
#			pass
#	match state:
#		InPlay:
#			emit_signal("card_hovered",self,false)
	pass

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void: # bug where releasing card with card and mouse overlapping another card doesn't allow you to selec card beind the top most card.
	match state:
		InHand, InPlay:
			if event.is_action_pressed("left_click"):
#
#				var areas = get_overlapping_areas()
#
#				var is_on_top = true
#				if areas.size() > 0:
#					for area in areas:
#						if not is_greater_than(area) and area.is_visible_in_tree():
#							is_on_top =  false
#							this_card_in_hand = false
#				if is_on_top:
				state = InMouse
				this_card_in_hand = true
				current_mouse_position = get_global_mouse_position()
				
			
		InMouse:
			if event.is_action_pressed("right_click"):
				state = ReOrganiseHand


func _input(event: InputEvent) -> void:
	match state:
		InMouse:
			if event.is_action_released("left_click") and selected == false:
				state = InHand
				#this_card_in_hand = false
				
				
			if event.is_action_released("left_click") and selected == true: # played over the play area
				state = InPlay2
				emit_signal("card_in_play_signal",self)





func _on_mouse_shape_entered(shape_idx: int) -> void:
		match state:
			InHand:
#			var areas = get_overlapping_areas()
#			var is_on_top = true
#			for area in areas:
#				if area.this_card_in_hand == true:
#					area.move_to_front()
#				elif area.this_card_in_hand == false:
#					move_to_front()
#					# DO SOMETHIng with is_on_top
#					# if card is on top = false when mouse enters, set to true if just exiting another card
	#					# if card is on top = true when 
				var hover_position: int = -25
				self.target_pos.y += hover_position
				var tween = get_tree().create_tween()
				tween.tween_property(self, "position", self.target_pos, .1).set_trans(Tween.TRANS_EXPO)
				emit_signal("card_hovered",self,true) 
				
		match state:
			InPlay:
				
				emit_signal("card_hovered",self,true) # fix so only 1 signal is needed to toggle between them


func _on_mouse_shape_exited(shape_idx: int) -> void:
		match state:
			InHand:
				var hover_position: int = -25
				self.target_pos.y -= hover_position
				var tween = get_tree().create_tween()
				tween.tween_property(self, "position", self.target_pos, .1).set_trans(Tween.TRANS_EXPO)
				emit_signal("card_hovered",self,false)
		match state:
			FocusInHand:
				pass
		match state:
			InPlay:
				emit_signal("card_hovered",self,false)
