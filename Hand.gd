extends Node2D

@export var hand_spread_curve: Curve # first curve is card placement
# <.5 should move the hand to be negative
# > .5 should move the hand to be positive
# linear curve
@export var hand_rotation_curve: Curve # curve for rotating card
# <.5 should rotate CCW
# >. 5 should rotate CW
# .5 = 0

@export var hand_veritical_curve: Curve # curve for how high the card is
# <.5 should lower the card
# > .5 should lower the card
# .5 = neutral
#parabola

@export var HAND_WIDTH: float
@onready var CARD = preload("res://Cards/CardBase.tscn")



const MaxCardHand = 7
const HandSize = 7
var hand_ratio = []
var player_hand:Array = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_5_cards()
	#spawn_cards2(MaxCardHand)
	#spawn_cards(MaxCardHand)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass




func add_5_cards() -> void:
	var current_card: float = 0.0
	for x in MaxCardHand: # hand of 5 cards
		
		#if get_child_count() == 1: Do something if you only have 1 card in hand
			#hand_ratio = 0.5
		
		#else:
	
			#var hand_ratio = MaxCardHand / float(self.get_child_count() - 1)
			# gets the current index of the card and divides by the total chidlren added to hand - 1
		# this gives you the cards ratio so you display it
			#print(self.get_child_count())
		
		#generates the hand ratio for the entire rand (all cards have equal value betwween them)
		var current_card_hand_ratio := current_card / (MaxCardHand - 1)
		hand_ratio.append(current_card_hand_ratio)
		current_card += 1.0
		
		
		var destination := self.global_transform #must use this variable so it overrides and adds to itself to apply to the next card properly
		#Sets how far apart the cards are
		destination.origin.x += hand_spread_curve.sample(hand_ratio[x]) * 250
		
		#stes how high the cards are
		destination.origin.y -= hand_veritical_curve.sample(hand_ratio[x]) * 30
		
		
		#print(destination.origin)
		
		var card = CARD.instantiate()
		
		
		
		#card.target_transform.origin = destination.origin for 3D card
		#card.position.x = 500 + destination.origin.x
		
		#rotates the card
		card.rotation = hand_rotation_curve.sample(hand_ratio[x]) * .2
		#card.set_global_position(Vector2(destination.origin.x,destination.origin.y))
		card.position = destination.origin + Vector2(500,20)
		
		add_child(card)
		card.populate_card(1)
		
	print(hand_ratio)


	#print(hand_ratio)

	var origin = self.get_global_transform()
	var origin2 = self.global_transform

func spawn_cards(HandCount) -> void: #best function yet
	
	
#	var card = CARD.instantiate()
	var viewport_dimension = get_viewport_rect().size
#	var center_card_origin = Vector2((viewport_dimension.x*.5) - (card.size.x/2),(viewport_dimension.y*.95) - (card.size.y/1.25))
#	card.position = center_card_origin #Vector2(-250/2,-350/2) #
#	card.scale *= .9
#
#	add_child(card)
#	card.populate_card(1)
##	print(viewport_dimension)
##	print(center_card_origin)
#
#
#	var card2 = CARD.instantiate()
#	card2.position.x = -50 #hand_spread_curve.sample(0) * HAND_WIDTH
#	card2.position.y = 500
#	add_child(card2)
#	card2.populate_card(0)
#
#	print(hand_spread_curve.sample(0)*100)
	
	if HandSize > 1: #more than 1 card in the hand
		var gap = 10
		var HAND_WIDTH2: float = HandSize * (250+(2*gap))
	
		
		var current_card: float = 0.0
		for card_number in HandSize:
			var current_card_hand_ratio := current_card / (HandSize - 1) 
			hand_ratio.append(current_card_hand_ratio) # creates the hand ratio array. 
			current_card += 1.0
			var card3 = CARD.instantiate()
			player_hand.append(card3)
			
			# this is the starting position of the cards
			if card_number == 0:
				
				if HAND_WIDTH2 < viewport_dimension.x: #hand small enough to fit on screen
					var starter_width2 = (viewport_dimension.x - HAND_WIDTH2)/2 
					card3.position.x = starter_width2
					card3.position.y = viewport_dimension.y*.5
					
					
					add_child(card3)
					#print(card3.position.x)
					#print(HAND_WIDTH2)
				
				if HAND_WIDTH2 > viewport_dimension.x: #hand too big, creates negative placement
					var starter_width1 = 25
					card3.position.x = starter_width1
					card3.position.y = viewport_dimension.y*.5
					add_child(card3)
					#print(card3.position.x)
					#print(HAND_WIDTH2)
			
			# this places the rest of the cards
			else:
				card3.position.x = hand_ratio[card_number]*HAND_WIDTH2* hand_spread_curve.sample(hand_ratio[card_number])
				card3.position.y -= hand_veritical_curve.sample(hand_ratio[card_number]) * 180 - viewport_dimension.y*.5 
				add_child(card3)
				print(card3.position.y)
				
				
	elif HandSize == 1: #1 card in hand
		pass
	else: #0 card in hand
		pass

@onready var Center_Oval: Vector2 = Vector2(get_viewport().size.x * .5, get_viewport().size.y*1.2)
@onready var Hor_rad = get_viewport().size.x * 0.45
@onready var Ver_rad = get_viewport().size.y * 0.4
var angle = deg_to_rad(90) - .5 #need to make the offset match the handsize
var OvalAngleVector = Vector2()

func spawn_cards2(HandCount) -> void:

	
	if HandSize > 1: #more than 1 card in the hand
	
		for card_number in HandSize:
			
			var card3 = CARD.instantiate()
			OvalAngleVector = Vector2(Hor_rad*cos(angle), -Ver_rad*sin(angle))
			card3.rotation  = angle - deg_to_rad(45)
			card3.position = Center_Oval + OvalAngleVector - card3.size/2
			card3.scale *= .75
			angle += 0.25 # make the card spacing scale with hand size
			
			add_child(card3)
				
				
	elif HandSize == 1: #1 card in hand
		pass
	else: #0 card in hand
		pass
	

	

