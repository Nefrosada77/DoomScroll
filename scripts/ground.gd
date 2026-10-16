extends CSGBox3D


func change_color(new_color : Color):
	material.set_shader_parameter('color', new_color)
