extends Control

@export var inventory_size = 24

var items: Array[CraftingMaterial]

@onready var inventory_slot_scene = preload("res://inventory/inventory_slot.tscn")
@onready var coal_scene = preload("res://materials/coal.tscn")
@onready var vial_of_water_scene = preload("res://materials/vial_of_water.tscn")
@onready var iron_ingot_scene = preload("res://materials/iron_ingot.tscn")
@onready var grid_container = $GridContainer

func _ready() -> void:
	items.append(coal_scene.instantiate())
	items.append(coal_scene.instantiate())
	items.append(coal_scene.instantiate())
	items.append(coal_scene.instantiate())
	items.append(coal_scene.instantiate())
	items.append(vial_of_water_scene.instantiate())
	items.append(vial_of_water_scene.instantiate())
	items.append(vial_of_water_scene.instantiate())
	items.append(iron_ingot_scene.instantiate())
	items.append(iron_ingot_scene.instantiate())
	items.append(iron_ingot_scene.instantiate())
	items.append(iron_ingot_scene.instantiate())
	for i in range(0, inventory_size):
		var inventory_slot = inventory_slot_scene.instantiate()
		grid_container.add_child(inventory_slot)
		if i < items.size():
			inventory_slot.display_item_in_holder(items[i])

func place_item_in_next_slot(item: CraftingMaterial):
	for slot in grid_container.get_children():
		if slot.item_holder.get_children().size() == 0:
			slot.display_item_in_holder(item)
			break

	print("inventory ran out of space, placeholder to deal with it")
