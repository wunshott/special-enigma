extends RichTextLabel

@onready var Key_Phrases: Array[String] = [ "ex", "t", "Random"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for phrase in Key_Phrases:
		if self.get_selected_text() == phrase:
			print(self.get_selected_text())
