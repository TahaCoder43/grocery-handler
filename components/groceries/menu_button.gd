extends MenuButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var popup = self.get_popup()
	popup.index_pressed.connect(change_title)
	
func change_title(index):
	var popup = self.get_popup()
	self.text = popup.get_item_text(index)
