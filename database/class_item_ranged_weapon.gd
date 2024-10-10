extends "res://database/items/class_item.gd"
class_name ranged_weapon

@export var base_damage: int = 1#From 1 to 100
@export var shot_rate: int = 0 #From 0 to 10. 0 : no repetition possible, 10 : very fast pace of shot rate 
@export var shot_distance: int #In meters
@export var shot_accuracy: int #In %, from 1 to 100
@export var shot_extent: int #Measure if bullets are widespread or not and how much. From 0 to 100
@export var shot_kickback: int #In jouls, measure how long the player will step back when he shots
@export_enum("9_mm_bullet", "shotgun_shell", "5_56_bullet", "bolt") var bullet_type : String #Tells what bullet is used by this weapon
@export_file var shot_sound #This is the sound that will be played when firing with that ranged weapon # (String, FILE)
@export var magazine_capacity : int
var current_number_of_bullets_in_magazine : int = 0
	
# Search for all bullets in all the differents stack in the inventory.
# Returns the total number of available bullets that can be used with this weapon
func get_total_available_bullets():
	
	var bullets_resources = inventory.find_all_item_resources_in_inventory(bullet_type)
	var total_bullets = 0
	if bullets_resources != null:
		for i in bullets_resources:
			total_bullets = total_bullets + i.units_in_stack
			pass
	
	return total_bullets
	
func load_bullets():
	current_number_of_bullets_in_magazine = magazine_capacity
	pass
