shader_type canvas_item;


uniform float Speed : hint_range(.0, 10.0) = 2.0;
uniform float PixelIncrease = 10.0;
uniform bool Hovered = false;
uniform int direction : hint_enum("UP", "RIGHT", "DOWN", "LEFT", "NONE") = 4;

void vertex() {
	float VertexSpeed = abs(sin(TIME * Speed) * PixelIncrease);
	if (Hovered){
		switch (direction){
			case 0:
				VERTEX.y -= VertexSpeed;
				break;
			case 1:
				VERTEX.x += VertexSpeed;
				break;
			case 2:
				VERTEX.y += VertexSpeed;
				break;
			case 3:
				VERTEX.x -= VertexSpeed;
				break;
			case 4:
				break;
		}
	}
}
