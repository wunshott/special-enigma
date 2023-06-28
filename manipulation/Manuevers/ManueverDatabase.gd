extends Resource #extends Node
class_name ManueverDatabase

# export value for cards to inherit

var hand := 1
var movement_ := 2
#cards go into hand


#effects go onto cards

var cards := {"Gaslight":Movement
	
	}
# This Dictionary File Holds all the Manuevers. Find a way to explain the data so each manuever
# is a nested dictionary 

const Movement := {
	# value (x,y,z): float, Freedom of movement check: boolean, xyz: float (3 2 1 means z -> y -> x
	#ominidirectional check (can move in any direction, sum of movement vector), ADJ only: Boolean, Move through obstacle boolean check
	"GL": [1, 1, 2, true, 2, 1, 3, false, true, false], #Gaslight, high freedom of movement manuever
	"ST": [1, 0, 0, false, 0, 0, 0, true,  true, false] #Smalltalk, can only move adjacent 1 space
	
	
	}

#const BodyLanguage: Dictionary = {
#	"Pouty": Pousty.tscn, #make sure to add the full directory
#	"Excited": Excited.tscn,
#	"Confident": Excited.tscn,
#
#} 
#This Dictionary contains all the bodylangauges

const Descriptions := {
	"GL":"Make your target question their reality and trust you more by confidently asserting their perception isn't real. Move IMPORT MOVEMENT AS VARIABLE HERE
	adjacent spaces on the board while creating a shadow that mimics your movement at a place of your choosing on the board"
	
	}

const Titles := {
	"GL":"Gaslight"
	
	}
	
const BodyLanguages := {
	"Pout":"Effect",
	"Arrogant":"Effect",
	"Annoyed":"Effect",
	"Suspicious":"Effect",
	"Sales Person": "Open arms and open palms. This conveys that you want to be trusted."
	#Breack out flavor text from the actual effect
}

const ManueverBodyLangages := {
	"GL":"Sales Person"
	
}

const Stacks :={
	"lie":1,
	"Resentment":1
	
}
#This Dictionary contains all the types of CovoActions that can stack

const ManueverStacks := {
	"GL": ["Lie", 1]
	
}

const Costs := { #don't know how I will do card costs.
	"GL": 2
}
