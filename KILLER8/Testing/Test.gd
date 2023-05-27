extends Node2D

@onready var test2 = preload("res://Cards/CardResources/Gaslight.tres")
@onready var testnode: Node = $Origin
@onready var endnode: Node = $Destination

@export var Test: Resource
@export var TestC: CardAttributes
@export var testarray: Array
@export var testcardarray: Array[CardAttributes]
@export var number = 5


var Sprite

func _ready() -> void:
#	if TestC:
#		print("resource loaded")
#		print(TestC.title)
#	if test2:
#		print(test2.title)
#	print(testarray.find("b"))
#	print(TestC.find(Test.id))

#	for card in testcardarray:
#		if card.id == "GL":
#			print("GL CARD FOUND")
#		if card.id == "GP":
#			print("GP CARD FOUND")
			
	print("the number is " + str(number))
	var vector = Vector2i(1,1)
	float(vector.x)
	print(get_viewport().size * 0.5)
		#print(card_index)
		#print(testarray[card_index])
		#var testing = testarray.bsearch("3")
		#print(testing)
#		if ID == CardData[card_index].id:
#			return card_index
	emit_signal("test")




func _on_button_spawn_node_pressed() -> void:
	var sprite = Sprite2D.new()
	add_child(sprite)
	sprite.reparent(testnode)


func _on_button_change_parent_pressed() -> void:
	for child in testnode.get_children():
		child.reparent(endnode)
