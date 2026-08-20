extends Node2D

const CELL := 24
const COLS := 24
const ROWS := 18
const TICK := 0.12

var snake: Array[Vector2i] = []
var dir := Vector2i.RIGHT
var next_dir := Vector2i.RIGHT
var food := Vector2i.ZERO
var elapsed := 0.0
var alive := true
var score := 0

func _ready() -> void:
	reset()


func reset() -> void:
	snake = [Vector2i(6, 9), Vector2i(5, 9), Vector2i(4, 9)]
	dir = Vector2i.RIGHT
	next_dir = Vector2i.RIGHT
	alive = true
	score = 0
	elapsed = 0.0
	spawn_food()
	queue_redraw()


func spawn_food() -> void:
	if snake.size() >= COLS * ROWS:
		alive = false
		return
	var occupied := {}
	for cell in snake:
		occupied[cell] = true
	food = Vector2i(randi() % COLS, randi() % ROWS)
	while occupied.has(food):
		food = Vector2i(randi() % COLS, randi() % ROWS)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if not alive:
			reset()
			return
		match event.keycode:
			KEY_UP, KEY_W:
				if dir != Vector2i.DOWN:
					next_dir = Vector2i.UP
			KEY_DOWN, KEY_S:
				if dir != Vector2i.UP:
					next_dir = Vector2i.DOWN
			KEY_LEFT, KEY_A:
				if dir != Vector2i.RIGHT:
					next_dir = Vector2i.LEFT
			KEY_RIGHT, KEY_D:
				if dir != Vector2i.LEFT:
					next_dir = Vector2i.RIGHT


func _process(delta: float) -> void:
	if not alive:
		return
	elapsed += delta
	if elapsed < TICK:
		return
	elapsed = 0.0
	_tick()


func _tick() -> void:
	dir = next_dir
	var head: Vector2i = snake[0] + dir
	if head.x < 0 or head.y < 0 or head.x >= COLS or head.y >= ROWS or head in snake:
		alive = false
		queue_redraw()
		return
	snake.push_front(head)
	if head == food:
		score += 1
		spawn_food()
	else:
		snake.pop_back()
	queue_redraw()


func _board_origin() -> Vector2:
	var size := Vector2(COLS * CELL, ROWS * CELL)
	var origin := (get_viewport_rect().size - size) * 0.5
	origin.y += 12.0
	return origin


func _draw() -> void:
	var origin := _board_origin()
	var board_size := Vector2(COLS * CELL, ROWS * CELL)
	var font := ThemeDB.fallback_font
	var status := "Score: %d" % score
	if not alive:
		status += "    GAME OVER — press any key"
	else:
		status += "    arrows / WASD"
	draw_string(font, Vector2(origin.x, origin.y - 16.0), status, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(0.9, 0.92, 0.95))
	draw_rect(Rect2(origin, board_size), Color(0.07, 0.09, 0.11))
	draw_rect(Rect2(origin, board_size), Color(0.18, 0.22, 0.26), false, 2.0)
	for i in snake.size():
		var color := Color(0.42, 0.88, 0.48) if i == 0 else Color(0.24, 0.64, 0.32)
		draw_rect(Rect2(origin + Vector2(snake[i]) * CELL + Vector2(1, 1), Vector2(CELL - 2, CELL - 2)), color)
	draw_rect(Rect2(origin + Vector2(food) * CELL + Vector2(4, 4), Vector2(CELL - 8, CELL - 8)), Color(0.92, 0.34, 0.3))
