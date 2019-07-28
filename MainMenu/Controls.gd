extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready():
	$Panel.hide()
	
func _on_BackButton_pressed():
	$Panel.hide()
