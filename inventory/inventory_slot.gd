extends Control


var item_being_held: CraftingMaterial

@onready var item_holder = $PanelContainer/ItemHolder

func display_item_in_holder(item: CraftingMaterial):
	item_holder.add_child(item)


func _get_drag_data(_at_position: Vector2) -> Variant:
	if item_holder.get_child_count() == 0:
		return null

	var item = item_holder.get_child(0) as CraftingMaterial
	item_being_held = item
	print("dragging %s" % item)
	var preview = Control.new()
	var preview_icon = item_being_held.icon.duplicate()
	preview.add_child(preview_icon)
	set_drag_preview(preview)
	item_being_held.modulate.a = 0.0

	return {"item": item, "source_slot": self}

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_DRAG_END:
			if item_being_held != null:
				item_being_held.modulate.a = 1.0
