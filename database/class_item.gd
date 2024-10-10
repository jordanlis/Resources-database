extends Resource
class_name item

#Fixed parameters
@export var unique_key: String #Instead of using number ID, I will use string ID which MUST be unique. No mistake allowed :) 2 items cannot have the same unique_key
@export var name: String
@export var icon: Texture2D
@export_enum("ammunition", "ranged weapon", "weapon", "weapon improvement", "material", "consumable", "explosive or trap", "tool", "raw food", "beverage", "consumable food", "camp improvement", "valuable good", "pharmaceutical product") var category : String
@export var available_actions = {
	"use":false,
	"equip":false,
	"combine":false, #Stack can be combined, but also items between themselves. Example : Silencer + gun
	"throw_away":false,
	"rotate":false
}
@export var description: String
@export var weight: float #in grams, can be below 1 gram. For example : 0.1 g, 0.5 g, and so on
@export var barter_value: int #from 0 to 1000
@export var is_consumable: bool = false #If yes, each time the player uses this item, its number will decrease by 1
var currently_equipped = false #If yes, this means that the equipment is equipped :) 

@export var max_units_per_stack: int #from 1 to 100

@export_enum("nowhere", "workshop", "laboratory", "garden", "campfire") var where_to_craft : String
@export var crafting_ingredients: Dictionary #The keys will contain the unique_key of the ingredient, and the value will contain the quantity of items required

#Parameters that can change in-game and depends on player's actions
@export var units_in_stack: int = 0
var pos_in_grid = Vector2(-1,-1) #Allow the inventory to remember the position of the item. Unit = cell coordinate starting from 1. By default, -1 allows the script to know that the item was never placed before so it has to place it at first available spot instead of placing it at these current coordinates. 
var pouch #In which pouch of the inventory is the item currently stored ? 
