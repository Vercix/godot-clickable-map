extends Control

var current_num = 0;

onready var label = $PanelContainer/VBoxContainer/Panel/HBoxContainer/Label;

func _ready():
	pass

func _on_Main_selected_area(area):
	label.set_text("Selected Area: " + str(area))
