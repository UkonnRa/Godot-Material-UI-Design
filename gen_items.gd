extends HFlowContainer

@export var button_template: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if button_template != null:
		for i in range(10):
			var btn: Button = button_template.instantiate()
			btn.text = "Hello " + str(i)
			add_child(btn)
