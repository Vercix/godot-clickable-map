extends Node2D

const DIM = 10;

onready var sprite = $Sprite;

var lookup_texture;
var map_texture;
var color_texture;

var areas = {}
var owners = {}

signal selected_area(area)

func parse_area(data):
	data.color = Color8(data.color[0], data.color[1], data.color[2])
	data.id = int(data.id)
	data.owner = int(data.owner)
	areas[data.color] = data

func parse_owner(data):
	data.color = Color8(data.color[0], data.color[1], data.color[2])
	data.id = int(data.id)
	owners[data.id] = data

func load_file(path : String):
	var file = File.new()
	file.open("res://" + path, File.READ)
	var content = file.get_as_text()
	file.close()
	return content

func load_data():
	var json = JSON.parse(load_file("areas.json"))
	if typeof(json.result) == TYPE_ARRAY:
		for area in json.result:
			parse_area(area);
	else:
		push_error("Unexpected results.")
		
	json = JSON.parse(load_file("owners.json"))
	if typeof(json.result) == TYPE_ARRAY:
		for owner in json.result:
			parse_owner(owner);
	else:
		push_error("Unexpected results.")
	

func generate_map():
	map_texture = sprite.texture.get_data();
	
	lookup_texture = Image.new();
	lookup_texture.create(400, 400, false, Image.FORMAT_RGBF);
	
	color_texture = Image.new();
	color_texture.create(DIM, DIM, false, Image.FORMAT_RGBF);
	
	lookup_texture.lock();
	map_texture.lock();
	color_texture.lock();
	
	for x in range(map_texture.get_width()):
		for y in range(map_texture.get_height()):
			var area_id = areas[map_texture.get_pixel(x, y)].id;
			var uv = Vector2((float(area_id % DIM)/ (DIM - 1)), (floor(area_id/DIM) / (DIM - 1)));
			lookup_texture.set_pixel(x, y, Color(uv.x, uv.y, 0.0));
			
	for area in areas:
		var uv = Vector2((float(areas[area].id % DIM)), (floor(areas[area].id/DIM)));
		color_texture.set_pixel(uv.x, uv.y, owners[areas[area].owner].color)
	
	color_texture.unlock();
	
	var itex = ImageTexture.new();
	itex.create_from_image(lookup_texture, 0);
	sprite.material.set_shader_param("lookup_texture", itex);
	
	var itex2 = ImageTexture.new();
	itex2.create_from_image(color_texture, 0);
	sprite.material.set_shader_param("color_texture", itex2);


func _ready():
	load_data()
	generate_map()

func _input(event):
	if event is InputEventMouseButton:
		var mouse_pos = Vector2(event.position[0], event.position[1])
		sprite.material.set_shader_param("selected_area", lookup_texture.get_pixelv(mouse_pos));
		var color = map_texture.get_pixelv(mouse_pos);
		emit_signal("selected_area", areas[color])
