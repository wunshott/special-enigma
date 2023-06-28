extends VBoxContainer

class_name ResourceItemDisplay

signal resourcebarA_filled

#Test Bar
@onready var texture_rect: TextureRect = $HBoxContainer/TextureRect
@onready var name_label: Label = $HBoxContainer/Label
@onready var quantity_label: Label = $HBoxContainer/Label2
@onready var Bar1: ProgressBar = $HBoxContainer/ProgressBar

#Card Draw Bar
@onready var Bar_card_Draw: ProgressBar = $HBoxContainer2/ProgressBar

@export var bar_fill_empty_speed: float 
var placholdercount: int = 0
var cardtype: String = "GL" 
var BarNames: Array[String] = ["Bar1", "card_draw"]

func _ready() -> void:
	pass
	
func update_count(bar_type:String, count:int) -> void:
	placholdercount += count
#	Bar1.value +=  count

	
	if bar_type == "Bar1":
		var tween = get_tree().create_tween()
		tween.tween_property(Bar1, "value", placholdercount, bar_fill_empty_speed).set_trans(Tween.TRANS_LINEAR)
		

	
	if bar_type == "card_draw": #cleaner way to do this? make variable with bar names
		var tween = get_tree().create_tween()
		tween.tween_property(Bar_card_Draw, "value", placholdercount, bar_fill_empty_speed).set_trans(Tween.TRANS_LINEAR)

	
func update_bar_1(bar_type:String, Quantity:int) -> void: #make this function select the proper bar based on the input
	# check for bar type, just 1 bar for now
	update_count(bar_type,Quantity)


func _spawn_card() -> void: # this function is called when a resource bar fills up. calls a random card
	pass

func _test() ->void:
	print("test")	

func _revive_card() -> void: #this function pulls a card from discard when a resource bar fills upo
	pass
	
func _improvise_card() -> void: #this function draws 3 cards and lets the player pick 1 when a bar fills
	pass
	
func _draw_card() -> void: # this function draws a random card from the deck when a bar fills
	# draw random card from deck into your hand
	# make copy of deck array
	# remove that card from the copy of deck array
	
	pass

func _group_test() -> void:
	print("group worked")

func _on_progress_bar_value_changed(value: float) -> void: # move this function to each individual progress bar? inherit the actual progress bar?
	if value >= Bar_card_Draw.max_value:
		_spawn_card()
		var overflow: int = value - Bar_card_Draw.max_value
		
		var tween = get_tree().create_tween()
		tween.tween_property(Bar_card_Draw, "value", 0, bar_fill_empty_speed*1.5).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT).set_delay(.3)
		placholdercount = 0
		
		
		resourcebarA_filled.emit(cardtype) # inherit copies of the progress bar that give out different resrouces
		
				
	elif value < Bar1.max_value:
		#shake meter
		#play sound effect
		pass
