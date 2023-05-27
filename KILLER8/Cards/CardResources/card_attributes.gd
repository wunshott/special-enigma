extends Resource #extends Node
class_name CardAttributes

#This is the template file for cards. You will make resource files that fill in these export values


@export var id: String = "" #Unique Card ID ShortHand
@export var title: String = "" # "GasLight"
@export var CardDesc: String = "" # Card flavor text and description

@export var StackTitle: PackedStringArray = []# ["Lie" "Resentment"] packed string array more efficient
@export var StackValue: Array[int] = [] # [1 1] #maps to titles above
@export var BodyLanguage: String = "" #"Sales Person"

@export var Movement: Array[int] = [] #[x y z]
@export var MovementOrder: Array[int]
@export var FreedomDirection: bool = false #allowed to sum movement points then move in any allowed direction with the pool of points
@export var Diagonal: bool = false # allowed to move diagonally
@export var Ghost: bool = false #Can you move through solid objects
@export var Hover: bool = false # can you move over gaps

@export var Cost: int = 0 # resources the card will cost
@export var CardArt: Texture = null

