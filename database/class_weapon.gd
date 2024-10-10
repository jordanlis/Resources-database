extends "res://database/items/class_item.gd"
class_name weapon

@export var base_damage: int = 1#From 1 to 100
@export_file var attack_sound #This is the sound that will be played when attacking with that weapon # (String, FILE)
@export_file var impact_sound #This is the sound that will be played when reaching ennemies with that weapon # (String, FILE)
