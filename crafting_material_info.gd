class_name CraftingMaterialInfo
extends Resource

# cosmetic
@export var material_name: String
@export var length: int = 40
@export var height: int = 40

# crafting contribution
@export var element: Elements.Elements
@export var elemental_contribution: int = 1
@export var size: int = 1 ## workbench has a maximum total size as a constraint
