extends Button

@export var suffix_svg_path: String = ""  # 后置图标的 SVG 路径
@onready var hbox: HBoxContainer = HBoxContainer.new()
@onready var prefix_icon_node: TextureRect
@onready var label_node: Label
@onready var suffix_icon_node: TextureRect

var count: int = 0

func _ready():
	pressed.connect(on_clicked)
	
	# 不让按钮自动绘制 icon 和 text，由我们自行控制
	flat = true
	# 移除按钮内置文本和图标的视觉输出：通过主题或让按钮不绘制任何内容
	# 如果有需要，可在 theme 中给 Button 设置无前景样式，以确保不重复绘制

	add_child(hbox)
	hbox.alignment = HBoxContainer.ALIGNMENT_CENTER

	var font_color: Color = get_theme_color("font_color", "Button")
	if font_color == null:
		font_color = Color(1,1,1)

# 如果有 icon（从 Button 属性来）
	if icon:
		prefix_icon_node = TextureRect.new()
		prefix_icon_node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		hbox.add_child(prefix_icon_node)
	# 稍后根据文本尺寸动态加载和缩放

	# 如果有 text（从 Button 属性来）
	if text != "":
		label_node = Label.new()
		label_node.add_theme_color_override("font_color", font_color)
		label_node.text = text
		text = ""
		hbox.add_child(label_node)

	# 如果有 suffix_svg_path 自定义后缀图标
	if suffix_svg_path != "":
		suffix_icon_node = TextureRect.new()
		suffix_icon_node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		hbox.add_child(suffix_icon_node)

	update_icon_style(font_color)


func update_icon_style(font_color: Color):
	# 获取字体样式（假设从 Theme 中获取 Button 的默认字体颜色和大小）
	var font_size: int = 14 if label_node == null else label_node.get_theme_font_size("font_size", "Button")
	if font_size <= 0:
		font_size = 14

	# 图标大小参考字体大小，可以根据需要进行微调
	var icon_size = int(font_size) # 转为 int，SVG 渲染需要整数尺寸
	if icon_size < 8: 
		icon_size = 8
		
	add_theme_constant_override("icon_max_width", icon_size)
	# 更新前缀图标纹理
	if prefix_icon_node and icon:
		prefix_icon_node.texture = create_texture_from_svg_if_needed(icon, icon_size, icon_size)
		prefix_icon_node.self_modulate = font_color
		icon = null

	# 更新后缀图标纹理
	if suffix_icon_node and suffix_svg_path != "":
		suffix_icon_node.texture = load_svg_as_texture(suffix_svg_path, icon_size, icon_size)
		suffix_icon_node.self_modulate = font_color

	adjust_button_size()


func load_svg_as_texture(svg_path: String, width: int, height: int) -> Texture2D:
	var img: Image = Image.load_from_file(svg_path)
	img.resize(width, height)
	for x in range(img.get_width()):
		for y in range(img.get_height()):
			var new_px: Color = img.get_pixel(x, y)
			if new_px.r < 0.01 and new_px.g < 0.01 and new_px.b < 0.01:
				img.set_pixel(x, y, Color(1,1,1, new_px.a))
	return ImageTexture.create_from_image(img)

func create_texture_from_svg_if_needed(tex: Texture2D, width: int, height: int) -> Texture2D:
	var img: Image = tex.get_image()
	if img:
		img.resize(width, height)
		for x in range(img.get_width()):
			for y in range(img.get_height()):
				var new_px: Color = img.get_pixel(x, y)
				if new_px.r < 0.01 and new_px.g < 0.01 and new_px.b < 0.01:
					img.set_pixel(x, y, Color(1,1,1, new_px.a))
		return ImageTexture.create_from_image(img)
	return tex
	

func adjust_button_size():
	# 尝试根据 hbox 的最小尺寸来设置按钮的 rect_min_size
	# 因为 hbox 是 Container，会根据其子节点计算自身大小。
	# 注意：get_minimum_size() 是 Control 的方法，HBoxContainer 作为 Container 应能返回子节点所需的大小。
	var min_size: Vector2 = hbox.get_minimum_size()
	custom_minimum_size = min_size
	
func on_clicked():
	count += 1
	do_set_text(label_node.text + str(count))

func do_set_text(value: String) -> void:
	label_node.text = value
	adjust_button_size()
