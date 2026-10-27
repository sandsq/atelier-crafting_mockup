extends Control

@export var inventory_size = 24

var items: Array[CraftingMaterial]

@onready var inventory_slot_scene = preload("res://inventory/inventory_slot.tscn")
@onready var coal_scene = preload("res://materials/coal.tscn")
@onready var vial_of_water_scene = preload("res://materials/vial_of_water.tscn")
@onready var iron_ingot_scene = preload("res://materials/iron_ingot.tscn")
@onready var grid_container = $GridContainer

func _ready() -> void:
	var coal1 = coal_scene.instantiate()
	coal1.crafting_material_info.passive_buff = "Burn: Level 1"
	items.append(coal1)
	items.append(coal_scene.instantiate())
	items.append(coal_scene.instantiate())
	items.append(coal_scene.instantiate())
	items.append(coal_scene.instantiate())
	var water1 = vial_of_water_scene.instantiate()
	water1.crafting_material_info.passive_buff = "Lifesteal: Level 1"
	items.append(water1)
	items.append(vial_of_water_scene.instantiate())
	items.append(vial_of_water_scene.instantiate())
	var ingot1 = iron_ingot_scene.instantiate()
	ingot1.crafting_material_info.passive_buff = "Damage up: Level 1"
	items.append(ingot1)
	var ingot2 = iron_ingot_scene.instantiate()
	ingot2.crafting_material_info.passive_buff = "Slash up: Level 1"
	items.append(ingot2)
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
