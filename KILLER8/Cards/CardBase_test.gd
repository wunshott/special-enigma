extends Control

@export var CardData: Array[Resource]
@export var CardMovement_x: int = 0
@export var CardMovement_y: int = 0
@export var CardMovement_z: int = 0


@onready var ManueverDatabase := preload("res://manipulation/Manuevers/ManueverDatabase.gd")
#Edit so card base loads up card based on ID
#check that resource file tutorial for cards


var CardTitle := ManueverDatabase.Titles.GL
var CardDesc := ManueverDatabase.Descriptions.GL
var CardBodyLanguageTitle := ManueverDatabase.ManueverBodyLangages.GL
var CardBodyLanguageEffect = ManueverDatabase.BodyLanguages[CardBodyLanguageTitle]
var ManueverStackTitle = ManueverDatabase.ManueverStacks.GL[0]
var ManueverStackValue = ManueverDatabase.ManueverStacks.GL[1]
var ManueverCost = ManueverDatabase.Costs.GL
var MovementValue = ManueverDatabase.Movement.GL



@onready var CardTitleNode: Node = $GridContainer/CardLayout/VBoxContainer/TopBar/Name/CardTitleLabel
@onready var CardCost: Node = $GridContainer/CardLayout/VBoxContainer/TopBar/CardCost/CardCostLabel
@onready var CardDescription: Node = $GridContainer/CardLayout/VBoxContainer/FlavorText/DescriptionContainer/FlavorTextLabel
@onready var CardStackName: Node = $GridContainer/CardLayout/VBoxContainer/ManueverDescription/MarginContainer/ManeuverName
@onready var CardStackValue: Node = $GridContainer/CardLayout/VBoxContainer/ManueverDescription/DescriptionContainer/ManeuverValue
@onready var CardMovementValue: Node = $GridContainer/CardLayout/VBoxContainer/MovementValues/DescriptionContainer/CenterContainer/MovementDescription
@onready var FlavorText: Node = $GridContainer/CardLayout/VBoxContainer/FlavorText/DescriptionContainer/FlavorTextLabel

@onready var CardBorder: Node = $CardBorder
@onready var CardArt: Node = $CardArt # edit so it calls the proper art for gaslight (make a gaslight folder?)

#@onready var CardDatabase := preload("") # load up all the cards
#var CardName:= 'Footman'
#@onready var CardInfo = CardDatabase.DATA[CardDatabase.get(CardName)]







func _ready() -> void:
	#test(CardTitle,CardDesc,CardBodyLanguageTitle,CardBodyLanguageEffect,ManueverStackTitle,ManueverStackValue,ManueverCost, MovementValue)
	CardTitleNode.text = CardTitle
	CardCost.text = str(ManueverCost)
	CardStackName.text = ManueverStackTitle
	CardStackValue.text = str(ManueverStackValue)
	FlavorText.text = CardDesc
	
	
	CardMovementValue.text = "X" + str(MovementValue[0]) + " " + "Y" + str(MovementValue[1]) + " " + "Z" + str(MovementValue[2])
	
	
	
	
	#var CardSize = size
	#CardBorder.scale *= CardSize/CardBorder.texture.get_size()
	


func test(Title,Description,BodyLanguageTitle,BodyLanguageEffect, StackName, StackValue, CardCost,CardMovementValue) -> void:
	print(Title)
	print(Description)
	print(BodyLanguageTitle)
	print(StackName)
	print(StackValue)
	print(CardCost)
	print(CardMovementValue)
