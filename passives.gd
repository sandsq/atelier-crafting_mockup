extends Control

signal passive_chosen(text: String)

@onready var passive_labels = $PassiveLabels
@onready var passive_buttons = $PassiveButtons

func draw_passives(passives: Dictionary):
	for label_child in passive_labels.get_children():
		label_child.queue_free()
	for node in passives:
		for passive in passives[node]:
			var passive_label = Label.new()
			passive_label.text = passive
			passive_labels.add_child(passive_label)

func draw_passives_as_selection(passives: Dictionary):
	for button_child in passive_buttons.get_children():
		button_child.queue_free()

	var button_group = ButtonGroup.new()
	for node in passives:
		for passive in passives[node]:
			var passive_button = CheckButton.new()
			passive_button.text = passive
			passive_button.toggle_mode = true
			passive_button.button_group = button_group
			passive_buttons.add_child(passive_button)

	button_group.pressed.connect(_on_passive_button_pressed)
	
func _on_passive_button_pressed(button: BaseButton):
	emit_signal("passive_chosen", button.text)
