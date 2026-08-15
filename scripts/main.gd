extends Node2D

const WAVE_DURATION := 45.0
const MAX_WAVES := 12
const ARENA_SIZE := Vector2(2200, 1400)
const PLAYER_RADIUS := 22.0
const XP_TO_LEVEL := 12
const SPAWN_WARNING_TIME := 0.75
const SPAWN_EDGE_PADDING := 48.0
const BASE_SHOP_SLOTS := 3
const MAX_SHOP_SLOT_BONUS := 3
const BASE_WEAPON_SLOTS := 3
const SHOP_REFRESH_BASE_COST := 3
const SHOP_REFRESH_COST_STEP := 2

const WEAPON_POOL := [
	{
		"id": "gravity",
		"name": "万有引力",
		"desc": "周期性生成引力场，拉扯敌人并造成中心挤压伤害。",
		"type": "field",
		"base_cost": 18,
		"max_level": 5,
	},
	{
		"id": "friction",
		"name": "摩擦力",
		"desc": "自身周围常驻摩擦场，减速并按敌人速度造成动能伤害。",
		"type": "aura",
		"base_cost": 16,
		"max_level": 5,
	},
	{
		"id": "momentum",
		"name": "动量守恒",
		"desc": "自动发射弹球，命中后寻找附近敌人弹射并逐跳增伤。",
		"type": "projectile",
		"base_cost": 20,
		"max_level": 5,
	},
	{
		"id": "thermal_expansion",
		"name": "热膨胀",
		"desc": "在敌群中心爆发膨胀冲击，越靠中心伤害越高。",
		"type": "burst",
		"base_cost": 22,
		"max_level": 5,
	},
	{
		"id": "angular_momentum",
		"name": "角动量",
		"desc": "自身周围形成旋转力场，按敌人体型造成伤害并将其甩开。",
		"type": "aura",
		"base_cost": 24,
		"max_level": 5,
	},
	{
		"id": "ohm",
		"name": "欧姆定律",
		"desc": "周期性释放链式电流，依次击穿多个目标并逐跳衰减。",
		"type": "chain",
		"base_cost": 25,
		"max_level": 5,
	},
	{
		"id": "lorentz",
		"name": "洛伦兹力",
		"desc": "发射带电粒子，穿过力场时轨迹偏转、速度提升并增加伤害。",
		"type": "projectile",
		"base_cost": 27,
		"max_level": 5,
	},
	{
		"id": "entropy",
		"name": "熵增定律",
		"desc": "周期性提高全场敌人的熵，每层使其受到的伤害增加 5%。",
		"type": "aura",
		"base_cost": 28,
		"max_level": 5,
	},
	{
		"id": "thermal_conduction",
		"name": "热传导",
		"desc": "点燃最近目标，灼烧会向附近敌人传播并逐次衰减。",
		"type": "spread",
		"base_cost": 26,
		"max_level": 5,
	},
]

const ACADEMIC_STAGES := [
	{"level": 1, "name": "小学", "title": "力学启蒙", "bonus": "移动速度 +5%"},
	{"level": 3, "name": "初中", "title": "运动研究者", "bonus": "法则冷却 -10%"},
	{"level": 5, "name": "高中", "title": "实验物理学徒", "bonus": "最大生命 +20"},
	{"level": 7, "name": "大学", "title": "理论物理学生", "bonus": "法则伤害 +15%"},
	{"level": 10, "name": "硕士", "title": "物理专精学者", "bonus": "物理法则伤害 +20%"},
	{"level": 13, "name": "博士", "title": "法则研究者", "bonus": "护甲 +4，法则伤害 +12%"},
	{"level": 16, "name": "博士后", "title": "统一场追寻者", "bonus": "融合冷却 -15%，伤害 +15%"},
]

const EXAM_WAVES := {
	3: {
		"name": "升学考试·力与运动",
		"boss": "惯性质量体",
		"kind": "mechanics",
		"hp": 560.0,
		"radius": 52.0,
		"reward_money": 18,
		"reward_xp": 12,
		"color": Color(0.95, 0.72, 0.22),
	},
	6: {
		"name": "升学考试·电磁感应",
		"boss": "交变磁场核心",
		"kind": "electromagnetism",
		"hp": 920.0,
		"radius": 58.0,
		"reward_money": 28,
		"reward_xp": 18,
		"color": Color(0.2, 0.82, 1.0),
	},
	9: {
		"name": "升学考试·热力学综合",
		"boss": "不可逆热机",
		"kind": "thermodynamics",
		"hp": 1380.0,
		"radius": 64.0,
		"reward_money": 40,
		"reward_xp": 26,
		"color": Color(1.0, 0.34, 0.12),
	},
	12: {
		"name": "终极答辩·万物理论",
		"boss": "统一场方程",
		"kind": "unified_field",
		"hp": 2200.0,
		"radius": 72.0,
		"reward_money": 60,
		"reward_xp": 40,
		"color": Color(0.78, 0.56, 1.0),
	},
}

const ITEM_POOL := [
	{"id": "apple", "name": "牛顿的苹果", "desc": "万有引力范围 +30%", "cost": 16, "rarity": "common"},
	{"id": "maxwell", "name": "麦克斯韦的手稿", "desc": "法则冷却 -8%", "cost": 18, "rarity": "common"},
	{"id": "mendeleev", "name": "焦耳的热功当量", "desc": "热膨胀范围 +20%，伤害 +10%", "cost": 18, "rarity": "common"},
	{"id": "darwin", "name": "法拉第探测线圈", "desc": "经验拾取范围 +25%，击杀收益 +1 概率提高", "cost": 19, "rarity": "common"},
	{"id": "lagrange", "name": "拉格朗日的方程", "desc": "动量守恒弹射 +1", "cost": 24, "rarity": "rare"},
	{"id": "field_notes", "name": "场论札记", "desc": "场类伤害 +18%", "cost": 22, "rarity": "rare"},
	{"id": "gauss", "name": "高斯的面纱", "desc": "商店价格 -8%，幸运 +8", "cost": 25, "rarity": "rare"},
	{"id": "curie", "name": "居里夫人的放射源", "desc": "热膨胀伤害 +25%，但受伤 +8%", "cost": 28, "rarity": "rare"},
	{"id": "watch", "name": "爱因斯坦的怀表", "desc": "所有法则冷却 -14%", "cost": 34, "rarity": "epic"},
	{"id": "riemann", "name": "薛定谔的手稿", "desc": "升级奖励高品质概率大幅提高", "cost": 36, "rarity": "epic"},
	{"id": "shop_shelf", "name": "周期陈列架", "desc": "商店商品位置 +1（每局最多 3 个）", "cost": 32, "rarity": "epic", "max_stacks": 3},
	{"id": "noether", "name": "诺特的对称", "desc": "每拥有 1 个法则武器，伤害 +6%", "cost": 42, "rarity": "legendary"},
	{"id": "unified_force", "name": "四大力统一", "desc": "所有属性 +10%，幸运 +15", "cost": 55, "rarity": "legendary"},
	{"id": "hilbert_rack", "name": "泡利法则武器架", "desc": "本局武器槽位 +1", "cost": 60, "rarity": "legendary"},
]

const META_EQUIPMENT := {
	"惯性靴": {"desc": "开局移速 +8%", "cost": 0},
	"守恒核心": {"desc": "开局法则伤害 +10%", "cost": 120},
	"真理电容": {"desc": "开局冷却 -8%", "cost": 160},
	"幸运棱镜": {"desc": "开局幸运 +12，商店更容易出现高稀有度道具", "cost": 140},
	"奖状夹": {"desc": "通关和失败结算奖状 +15%", "cost": 180},
	"磁场背包": {"desc": "开局拾取范围 +25%", "cost": 110},
	"防撞圆壳": {"desc": "开局护甲 +3", "cost": 130},
	"再生公式": {"desc": "开局每秒回复 +0.35", "cost": 150},
}

const RARITY_COLOR := {
	"common": Color(0.82, 0.88, 0.95),
	"rare": Color(0.35, 0.65, 1.0),
	"epic": Color(0.82, 0.45, 1.0),
	"legendary": Color(1.0, 0.72, 0.22),
}

const RARITY_LABEL := {
	"common": "普通",
	"rare": "稀有",
	"epic": "史诗",
	"legendary": "传说",
}

const RARITY_COST_MULTIPLIER := {
	"common": 1.0,
	"rare": 1.65,
	"epic": 2.55,
	"legendary": 4.0,
}

const SHOP_STAT_POOL := [
	{"id": "shop_hp", "name": "质量补习", "stat": "hp", "base_value": 10.0, "base_cost": 10, "desc": "本局最大生命提升。"},
	{"id": "shop_speed", "name": "惯性调校", "stat": "speed", "base_value": 0.045, "base_cost": 12, "desc": "本局移动速度提升。"},
	{"id": "shop_damage", "name": "法则校准", "stat": "damage", "base_value": 0.065, "base_cost": 14, "desc": "本局法则伤害提升。"},
	{"id": "shop_cooldown", "name": "推导捷径", "stat": "cooldown", "base_value": 0.04, "base_cost": 14, "desc": "本局法则冷却降低。"},
	{"id": "shop_luck", "name": "概率祝福", "stat": "luck", "base_value": 5.0, "base_cost": 13, "desc": "本局幸运提升，影响后续商店品质。"},
	{"id": "shop_pickup", "name": "感知扩张", "stat": "pickup", "base_value": 0.12, "base_cost": 10, "desc": "本局拾取范围提升。"},
	{"id": "shop_income", "name": "奖币演算", "stat": "income", "base_value": 0.045, "base_cost": 12, "desc": "本局击杀额外知识币概率提升。"},
	{"id": "shop_armor", "name": "防撞涂层", "stat": "armor", "base_value": 1.5, "base_cost": 13, "desc": "本局护甲提升。"},
	{"id": "shop_regen", "name": "再生推论", "stat": "regen", "base_value": 0.16, "base_cost": 13, "desc": "本局每秒回复提升。"},
]

const SHOP_STAT_QUALITY := {
	"common": {"value": 1.0, "label": "普通"},
	"rare": {"value": 1.65, "label": "稀有"},
	"epic": {"value": 2.45, "label": "史诗"},
	"legendary": {"value": 3.8, "label": "传说"},
}

const DIFFICULTIES := [
	{"id": "easy", "name": "求知", "desc": "适合熟悉机制。敌人生命/伤害 -15%，奖状 -10%。", "enemy": 0.85, "damage": 0.85, "reward": 0.9},
	{"id": "normal", "name": "标准", "desc": "推荐体验。标准敌人与奖励。", "enemy": 1.0, "damage": 1.0, "reward": 1.0},
	{"id": "hard", "name": "答辩", "desc": "敌人生命/伤害 +25%，奖状 +20%。", "enemy": 1.25, "damage": 1.25, "reward": 1.2},
	{"id": "chaos", "name": "混沌", "desc": "高压挑战。敌人生命/伤害 +55%，奖状 +45%。", "enemy": 1.55, "damage": 1.55, "reward": 1.45},
]

const LAW_LINKS := {
	"angular_momentum|gravity": {
		"name": "角动量坍缩",
		"desc": "引力场会追加切向加速，敌人螺旋坍缩并受到体型相关的撕裂伤害。",
	},
	"entropy|thermal_conduction": {
		"name": "热寂",
		"desc": "释放热传导时引爆全场熵层，熵越高，追加的热寂伤害越强。",
	},
	"gravity|momentum": {
		"name": "轨道加速",
		"desc": "动量弹球命中引力场内敌人时伤害 +60%，且弹射次数 +1。",
	},
	"friction|gravity": {
		"name": "轨道衰变",
		"desc": "引力场内叠加摩擦耗散，敌人被吸入时额外减速并持续受热。",
	},
	"gravity|thermal_expansion": {
		"name": "坍缩热爆",
		"desc": "热膨胀若在引力场附近爆发，伤害 +35%，范围内敌人先被拉向爆心。",
	},
	"friction|momentum": {
		"name": "摩擦生热",
		"desc": "动量弹球穿过摩擦光环后变成灼热弹，下一次命中伤害 +35%。",
	},
	"friction|thermal_expansion": {
		"name": "热阻尼",
		"desc": "热膨胀命中摩擦光环内敌人时额外施加减速，并追加一次摩擦伤害。",
	},
	"momentum|thermal_expansion": {
		"name": "冲击波反弹",
		"desc": "热膨胀爆发会重定向附近动量弹球，并使其下一击伤害 +50%。",
	},
	"lorentz|ohm": {
		"name": "电磁炮",
		"desc": "欧姆定律建立加速轨道，洛伦兹力约束弹丸贯穿整条路径并逐次增伤。",
	},
}

var save: Node = preload("res://scripts/save_data.gd").new()
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var player: Dictionary = {
	"pos": Vector2.ZERO,
	"vel": Vector2.ZERO,
	"hp": 120.0,
	"max_hp": 120.0,
	"speed": 310.0,
	"damage": 1.0,
	"cooldown": 1.0,
	"pickup": 1.0,
	"luck": 0.0,
	"armor": 0.0,
	"regen": 0.0,
	"income": 0.0,
}
var enemies: Array = []
var spawn_warnings: Array = []
var xp_orbs: Array = []
var fields: Array = []
var projectiles: Array = []
var beams: Array = []
var float_texts: Array = []
var weapons: Dictionary = {}
var weapon_backpack: Dictionary = {}
var owned_items: Array = []
var item_counts: Dictionary = {}
var wave := 1
var wave_time := WAVE_DURATION
var spawn_timer := 0.0
var level := 1
var xp := 0
var pending_level_choices := 0
var money := 0
var kills := 0
var academic_stage_index := -1
var physics_specialization_multiplier := 1.0
var exam_active := false
var exam_passed := false
var exam_overtime_notice := false
var current_exam_name := ""
var enemy_uid_counter := 0
var game_state := "meta"
var shop_offers: Array = []
var shop_locks: Array = []
var shop_refresh_count := 0
var shop_slot_bonus := 0
var weapon_slot_bonus := 0
var shop_inventory_scroll := 0
var shop_inventory_rect := Rect2()
var level_offers: Array = []
var buttons: Array = []
var message := "局外成长：使用奖状升级属性或局外装备。"
var notice_visible := false
var notice_title := "提示"
var notice_text := ""
var notice_confirm_rect := Rect2()
var meta_screen := "home"
var selected_difficulty := 1
var settings := {"show_warnings": true, "show_reaction_text": true}
var codex_selected_link := "gravity|momentum"

func _ready() -> void:
	rng.randomize()
	add_child(save)
	save.load_game()
	_apply_meta_stats()
	set_process(true)

func _process(delta: float) -> void:
	buttons.clear()
	if game_state == "playing":
		_update_playing(delta)
	queue_redraw()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN].has(event.button_index):
		var wheel_mouse_pos := get_global_mouse_position()
		if notice_visible:
			get_viewport().set_input_as_handled()
			return
		if game_state == "shop" and shop_inventory_rect.has_point(wheel_mouse_pos):
			_scroll_shop_inventory(-1 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 1)
			get_viewport().set_input_as_handled()
			return
	if event is InputEventPanGesture:
		var pan_mouse_pos := get_global_mouse_position()
		if game_state == "shop" and not notice_visible and shop_inventory_rect.has_point(pan_mouse_pos):
			_scroll_shop_inventory(1 if event.delta.y > 0.0 else -1)
			get_viewport().set_input_as_handled()
			return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos := get_global_mouse_position()
		if notice_visible:
			if notice_confirm_rect.has_point(mouse_pos):
				_dismiss_notice()
			get_viewport().set_input_as_handled()
			return
		for button: Dictionary in buttons:
			if button["rect"].has_point(mouse_pos):
				button["callback"].call()
				get_viewport().set_input_as_handled()
				return
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if notice_visible:
			_dismiss_notice()
			get_viewport().set_input_as_handled()
			return
		if game_state != "meta":
			_end_run(false)

func _start_run() -> void:
	_dismiss_notice()
	player = {
		"pos": Vector2.ZERO,
		"vel": Vector2.ZERO,
		"hp": 120.0,
		"max_hp": 120.0,
		"speed": 310.0,
		"damage": 1.0,
		"cooldown": 1.0,
		"pickup": 1.0,
		"luck": 0.0,
		"armor": 0.0,
		"regen": 0.0,
		"income": 0.0,
	}
	_apply_meta_stats()
	enemies.clear()
	spawn_warnings.clear()
	xp_orbs.clear()
	fields.clear()
	projectiles.clear()
	beams.clear()
	float_texts.clear()
	weapons = {
		"gravity": {"level": 1, "timer": 1.0},
		"momentum": {"level": 1, "timer": 1.8},
	}
	weapon_backpack.clear()
	owned_items.clear()
	item_counts.clear()
	shop_offers.clear()
	shop_locks.clear()
	shop_refresh_count = 0
	shop_slot_bonus = 0
	weapon_slot_bonus = 0
	shop_inventory_scroll = 0
	shop_inventory_rect = Rect2()
	wave = 1
	wave_time = WAVE_DURATION
	spawn_timer = 0.0
	level = 1
	xp = 0
	pending_level_choices = 0
	money = 12
	kills = 0
	academic_stage_index = -1
	physics_specialization_multiplier = 1.0
	exam_active = false
	exam_passed = false
	exam_overtime_notice = false
	current_exam_name = ""
	enemy_uid_counter = 0
	_update_academic_stage(false)
	message = "第 1/12 小关开始。存活 45 秒后进入升级奖励与商店。"
	game_state = "playing"

func _apply_meta_stats() -> void:
	player["max_hp"] += int(save.stats.get("max_hp", 0)) * 8
	player["hp"] = min(player["hp"] + int(save.stats.get("max_hp", 0)) * 8, player["max_hp"])
	player["speed"] *= 1.0 + float(save.stats.get("move_speed", 0)) * 0.035
	player["damage"] *= 1.0 + float(save.stats.get("damage", 0)) * 0.05
	player["cooldown"] *= max(0.6, 1.0 - float(save.stats.get("cooldown", 0)) * 0.035)
	player["luck"] += float(save.stats.get("luck", 0)) * 3.0
	player["pickup"] *= 1.0 + float(save.stats.get("pickup", 0)) * 0.08
	player["income"] += float(save.stats.get("income", 0)) * 0.04
	player["armor"] += float(save.stats.get("armor", 0)) * 1.0
	player["regen"] += float(save.stats.get("regen", 0)) * 0.12
	if save.equipped.has("惯性靴"):
		player["speed"] *= 1.08
	if save.equipped.has("守恒核心"):
		player["damage"] *= 1.1
	if save.equipped.has("真理电容"):
		player["cooldown"] *= 0.92
	if save.equipped.has("幸运棱镜"):
		player["luck"] += 12.0
	if save.equipped.has("磁场背包"):
		player["pickup"] *= 1.25
	if save.equipped.has("防撞圆壳"):
		player["armor"] += 3.0
	if save.equipped.has("再生公式"):
		player["regen"] += 0.35

func _update_playing(delta: float) -> void:
	wave_time = max(0.0, wave_time - delta)
	if wave_time <= 0.0:
		if exam_active and not exam_passed:
			if not exam_overtime_notice:
				exam_overtime_notice = true
				message = "考试时间结束，但必须击败“%s”才能结算本关。" % _current_exam_boss_name()
		else:
			_enter_level_up_or_shop()
			return
	player["hp"] = min(float(player["max_hp"]), float(player["hp"]) + float(player["regen"]) * delta)
	_update_player(delta)
	_update_spawning(delta)
	_update_spawn_warnings(delta)
	_update_weapons(delta)
	_update_fields(delta)
	_update_projectiles(delta)
	_update_beams(delta)
	_update_enemies(delta)
	_update_pickups(delta)
	_update_float_texts(delta)
	if player["hp"] <= 0.0:
		_end_run(false)

func _update_player(delta: float) -> void:
	var input: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	player["vel"] = input * float(player["speed"])
	player["pos"] += player["vel"] * delta
	player["pos"].x = clamp(player["pos"].x, -ARENA_SIZE.x * 0.5, ARENA_SIZE.x * 0.5)
	player["pos"].y = clamp(player["pos"].y, -ARENA_SIZE.y * 0.5, ARENA_SIZE.y * 0.5)

func _update_spawning(delta: float) -> void:
	spawn_timer -= delta
	if spawn_timer > 0.0:
		return
	spawn_timer = max(0.12, 0.78 - wave * 0.055)
	var count := 1 + int(wave / 4)
	for i in count:
		_queue_enemy_spawn()

func _queue_enemy_spawn() -> void:
	spawn_warnings.append({
		"pos": _random_spawn_position(),
		"time": SPAWN_WARNING_TIME,
		"duration": SPAWN_WARNING_TIME,
	})

func _update_spawn_warnings(delta: float) -> void:
	for i in range(spawn_warnings.size() - 1, -1, -1):
		var warning: Dictionary = spawn_warnings[i]
		warning["time"] -= delta
		if warning["time"] <= 0.0:
			_spawn_enemy(warning["pos"])
			spawn_warnings.remove_at(i)
		else:
			spawn_warnings[i] = warning

func _random_spawn_position() -> Vector2:
	var half_size: Vector2 = ARENA_SIZE * 0.5
	var min_pos: Vector2 = -half_size + Vector2(SPAWN_EDGE_PADDING, SPAWN_EDGE_PADDING)
	var max_pos: Vector2 = half_size - Vector2(SPAWN_EDGE_PADDING, SPAWN_EDGE_PADDING)
	var pos: Vector2 = Vector2.ZERO
	for attempt in 8:
		pos = Vector2(rng.randf_range(min_pos.x, max_pos.x), rng.randf_range(min_pos.y, max_pos.y))
		if pos.distance_to(player["pos"]) >= 260.0:
			return pos
	return pos

func _spawn_enemy(spawn_pos: Vector2) -> void:
	var type_roll := rng.randf()
	var difficulty: Dictionary = DIFFICULTIES[selected_difficulty]
	var hp_value: float = (34.0 + wave * 8.0) * float(difficulty["enemy"])
	var speed_value: float = 105.0 + wave * 5.0
	var shape := "triangle"
	var color := Color(0.95, 0.25, 0.22)
	var radius := 18.0
	if type_roll > 0.72:
		shape = "square"
		color = Color(0.2, 0.85, 0.35)
		hp_value *= 1.8
		speed_value *= 0.72
		radius = 24.0
	elif type_roll > 0.42:
		shape = "diamond"
		color = Color(0.35, 0.65, 1.0)
		speed_value *= 1.25
		radius = 16.0
	enemies.append({
		"uid": _next_enemy_uid(),
		"pos": _clamp_to_arena(spawn_pos, radius),
		"vel": Vector2.ZERO,
		"hp": hp_value,
		"max_hp": hp_value,
		"speed": speed_value,
		"radius": radius,
		"shape": shape,
		"color": color,
		"hit_cd": 0.0,
		"entropy": 0,
		"burn_time": 0.0,
		"burn_tick": 0.5,
		"burn_damage": 0.0,
		"burn_generation": 0,
		"burn_spread_done": false,
		"boss": false,
	})

func _clamp_to_arena(pos: Vector2, padding: float = SPAWN_EDGE_PADDING) -> Vector2:
	var half_size: Vector2 = ARENA_SIZE * 0.5
	return Vector2(
		clamp(pos.x, -half_size.x + padding, half_size.x - padding),
		clamp(pos.y, -half_size.y + padding, half_size.y - padding)
	)

func _update_weapons(delta: float) -> void:
	if weapons.has("friction"):
		_apply_friction(delta, int(weapons["friction"]["level"]))
	if weapons.has("angular_momentum"):
		_apply_angular_momentum(delta, int(weapons["angular_momentum"]["level"]))
	if weapons.has("entropy"):
		_update_entropy_weapon(delta, int(weapons["entropy"]["level"]))
	for id in weapons.keys():
		if ["friction", "angular_momentum", "entropy"].has(id):
			continue
		weapons[id]["timer"] -= delta
		if weapons[id]["timer"] <= 0.0:
			_fire_weapon(id, int(weapons[id]["level"]))
			weapons[id]["timer"] = _weapon_cooldown(id, int(weapons[id]["level"]))

func _weapon_cooldown(id: String, weapon_level: int) -> float:
	var base: float = {
		"gravity": 5.2,
		"momentum": 1.45,
		"thermal_expansion": 4.2,
		"ohm": 3.1,
		"lorentz": 1.9,
		"thermal_conduction": 3.6,
	}.get(id, 3.0)
	if owned_items.has("watch"):
		base *= 0.86
	if owned_items.has("maxwell"):
		base *= 0.92
	if academic_stage_index >= 6 and _weapon_has_active_fusion(id):
		base *= 0.85
	return base * float(player["cooldown"]) * max(0.55, 1.0 - (weapon_level - 1) * 0.07)

func _fire_weapon(id: String, weapon_level: int) -> void:
	if id == "gravity":
		var center: Vector2 = _enemy_cluster_pos()
		var radius: float = 185.0 + weapon_level * 18.0
		if owned_items.has("apple"):
			radius *= 1.3
		if owned_items.has("unified_force"):
			radius *= 1.1
		fields.append({"kind": "gravity", "pos": center, "radius": radius, "life": 3.4 + weapon_level * 0.25, "level": weapon_level})
	elif id == "momentum":
		var target: int = _nearest_enemy(player["pos"])
		if target >= 0:
			var dir: Vector2 = (enemies[target]["pos"] - player["pos"]).normalized()
			var projectile_damage: float = 24.0 + weapon_level * 8.0
			if owned_items.has("unified_force"):
				projectile_damage *= 1.1
			projectiles.append({"kind": "momentum", "pos": player["pos"], "vel": dir * 620.0, "damage": projectile_damage, "radius": 8.0, "bounces": 3 + weapon_level / 2 + (1 if owned_items.has("lagrange") else 0), "hit": [], "heated": false, "life": 5.0})
	elif id == "thermal_expansion":
		var center2: Vector2 = _enemy_cluster_pos()
		var thermal_radius: float = 160.0 + weapon_level * 16.0
		if owned_items.has("mendeleev"):
			thermal_radius *= 1.2
		fields.append({"kind": "thermal", "pos": center2, "radius": thermal_radius, "life": 0.55, "level": weapon_level, "done": false})
	elif id == "ohm":
		_fire_ohm_chain(weapon_level)
	elif id == "lorentz":
		_fire_lorentz_particle(weapon_level)
	elif id == "thermal_conduction":
		_fire_thermal_conduction(weapon_level)

func _apply_friction(delta: float, weapon_level: int) -> void:
	var radius: float = 170.0 + weapon_level * 16.0
	for enemy: Dictionary in enemies:
		var dist: float = enemy["pos"].distance_to(player["pos"])
		if dist <= radius:
			enemy["vel"] *= 0.78
			var dmg: float = enemy["vel"].length() * (0.014 + weapon_level * 0.003) * float(player["damage"])
			_damage_enemy(enemy, dmg * delta * 60.0)

func _apply_angular_momentum(delta: float, weapon_level: int) -> void:
	var radius: float = 145.0 + weapon_level * 18.0
	var angular_force: float = 430.0 + weapon_level * 65.0
	for enemy: Dictionary in enemies:
		var offset: Vector2 = enemy["pos"] - player["pos"]
		var dist: float = max(1.0, offset.length())
		if dist > radius:
			continue
		var tangent := Vector2(-offset.y, offset.x).normalized()
		var outward := offset.normalized()
		var proximity: float = 1.0 - dist / radius
		enemy["vel"] += (tangent * angular_force + outward * angular_force * 0.34) * proximity * delta
		var mass_scale: float = max(0.7, float(enemy["radius"]) / 18.0)
		_damage_enemy(enemy, (5.0 + weapon_level * 1.8) * mass_scale * float(player["damage"]) * delta)

func _update_entropy_weapon(delta: float, weapon_level: int) -> void:
	weapons["entropy"]["timer"] = float(weapons["entropy"].get("timer", 0.1)) - delta
	if float(weapons["entropy"]["timer"]) > 0.0:
		return
	var layer_gain: int = 1 + int(weapon_level >= 4)
	for enemy: Dictionary in enemies:
		enemy["entropy"] = int(enemy.get("entropy", 0)) + layer_gain
		_add_float_text(enemy["pos"], "熵 +%d" % layer_gain, Color(0.72, 0.84, 1.0))
	weapons["entropy"]["timer"] = max(0.8, 2.2 - weapon_level * 0.16) * float(player["cooldown"])

func _fire_ohm_chain(weapon_level: int) -> void:
	if enemies.is_empty():
		return
	var chain: Array = []
	var excluded: Array = []
	var cursor: Vector2 = player["pos"]
	var max_targets: int = min(enemies.size(), 3 + weapon_level)
	for step in max_targets:
		var target_index: int = _nearest_enemy(cursor, excluded)
		if target_index < 0:
			break
		excluded.append(target_index)
		chain.append(enemies[target_index])
		cursor = enemies[target_index]["pos"]
	var points: Array = [player["pos"]]
	var voltage_damage: float = (48.0 + weapon_level * 13.0) * float(player["damage"])
	for i in chain.size():
		var enemy: Dictionary = chain[i]
		points.append(enemy["pos"])
		_damage_enemy(enemy, voltage_damage * pow(0.82, i))
	beams.append({"points": points, "life": 0.22, "color": Color(0.25, 0.85, 1.0), "width": 4.0})
	if weapons.has("lorentz"):
		_fire_electromagnetic_railgun(weapon_level)

func _fire_lorentz_particle(weapon_level: int) -> void:
	var target: int = _nearest_enemy(player["pos"])
	if target < 0:
		return
	var dir: Vector2 = (enemies[target]["pos"] - player["pos"]).normalized()
	projectiles.append({
		"kind": "lorentz",
		"pos": player["pos"],
		"vel": dir * (520.0 + weapon_level * 35.0),
		"damage": 22.0 + weapon_level * 9.0,
		"radius": 7.0,
		"bounces": 0,
		"pierces": 1 + weapon_level / 2,
		"hit": [],
		"heated": false,
		"field_hits": [],
		"life": 4.5,
	})

func _fire_thermal_conduction(weapon_level: int) -> void:
	var target: int = _nearest_enemy(player["pos"])
	if target < 0:
		return
	_apply_burn(enemies[target], 12.0 + weapon_level * 5.0, 4.0 + weapon_level * 0.3, 0)
	_add_float_text(enemies[target]["pos"], "热传导", Color(1.0, 0.52, 0.15))
	if weapons.has("entropy"):
		var heat_death_damage: float = 0.0
		for enemy: Dictionary in enemies:
			var layers: int = int(enemy.get("entropy", 0))
			if layers <= 0:
				continue
			var damage: float = layers * (2.2 + weapon_level * 0.65) * float(player["damage"])
			_damage_enemy(enemy, damage)
			heat_death_damage += damage
		if heat_death_damage > 0.0:
			_add_float_text(player["pos"], "热寂", Color(0.82, 0.72, 1.0))

func _fire_electromagnetic_railgun(weapon_level: int) -> void:
	var target: int = _nearest_enemy(player["pos"])
	if target < 0:
		return
	var direction: Vector2 = (enemies[target]["pos"] - player["pos"]).normalized()
	var end: Vector2 = player["pos"] + direction * 1300.0
	var hits: Array = []
	for enemy: Dictionary in enemies:
		var projection: float = clamp((enemy["pos"] - player["pos"]).dot(direction), 0.0, 1300.0)
		var closest: Vector2 = player["pos"] + direction * projection
		if projection > 0.0 and enemy["pos"].distance_to(closest) <= float(enemy["radius"]) + 20.0:
			hits.append({"enemy": enemy, "distance": projection})
	hits.sort_custom(func(a: Dictionary, b: Dictionary): return float(a["distance"]) < float(b["distance"]))
	for i in hits.size():
		var hit: Dictionary = hits[i]
		_damage_enemy(hit["enemy"], (34.0 + weapon_level * 10.0) * (1.0 + i * 0.18) * float(player["damage"]))
	beams.append({"points": [player["pos"], end], "life": 0.16, "color": Color(0.95, 0.98, 1.0), "width": 8.0})
	_add_float_text(player["pos"] + direction * 80.0, "电磁炮", Color(0.55, 0.9, 1.0))

func _apply_burn(enemy: Dictionary, damage: float, duration: float, generation: int) -> void:
	if float(enemy.get("burn_time", 0.0)) > 0.0 and float(enemy.get("burn_damage", 0.0)) >= damage:
		enemy["burn_time"] = max(float(enemy["burn_time"]), duration)
		return
	enemy["burn_time"] = duration
	enemy["burn_tick"] = 0.2
	enemy["burn_damage"] = damage
	enemy["burn_generation"] = generation
	enemy["burn_spread_done"] = false

func _update_fields(delta: float) -> void:
	for i in range(fields.size() - 1, -1, -1):
		var field: Dictionary = fields[i]
		field["life"] -= delta
		if field["kind"] == "gravity":
			for enemy: Dictionary in enemies:
				var offset: Vector2 = field["pos"] - enemy["pos"]
				var dist: float = max(12.0, offset.length())
				if dist <= field["radius"]:
					var force: Vector2 = offset.normalized() * (560.0 + int(field["level"]) * 90.0) * (1.0 - dist / float(field["radius"]))
					enemy["vel"] += force * delta
					var dmg_scale: float = 1.18 if owned_items.has("field_notes") else 1.0
					if weapons.has("angular_momentum"):
						var radial: Vector2 = enemy["pos"] - field["pos"]
						var tangent := Vector2(-radial.y, radial.x).normalized()
						enemy["vel"] += tangent * (410.0 + int(weapons["angular_momentum"]["level"]) * 55.0) * delta
						dmg_scale *= 1.22
						_damage_enemy(enemy, float(enemy["radius"]) * 0.13 * float(player["damage"]) * delta)
					if weapons.has("friction"):
						enemy["vel"] *= 0.92
						dmg_scale *= 1.18
					if owned_items.has("unified_force"):
						dmg_scale *= 1.1
					_damage_enemy(enemy, (7.0 + int(field["level"]) * 2.6) * dmg_scale * float(player["damage"]) * delta)
		elif field["kind"] == "thermal" and not bool(field["done"]):
			field["done"] = true
			var gravity_linked: bool = _has_field_near("gravity", field["pos"], float(field["radius"]) + 130.0)
			if gravity_linked and weapons.has("gravity"):
				for enemy: Dictionary in enemies:
					if enemy["pos"].distance_to(field["pos"]) <= float(field["radius"]) + 130.0:
						enemy["pos"] = enemy["pos"].move_toward(field["pos"], 55.0)
			if weapons.has("momentum"):
				_boost_projectiles_near(field["pos"], float(field["radius"]) + 180.0, field["pos"])
			for enemy: Dictionary in enemies:
				var offset2: Vector2 = enemy["pos"] - field["pos"]
				var dist2: float = max(1.0, offset2.length())
				if dist2 <= field["radius"]:
					var t: float = 1.0 - dist2 / float(field["radius"])
					enemy["vel"] += offset2.normalized() * (460.0 + int(field["level"]) * 80.0) * t
					var thermal_damage_scale: float = 1.0
					if owned_items.has("mendeleev"):
						thermal_damage_scale *= 1.1
					if owned_items.has("curie"):
						thermal_damage_scale *= 1.25
					if owned_items.has("unified_force"):
						thermal_damage_scale *= 1.1
					if gravity_linked and weapons.has("gravity"):
						thermal_damage_scale *= 1.35
					if weapons.has("friction") and enemy["pos"].distance_to(player["pos"]) <= _friction_radius():
						enemy["vel"] *= 0.55
						thermal_damage_scale *= 1.16
					_damage_enemy(enemy, (28.0 + int(field["level"]) * 12.0) * t * thermal_damage_scale * float(player["damage"]))
		if field["life"] <= 0.0:
			fields.remove_at(i)
		else:
			fields[i] = field

func _update_projectiles(delta: float) -> void:
	for i in range(projectiles.size() - 1, -1, -1):
		var p: Dictionary = projectiles[i]
		p["life"] = float(p.get("life", 5.0)) - delta
		if p["life"] <= 0.0:
			projectiles.remove_at(i)
			continue
		if p.get("kind", "momentum") == "lorentz":
			for field: Dictionary in fields:
				if not ["gravity", "thermal"].has(field["kind"]):
					continue
				if p["field_hits"].has(field["kind"]):
					continue
				if p["pos"].distance_to(field["pos"]) > float(field["radius"]):
					continue
				var offset: Vector2 = field["pos"] - p["pos"]
				var turn_sign: float = -1.0 if field["kind"] == "gravity" else 1.0
				var perpendicular := Vector2(-p["vel"].y, p["vel"].x).normalized() * turn_sign
				p["vel"] = (p["vel"] + perpendicular * p["vel"].length() * 0.38 + offset.normalized() * 90.0).normalized() * p["vel"].length() * 1.12
				p["damage"] *= 1.7
				p["field_hits"].append(field["kind"])
				_add_float_text(p["pos"], "洛伦兹偏转", Color(0.35, 0.9, 1.0))
		p["pos"] += p["vel"] * delta
		var removed := false
		for enemy_index in enemies.size():
			var enemy: Dictionary = enemies[enemy_index]
			var enemy_uid: int = int(enemy.get("uid", enemy_index))
			if p["hit"].has(enemy_uid):
				continue
			if p["pos"].distance_to(enemy["pos"]) <= float(p["radius"]) + float(enemy["radius"]):
				if p.get("kind", "momentum") == "lorentz":
					_damage_enemy(enemy, float(p["damage"]) * float(player["damage"]))
					p["hit"].append(enemy_uid)
					p["pierces"] -= 1
					if p["pierces"] < 0:
						projectiles.remove_at(i)
						removed = true
					else:
						p["vel"] = p["vel"].rotated(rng.randf_range(-0.2, 0.2))
					break
				var damage_scale: float = 1.0
				if weapons.has("gravity") and _is_point_in_field(enemy["pos"], "gravity"):
					damage_scale *= 1.6
					p["bounces"] += 1
					_add_float_text(enemy["pos"], "轨道加速", Color(0.72, 0.62, 1.0))
				if bool(p.get("heated", false)):
					damage_scale *= 1.35
					p["heated"] = false
					_add_float_text(enemy["pos"], "摩擦生热", Color(1.0, 0.55, 0.18))
				_damage_enemy(enemy, float(p["damage"]) * float(player["damage"]) * damage_scale)
				p["hit"].append(enemy_uid)
				p["damage"] *= 1.22
				p["bounces"] -= 1
				if p["bounces"] < 0:
					projectiles.remove_at(i)
					removed = true
				else:
					var next: int = _nearest_enemy_excluding_uids(p["pos"], p["hit"])
					if next >= 0:
						p["vel"] = (enemies[next]["pos"] - p["pos"]).normalized() * p["vel"].length()
					else:
						p["vel"] = p["vel"].bounce(Vector2.RIGHT.rotated(rng.randf_range(0, TAU)))
				break
		if removed:
			continue
		if p["pos"].distance_to(player["pos"]) > 1300.0:
			projectiles.remove_at(i)
		else:
			if weapons.has("friction") and p["pos"].distance_to(player["pos"]) <= _friction_radius():
				p["heated"] = true
			projectiles[i] = p

func _update_beams(delta: float) -> void:
	for i in range(beams.size() - 1, -1, -1):
		beams[i]["life"] -= delta
		if beams[i]["life"] <= 0.0:
			beams.remove_at(i)

func _update_enemies(delta: float) -> void:
	for i in range(enemies.size() - 1, -1, -1):
		var enemy: Dictionary = enemies[i]
		_update_enemy_status(enemy, i, delta)
		if bool(enemy.get("boss", false)):
			_update_exam_boss_ability(enemy, delta)
		var dir: Vector2 = (player["pos"] - enemy["pos"]).normalized()
		enemy["vel"] = enemy["vel"].move_toward(dir * float(enemy["speed"]), float(enemy["speed"]) * 2.8 * delta)
		enemy["pos"] += enemy["vel"] * delta
		enemy["hit_cd"] = max(0.0, float(enemy["hit_cd"]) - delta)
		if enemy["pos"].distance_to(player["pos"]) <= float(enemy["radius"]) + PLAYER_RADIUS and float(enemy["hit_cd"]) <= 0.0:
			var difficulty: Dictionary = DIFFICULTIES[selected_difficulty]
			var incoming: float = (10.0 + wave * 1.5) * float(difficulty["damage"])
			incoming *= 1.08 if owned_items.has("curie") else 1.0
			player["hp"] -= max(1.0, incoming - float(player["armor"]) * 0.9)
			enemy["hit_cd"] = 0.7
			enemy["vel"] -= dir * 260.0
		if enemy["hp"] <= 0.0:
			_kill_enemy(enemy)
			enemies.remove_at(i)
		else:
			enemies[i] = enemy

func _update_enemy_status(enemy: Dictionary, enemy_index: int, delta: float) -> void:
	if float(enemy.get("burn_time", 0.0)) <= 0.0:
		return
	enemy["burn_time"] -= delta
	enemy["burn_tick"] = float(enemy.get("burn_tick", 0.5)) - delta
	if float(enemy["burn_tick"]) > 0.0:
		return
	enemy["burn_tick"] = 0.5
	_damage_enemy(enemy, float(enemy["burn_damage"]) * 0.5 * float(player["damage"]))
	var generation: int = int(enemy.get("burn_generation", 0))
	var max_generation: int = 2
	if weapons.has("thermal_conduction"):
		max_generation += int(weapons["thermal_conduction"]["level"]) / 2
	if bool(enemy.get("burn_spread_done", false)) or generation >= max_generation:
		return
	var target: int = _nearest_enemy(enemy["pos"], [enemy_index])
	if target >= 0 and enemies[target]["pos"].distance_to(enemy["pos"]) <= 190.0:
		_apply_burn(enemies[target], float(enemy["burn_damage"]) * 0.78, max(1.5, float(enemy["burn_time"]) * 0.85), generation + 1)
		enemy["burn_spread_done"] = true
		beams.append({"points": [enemy["pos"], enemies[target]["pos"]], "life": 0.18, "color": Color(1.0, 0.42, 0.12), "width": 3.0})

func _update_exam_boss_ability(enemy: Dictionary, delta: float) -> void:
	enemy["ability_timer"] = float(enemy.get("ability_timer", 2.0)) - delta
	if float(enemy["ability_timer"]) > 0.0:
		return
	var kind: String = enemy.get("boss_kind", "mechanics")
	var distance: float = enemy["pos"].distance_to(player["pos"])
	var difficulty: Dictionary = DIFFICULTIES[selected_difficulty]
	var ability_damage: float = (7.0 + wave * 0.9) * float(difficulty["damage"])
	match kind:
		"mechanics":
			player["pos"] = player["pos"].move_toward(enemy["pos"], 95.0)
			if distance <= 190.0:
				player["hp"] -= max(1.0, ability_damage - float(player["armor"]) * 0.55)
			fields.append({"kind": "exam_gravity", "pos": enemy["pos"], "radius": 230.0, "life": 0.45, "level": 1})
			enemy["ability_timer"] = 2.6
		"electromagnetism":
			beams.append({"points": [enemy["pos"], player["pos"]], "life": 0.3, "color": Color(0.2, 0.85, 1.0), "width": 6.0})
			if distance <= 560.0:
				player["hp"] -= max(1.0, ability_damage * 1.15 - float(player["armor"]) * 0.6)
			enemy["ability_timer"] = 2.9
		"thermodynamics":
			fields.append({"kind": "exam_thermal", "pos": enemy["pos"], "radius": 340.0, "life": 0.65, "level": 1})
			if distance <= 340.0:
				player["hp"] -= max(1.0, ability_damage * 1.25 - float(player["armor"]) * 0.5)
			enemy["ability_timer"] = 3.1
		"unified_field":
			enemy["boss_phase"] = int(enemy.get("boss_phase", 0)) + 1
			if int(enemy["boss_phase"]) % 2 == 0:
				player["pos"] = player["pos"].move_toward(enemy["pos"], 120.0)
				fields.append({"kind": "exam_gravity", "pos": enemy["pos"], "radius": 300.0, "life": 0.55, "level": 1})
			else:
				beams.append({"points": [enemy["pos"], player["pos"]], "life": 0.32, "color": Color(0.78, 0.56, 1.0), "width": 8.0})
				if distance <= 620.0:
					player["hp"] -= max(1.0, ability_damage * 1.35 - float(player["armor"]) * 0.55)
			enemy["ability_timer"] = 2.35

func _kill_enemy(enemy: Dictionary) -> void:
	kills += 1
	var bonus_chance: float = 0.22 + float(player["income"]) + float(player["luck"]) * 0.002
	if owned_items.has("darwin"):
		bonus_chance += 0.12
	money += 1 + int(rng.randf() < bonus_chance)
	xp_orbs.append({"pos": enemy["pos"], "value": 1 + int(enemy["max_hp"] > 70.0)})
	_add_float_text(enemy["pos"], "+知识", Color(0.7, 0.95, 1.0))
	if bool(enemy.get("boss", false)):
		_complete_exam(enemy)

func _add_float_text(pos: Vector2, text: String, color: Color) -> void:
	if not bool(settings["show_reaction_text"]) and text != "+知识":
		return
	float_texts.append({"pos": pos, "text": text, "life": 0.7, "color": color})

func _friction_radius() -> float:
	if not weapons.has("friction"):
		return 0.0
	return 170.0 + int(weapons["friction"]["level"]) * 16.0

func _is_point_in_field(pos: Vector2, kind: String) -> bool:
	for field: Dictionary in fields:
		if field["kind"] == kind and pos.distance_to(field["pos"]) <= float(field["radius"]):
			return true
	return false

func _has_field_near(kind: String, pos: Vector2, radius: float) -> bool:
	for field: Dictionary in fields:
		if field["kind"] == kind and pos.distance_to(field["pos"]) <= radius:
			return true
	return false

func _boost_projectiles_near(pos: Vector2, radius: float, target: Vector2) -> void:
	for p: Dictionary in projectiles:
		if p["pos"].distance_to(pos) <= radius:
			p["damage"] *= 1.5
			p["heated"] = true
			var dir: Vector2 = (target - p["pos"]).normalized()
			if dir.length() > 0.0:
				p["vel"] = dir * max(620.0, p["vel"].length())
			_add_float_text(p["pos"], "冲击波反弹", Color(1.0, 0.72, 0.25))

func _link_key(a: String, b: String) -> String:
	var ids: Array = [a, b]
	ids.sort()
	return "%s|%s" % [ids[0], ids[1]]

func _weapon_link_lines(candidate_id: String) -> Array:
	var lines: Array = []
	for owned_id in weapons.keys():
		if owned_id == candidate_id:
			continue
		var key: String = _link_key(candidate_id, owned_id)
		if LAW_LINKS.has(key):
			var link: Dictionary = LAW_LINKS[key]
			lines.append("联动：%s - %s" % [link["name"], link["desc"]])
	return lines

func _join_lines(lines: Array) -> String:
	var text := ""
	for i in lines.size():
		if i > 0:
			text += "\n"
		text += str(lines[i])
	return text

func _update_pickups(delta: float) -> void:
	for i in range(xp_orbs.size() - 1, -1, -1):
		var orb: Dictionary = xp_orbs[i]
		var dist: float = orb["pos"].distance_to(player["pos"])
		if dist < 44.0 * float(player["pickup"]):
			_grant_xp(int(orb["value"]))
			xp_orbs.remove_at(i)
		elif dist < 170.0 * float(player["pickup"]):
			orb["pos"] = orb["pos"].move_toward(player["pos"], 420.0 * delta)
			xp_orbs[i] = orb

func _grant_xp(amount: int) -> void:
	xp += amount
	while xp >= XP_TO_LEVEL + level * 3:
		xp -= XP_TO_LEVEL + level * 3
		level += 1
		pending_level_choices += 1
		_update_academic_stage(true)

func _update_academic_stage(announce: bool) -> void:
	while academic_stage_index + 1 < ACADEMIC_STAGES.size():
		var next_index: int = academic_stage_index + 1
		var stage: Dictionary = ACADEMIC_STAGES[next_index]
		if level < int(stage["level"]):
			break
		academic_stage_index = next_index
		_apply_academic_stage_bonus(academic_stage_index)
		if announce:
			message = "学历晋升：%s·%s，获得%s。" % [stage["name"], stage["title"], stage["bonus"]]
			_add_float_text(player["pos"], "晋升%s" % stage["name"], Color(1.0, 0.84, 0.38))

func _apply_academic_stage_bonus(stage_index: int) -> void:
	match stage_index:
		0:
			player["speed"] *= 1.05
		1:
			player["cooldown"] *= 0.9
		2:
			player["max_hp"] += 20.0
			player["hp"] += 20.0
		3:
			player["damage"] *= 1.15
		4:
			physics_specialization_multiplier *= 1.2
		5:
			player["armor"] += 4.0
			player["damage"] *= 1.12
		6:
			player["cooldown"] *= 0.85
			player["damage"] *= 1.15

func _academic_stage_name() -> String:
	if academic_stage_index < 0 or academic_stage_index >= ACADEMIC_STAGES.size():
		return "未入学"
	return str(ACADEMIC_STAGES[academic_stage_index]["name"])

func _collect_all_xp_orbs() -> void:
	var collected_xp := 0
	for orb: Dictionary in xp_orbs:
		collected_xp += int(orb["value"])
	xp_orbs.clear()
	if collected_xp > 0:
		_grant_xp(collected_xp)

func _update_float_texts(delta: float) -> void:
	for i in range(float_texts.size() - 1, -1, -1):
		float_texts[i]["life"] -= delta
		float_texts[i]["pos"].y -= 24.0 * delta
		if float_texts[i]["life"] <= 0.0:
			float_texts.remove_at(i)

func _damage_enemy(enemy: Dictionary, amount: float) -> void:
	var entropy_multiplier: float = 1.0 + float(enemy.get("entropy", 0)) * 0.05
	enemy["hp"] -= amount * entropy_multiplier * physics_specialization_multiplier

func _nearest_enemy(from: Vector2, excluded: Array = []) -> int:
	var best: int = -1
	var best_dist: float = INF
	for i in enemies.size():
		if excluded.has(i):
			continue
		var d: float = from.distance_squared_to(enemies[i]["pos"])
		if d < best_dist:
			best_dist = d
			best = i
	return best

func _nearest_enemy_excluding_uids(from: Vector2, excluded_uids: Array) -> int:
	var best: int = -1
	var best_dist: float = INF
	for i in enemies.size():
		if excluded_uids.has(int(enemies[i].get("uid", i))):
			continue
		var d: float = from.distance_squared_to(enemies[i]["pos"])
		if d < best_dist:
			best_dist = d
			best = i
	return best

func _enemy_cluster_pos() -> Vector2:
	if enemies.is_empty():
		return player["pos"] + Vector2.RIGHT.rotated(rng.randf_range(0, TAU)) * 240.0
	var sample_count: int = min(8, enemies.size())
	var center: Vector2 = Vector2.ZERO
	for i in sample_count:
		center += enemies[(i * 3 + wave) % enemies.size()]["pos"]
	return center / sample_count

func _next_enemy_uid() -> int:
	enemy_uid_counter += 1
	return enemy_uid_counter

func _weapon_has_active_fusion(weapon_id: String) -> bool:
	for key: String in LAW_LINKS.keys():
		var ids: Array = key.split("|")
		if not ids.has(weapon_id):
			continue
		if weapons.has(ids[0]) and weapons.has(ids[1]):
			return true
	return false

func _enter_level_up_or_shop() -> void:
	_collect_all_xp_orbs()
	game_state = "level_up" if pending_level_choices > 0 else "shop"
	if game_state == "level_up":
		_roll_level_offers()
		message = "小关结束：根据本关升级次数选择属性强化。剩余 %d 次。" % pending_level_choices
	else:
		_enter_shop()

func _roll_level_offers() -> void:
	var quality: float = 1.0 + min(0.65, float(player["luck"]) * 0.01)
	if owned_items.has("riemann"):
		quality += 0.35
	var all: Array = [
		{"name": "质量训练", "desc": "最大生命 +%d" % int(12 * quality), "stat": "hp", "value": 12.0 * quality},
		{"name": "惯性减免", "desc": "移动速度 +%d%%" % int(7 * quality), "stat": "speed", "value": 0.07 * quality},
		{"name": "法则共鸣", "desc": "法则伤害 +%d%%" % int(10 * quality), "stat": "damage", "value": 0.10 * quality},
		{"name": "推导熟练", "desc": "冷却 -%d%%" % int(6 * quality), "stat": "cooldown", "value": 0.06 * quality},
		{"name": "知识嗅觉", "desc": "拾取范围 +%d%%" % int(20 * quality), "stat": "pickup", "value": 0.20 * quality},
		{"name": "幸运推演", "desc": "幸运 +%d" % int(6 * quality), "stat": "luck", "value": 6.0 * quality},
		{"name": "奖币推导", "desc": "击杀额外知识币概率 +%d%%" % int(6 * quality), "stat": "income", "value": 0.06 * quality},
		{"name": "防撞曲率", "desc": "护甲 +%d" % int(2 * quality), "stat": "armor", "value": 2.0 * quality},
		{"name": "自洽再生", "desc": "每秒回复 +%.2f" % (0.22 * quality), "stat": "regen", "value": 0.22 * quality},
	]
	all.shuffle()
	level_offers = all.slice(0, 3)

func _take_level_offer(offer: Dictionary) -> void:
	match offer["stat"]:
		"hp":
			player["max_hp"] += float(offer["value"])
			player["hp"] += float(offer["value"])
		"speed":
			player["speed"] *= 1.0 + float(offer["value"])
		"damage":
			player["damage"] *= 1.0 + float(offer["value"])
		"cooldown":
			player["cooldown"] *= max(0.55, 1.0 - float(offer["value"]))
		"pickup":
			player["pickup"] *= 1.0 + float(offer["value"])
		"luck":
			player["luck"] += float(offer["value"])
		"income":
			player["income"] += float(offer["value"])
		"armor":
			player["armor"] += float(offer["value"])
		"regen":
			player["regen"] += float(offer["value"])
	pending_level_choices -= 1
	if pending_level_choices > 0:
		_roll_level_offers()
		message = "继续选择升级奖励。剩余 %d 次。" % pending_level_choices
	else:
		_enter_shop()

func _enter_shop() -> void:
	game_state = "shop"
	shop_inventory_scroll = clamp(shop_inventory_scroll, 0, _shop_inventory_max_scroll())
	var previous_slot_count: int = shop_offers.size()
	_ensure_shop_slot_count()
	for i in min(previous_slot_count, shop_offers.size()):
		if not bool(shop_locks[i]):
			_refresh_shop_offer(i, shop_offers[i])
	message = "商店：未上锁商品会在下次进入商店时刷新，单槽刷新费用会在本局持续上涨。"

func _shop_slot_count() -> int:
	return BASE_SHOP_SLOTS + min(MAX_SHOP_SLOT_BONUS, shop_slot_bonus)

func _weapon_slot_count() -> int:
	return BASE_WEAPON_SLOTS + weapon_slot_bonus

func _shop_kind_for_slot(index: int) -> String:
	var kinds: Array = ["weapon", "item", "stat"]
	return kinds[index % kinds.size()]

func _ensure_shop_slot_count() -> void:
	var target_count: int = _shop_slot_count()
	while shop_locks.size() < target_count:
		shop_locks.append(false)
	while shop_offers.size() < target_count:
		var index: int = shop_offers.size()
		var kind: String = _shop_kind_for_slot(index)
		shop_offers.append(_make_shop_offer(kind, _shop_offer_ids(kind)))
	while shop_offers.size() > target_count:
		shop_offers.pop_back()
	while shop_locks.size() > target_count:
		shop_locks.pop_back()

func _make_shop_offer(kind: String, excluded_ids: Array = []) -> Dictionary:
	match kind:
		"weapon":
			return _make_shop_weapon_offer(excluded_ids)
		"item":
			var items: Array = _roll_shop_items(1, excluded_ids)
			if not items.is_empty():
				return _make_shop_item_offer(items[0])
	return _make_random_shop_stat_offer(excluded_ids if kind == "stat" else [])

func _shop_offer_ids(kind: String, ignored_index: int = -1) -> Array:
	var ids: Array = []
	for i in shop_offers.size():
		if i == ignored_index:
			continue
		var offer: Dictionary = shop_offers[i]
		if offer["kind"] == kind:
			ids.append(offer["data"]["id"])
	return ids

func _make_shop_weapon_offer(excluded_ids: Array = []) -> Dictionary:
	var candidates: Array = []
	for weapon: Dictionary in WEAPON_POOL:
		if not excluded_ids.has(weapon["id"]):
			candidates.append(weapon)
	if candidates.is_empty():
		candidates = WEAPON_POOL.duplicate(true)
	var data: Dictionary = candidates[rng.randi_range(0, candidates.size() - 1)]
	var current: int = _weapon_level(data["id"])
	return {"kind": "weapon", "data": data, "cost": _shop_cost(data["base_cost"] + current * 10)}

func _make_shop_item_offer(item: Dictionary) -> Dictionary:
	return {"kind": "item", "data": item, "cost": _shop_cost(item["cost"])}

func _make_random_shop_stat_offer(excluded_ids: Array = []) -> Dictionary:
	var candidates: Array = []
	for stat: Dictionary in SHOP_STAT_POOL:
		if not excluded_ids.has(stat["id"]):
			candidates.append(stat)
	if candidates.is_empty():
		candidates = SHOP_STAT_POOL.duplicate(true)
	var data: Dictionary = candidates[rng.randi_range(0, candidates.size() - 1)]
	return _make_shop_stat_offer(data)

func _make_shop_stat_offer(base_data: Dictionary) -> Dictionary:
	var rarity: String = _roll_rarity_by_luck()
	var quality: Dictionary = SHOP_STAT_QUALITY[rarity]
	var value: float = float(base_data["base_value"]) * float(quality["value"])
	var cost: int = _shop_cost(int(round(float(base_data["base_cost"]) * float(RARITY_COST_MULTIPLIER[rarity]))))
	var data: Dictionary = base_data.duplicate(true)
	data["rarity"] = rarity
	data["value"] = value
	data["quality_label"] = quality["label"]
	data["desc"] = _shop_stat_desc(data)
	return {"kind": "stat", "data": data, "cost": cost}

func _roll_rarity_by_luck() -> String:
	var rarities: Array = ["common", "rare", "epic", "legendary"]
	var total_weight: float = 0.0
	var weights: Array = []
	for rarity: String in rarities:
		var weight: float = _rarity_weight(rarity)
		weights.append(weight)
		total_weight += weight
	var roll: float = rng.randf() * total_weight
	var cursor: float = 0.0
	for i in rarities.size():
		cursor += float(weights[i])
		if roll <= cursor:
			return rarities[i]
	return "common"

func _shop_stat_desc(data: Dictionary) -> String:
	var value: float = float(data["value"])
	match data["stat"]:
		"hp":
			return "%s 最大生命 +%d。%s" % [data["quality_label"], int(value), data["desc"]]
		"speed":
			return "%s 移动速度 +%d%%。%s" % [data["quality_label"], int(value * 100.0), data["desc"]]
		"damage":
			return "%s 法则伤害 +%d%%。%s" % [data["quality_label"], int(value * 100.0), data["desc"]]
		"cooldown":
			return "%s 冷却 -%d%%。%s" % [data["quality_label"], int(value * 100.0), data["desc"]]
		"luck":
			return "%s 幸运 +%d。%s" % [data["quality_label"], int(value), data["desc"]]
		"pickup":
			return "%s 拾取范围 +%d%%。%s" % [data["quality_label"], int(value * 100.0), data["desc"]]
		"income":
			return "%s 额外知识币概率 +%d%%。%s" % [data["quality_label"], int(value * 100.0), data["desc"]]
		"armor":
			return "%s 护甲 +%.1f。%s" % [data["quality_label"], value, data["desc"]]
		"regen":
			return "%s 每秒回复 +%.2f。%s" % [data["quality_label"], value, data["desc"]]
	return str(data["desc"])

func _roll_shop_items(count: int, excluded_ids: Array = []) -> Array:
	var results: Array = []
	var pool: Array = []
	for item: Dictionary in ITEM_POOL:
		if not excluded_ids.has(item["id"]) and _can_buy_item(item):
			pool.append(item)
	if pool.is_empty():
		for item: Dictionary in ITEM_POOL:
			if _can_buy_item(item):
				pool.append(item)
	while results.size() < count and not pool.is_empty():
		var total_weight: float = 0.0
		var weights: Array = []
		for item: Dictionary in pool:
			var weight: float = _rarity_weight(item["rarity"])
			weights.append(weight)
			total_weight += weight
		var roll: float = rng.randf() * total_weight
		var cursor: float = 0.0
		var picked_index: int = 0
		for i in weights.size():
			cursor += float(weights[i])
			if roll <= cursor:
				picked_index = i
				break
		results.append(pool[picked_index])
		pool.remove_at(picked_index)
	return results

func _item_count(item_id: String) -> int:
	return int(item_counts.get(item_id, 0))

func _item_data(item_id: String) -> Dictionary:
	for item: Dictionary in ITEM_POOL:
		if item["id"] == item_id:
			return item
	return {"id": item_id, "name": item_id, "desc": "物品信息不可用。", "rarity": "common"}

func _shop_inventory_max_scroll() -> int:
	return max(0, owned_items.size() - 2)

func _scroll_shop_inventory(direction: int) -> void:
	var previous_scroll := shop_inventory_scroll
	shop_inventory_scroll = clamp(shop_inventory_scroll + direction, 0, _shop_inventory_max_scroll())
	if shop_inventory_scroll != previous_scroll:
		queue_redraw()

func _item_max_stacks(item: Dictionary) -> int:
	return int(item.get("max_stacks", 1))

func _can_buy_item(item: Dictionary) -> bool:
	return _item_count(item["id"]) < _item_max_stacks(item)

func _weapon_level(weapon_id: String) -> int:
	if weapons.has(weapon_id):
		return int(weapons[weapon_id]["level"])
	if weapon_backpack.has(weapon_id):
		return int(weapon_backpack[weapon_id]["level"])
	return 0

func _rarity_weight(rarity: String) -> float:
	var luck: float = float(player["luck"])
	match rarity:
		"common":
			return max(12.0, 70.0 - luck * 0.45)
		"rare":
			return 24.0 + luck * 0.35
		"epic":
			return 7.0 + luck * 0.18
		"legendary":
			return 1.2 + luck * 0.06
	return 10.0

func _shop_cost(base_cost: int) -> int:
	var discount: float = min(0.22, float(player["luck"]) * 0.0015)
	if owned_items.has("gauss"):
		discount += 0.08
	return max(1, int(round(base_cost * (1.0 - discount))))

func _refresh_shop_offer(offer_index: int, previous_offer: Dictionary) -> void:
	var kind: String = previous_offer["kind"]
	var excluded_ids: Array = _shop_offer_ids(kind, offer_index)
	excluded_ids.append(previous_offer["data"]["id"])
	shop_offers[offer_index] = _make_shop_offer(kind, excluded_ids)

func _shop_refresh_cost() -> int:
	return SHOP_REFRESH_BASE_COST + shop_refresh_count * SHOP_REFRESH_COST_STEP

func _toggle_shop_lock(offer_index: int) -> void:
	if offer_index < 0 or offer_index >= shop_locks.size():
		_show_notice("商品信息已经变化，请重新选择商品。", "无法操作")
		return
	shop_locks[offer_index] = not bool(shop_locks[offer_index])
	message = "商品已上锁，下次进入商店时保留。" if shop_locks[offer_index] else "商品已解锁。"

func _refresh_shop_slot(offer_index: int) -> void:
	if offer_index < 0 or offer_index >= shop_offers.size():
		_show_notice("商品信息已经变化，请重新选择要刷新的位置。", "无法刷新")
		return
	if bool(shop_locks[offer_index]):
		_show_notice("该商品已上锁，无法刷新。请先点击“解锁”按钮。", "无法刷新")
		return
	var refresh_cost: int = _shop_refresh_cost()
	if money < refresh_cost:
		_show_notice(
			"当前有 %d 知识币，本次刷新需要 %d 知识币，还差 %d。" % [money, refresh_cost, refresh_cost - money],
			"知识币不足"
		)
		return
	money -= refresh_cost
	shop_refresh_count += 1
	var previous_offer: Dictionary = shop_offers[offer_index]
	_refresh_shop_offer(offer_index, previous_offer)
	message = "已刷新该位置。下一次刷新需要 %d 知识币。" % _shop_refresh_cost()

func _buy_offer(offer_index: int) -> void:
	if offer_index < 0 or offer_index >= shop_offers.size():
		_show_notice("商品信息已经变化，请重新选择要购买的商品。", "无法购买")
		return
	var offer: Dictionary = shop_offers[offer_index]
	var data: Dictionary = offer["data"]
	if offer["kind"] == "weapon":
		var current_level: int = _weapon_level(data["id"])
		if current_level >= int(data["max_level"]):
			_show_notice("%s 已达到最高等级，无法继续购买。" % data["name"], "武器已满级")
			return
		if current_level == 0 and weapons.size() >= _weapon_slot_count():
			_show_notice(
				"武器槽已满（%d/%d）。请先点击已装备武器旁的“背包”按钮，再购买新武器。" % [weapons.size(), _weapon_slot_count()],
				"武器槽已满"
			)
			return
	elif offer["kind"] == "item" and not _can_buy_item(data):
		_show_notice("%s 已达到本局持有上限，无法继续购买。" % data["name"], "已达持有上限")
		return
	if money < int(offer["cost"]):
		var cost: int = int(offer["cost"])
		_show_notice(
			"当前有 %d 知识币，购买“%s”需要 %d 知识币，还差 %d。" % [money, data["name"], cost, cost - money],
			"知识币不足"
		)
		return
	money -= int(offer["cost"])
	shop_locks[offer_index] = false
	if offer["kind"] == "weapon":
		if weapons.has(data["id"]):
			weapons[data["id"]]["level"] += 1
			message = "%s 升至 Lv.%d。" % [data["name"], weapons[data["id"]]["level"]]
		elif weapon_backpack.has(data["id"]):
			weapon_backpack[data["id"]]["level"] += 1
			message = "背包中的 %s 升至 Lv.%d。" % [data["name"], weapon_backpack[data["id"]]["level"]]
		else:
			weapons[data["id"]] = {"level": 1, "timer": 0.3}
			message = "获得法则武器：%s。" % data["name"]
	else:
		if offer["kind"] == "stat":
			_apply_shop_stat(data)
			message = "购买属性加成：%s。" % data["name"]
			_refresh_shop_offer(offer_index, offer)
			return
		item_counts[data["id"]] = _item_count(data["id"]) + 1
		if not owned_items.has(data["id"]):
			owned_items.append(data["id"])
		shop_inventory_scroll = _shop_inventory_max_scroll()
		_apply_item_effect(data["id"])
		var stack_text: String = "（%d/%d）" % [_item_count(data["id"]), _item_max_stacks(data)] if _item_max_stacks(data) > 1 else ""
		message = "购买书页：%s%s。" % [data["name"], stack_text]
	_refresh_shop_offer(offer_index, offer)

func _apply_shop_stat(data: Dictionary) -> void:
	var value: float = float(data["value"])
	match data["stat"]:
		"hp":
			player["max_hp"] += value
			player["hp"] += value
		"speed":
			player["speed"] *= 1.0 + value
		"damage":
			player["damage"] *= 1.0 + value
		"cooldown":
			player["cooldown"] *= max(0.55, 1.0 - value)
		"luck":
			player["luck"] += value
		"pickup":
			player["pickup"] *= 1.0 + value
		"income":
			player["income"] += value
		"armor":
			player["armor"] += value
		"regen":
			player["regen"] += value

func _apply_item_effect(item_id: String) -> void:
	match item_id:
		"gauss":
			player["luck"] += 8.0
		"riemann":
			player["luck"] += 6.0
		"unified_force":
			player["max_hp"] *= 1.1
			player["hp"] = min(float(player["max_hp"]), float(player["hp"]) + 12.0)
			player["speed"] *= 1.1
			player["damage"] *= 1.1
			player["cooldown"] *= 0.9
			player["pickup"] *= 1.1
			player["luck"] += 15.0
		"darwin":
			player["pickup"] *= 1.25
		"maxwell":
			player["cooldown"] *= 0.96
		"shop_shelf":
			shop_slot_bonus = min(MAX_SHOP_SLOT_BONUS, shop_slot_bonus + 1)
			if game_state == "shop":
				_ensure_shop_slot_count()
		"hilbert_rack":
			weapon_slot_bonus = 1

func _move_weapon_to_backpack(weapon_id: String) -> void:
	if not weapons.has(weapon_id):
		_show_notice("该武器当前不在装备栏中，可能已经被放入背包。", "无法放入背包")
		return
	weapon_backpack[weapon_id] = weapons[weapon_id].duplicate(true)
	weapons.erase(weapon_id)
	message = "%s 已放入背包，空出了一个武器槽。" % _weapon_name(weapon_id)

func _equip_weapon_from_backpack(weapon_id: String) -> void:
	if not weapon_backpack.has(weapon_id):
		_show_notice("该武器当前不在背包中，可能已经被装备。", "无法装备")
		return
	if weapons.size() >= _weapon_slot_count():
		_show_notice(
			"武器槽已满（%d/%d）。请先将一把已装备武器放入背包。" % [weapons.size(), _weapon_slot_count()],
			"无法装备"
		)
		return
	var weapon: Dictionary = weapon_backpack[weapon_id].duplicate(true)
	weapon["timer"] = 0.3
	weapons[weapon_id] = weapon
	weapon_backpack.erase(weapon_id)
	message = "%s 已从背包装备。" % _weapon_name(weapon_id)

func _start_exam_for_current_wave() -> void:
	exam_active = false
	exam_passed = false
	exam_overtime_notice = false
	current_exam_name = ""
	if not EXAM_WAVES.has(wave):
		return
	var exam: Dictionary = EXAM_WAVES[wave]
	var difficulty: Dictionary = DIFFICULTIES[selected_difficulty]
	var boss_hp: float = float(exam["hp"]) * float(difficulty["enemy"])
	var spawn_pos: Vector2 = _clamp_to_arena(
		player["pos"] + Vector2.RIGHT.rotated(rng.randf_range(0.0, TAU)) * 520.0,
		float(exam["radius"]) + 20.0
	)
	enemies.append({
		"uid": _next_enemy_uid(),
		"pos": spawn_pos,
		"vel": Vector2.ZERO,
		"hp": boss_hp,
		"max_hp": boss_hp,
		"speed": 72.0 + wave * 2.5,
		"radius": float(exam["radius"]),
		"shape": "boss",
		"color": exam["color"],
		"hit_cd": 0.0,
		"entropy": 0,
		"burn_time": 0.0,
		"burn_tick": 0.5,
		"burn_damage": 0.0,
		"burn_generation": 0,
		"burn_spread_done": false,
		"boss": true,
		"boss_name": exam["boss"],
		"boss_kind": exam["kind"],
		"ability_timer": 1.8,
		"boss_phase": 0,
	})
	exam_active = true
	current_exam_name = str(exam["name"])
	message = "%s：击败“%s”，倒计时结束后才能结算。" % [exam["name"], exam["boss"]]

func _complete_exam(enemy: Dictionary) -> void:
	if not bool(enemy.get("boss", false)) or exam_passed:
		return
	exam_passed = true
	exam_active = false
	var exam: Dictionary = EXAM_WAVES.get(wave, {})
	var reward_money: int = int(exam.get("reward_money", 12))
	var reward_xp: int = int(exam.get("reward_xp", 10))
	money += reward_money
	_grant_xp(reward_xp)
	pending_level_choices += 1
	message = "通过%s：知识币 +%d，经验 +%d，并获得额外升级奖励。" % [current_exam_name, reward_money, reward_xp]
	_add_float_text(enemy["pos"], "考试通过", Color(1.0, 0.82, 0.3))

func _current_exam_boss_name() -> String:
	for enemy: Dictionary in enemies:
		if bool(enemy.get("boss", false)):
			return str(enemy.get("boss_name", "考试目标"))
	return "考试目标"

func _next_wave() -> void:
	if wave >= MAX_WAVES:
		_end_run(true)
		return
	wave += 1
	wave_time = WAVE_DURATION
	spawn_timer = 0.0
	enemies.clear()
	spawn_warnings.clear()
	fields.clear()
	projectiles.clear()
	beams.clear()
	game_state = "playing"
	message = "第 %d/%d 小关开始。" % [wave, MAX_WAVES]
	_start_exam_for_current_wave()

func _end_run(victory: bool) -> void:
	var certificates: int = max(1, wave + kills / 18 + level / 3)
	if victory:
		certificates += 18
	certificates += int(float(player["luck"]) / 18.0)
	if save.equipped.has("奖状夹"):
		certificates = int(ceil(certificates * 1.15))
	certificates = max(1, int(ceil(certificates * float(DIFFICULTIES[selected_difficulty]["reward"]))))
	var gained_levels: int = save.add_certificates(certificates)
	message = "%s：获得 %d 张奖状，局外等级提升 %d 次。" % ["12 小关通关" if victory else "本局结束", certificates, gained_levels]
	game_state = "meta"

func _draw() -> void:
	var screen_center: Vector2 = get_viewport_rect().size * 0.5
	draw_set_transform(screen_center - player["pos"])
	_draw_arena()
	for field: Dictionary in fields:
		_draw_field(field)
	for orb: Dictionary in xp_orbs:
		draw_circle(orb["pos"], 5.0, Color(0.2, 0.9, 1.0))
	for beam: Dictionary in beams:
		_draw_beam(beam)
	for p: Dictionary in projectiles:
		var projectile_color: Color = Color(0.3, 0.9, 1.0) if p.get("kind", "momentum") == "lorentz" else Color(1.0, 0.92, 0.25)
		draw_circle(p["pos"], p["radius"], projectile_color)
	if bool(settings["show_warnings"]):
		for warning: Dictionary in spawn_warnings:
			_draw_spawn_warning(warning)
	for enemy: Dictionary in enemies:
		_draw_enemy(enemy)
	if game_state == "playing" and weapons.has("friction"):
		draw_arc(player["pos"], 170.0 + weapons["friction"]["level"] * 16.0, 0, TAU, 64, Color(0.85, 0.85, 0.85, 0.35), 3.0)
	if game_state == "playing" and weapons.has("angular_momentum"):
		var angular_radius: float = 145.0 + weapons["angular_momentum"]["level"] * 18.0
		var angular_time: float = Time.get_ticks_msec() / 1000.0
		draw_arc(player["pos"], angular_radius, 0, TAU, 64, Color(0.96, 0.72, 0.25, 0.5), 3.0)
		for marker in 4:
			var marker_pos: Vector2 = player["pos"] + Vector2.RIGHT.rotated(angular_time * 3.2 + marker * TAU / 4.0) * angular_radius
			draw_circle(marker_pos, 5.0, Color(1.0, 0.82, 0.34))
	if game_state == "playing" and weapons.has("entropy"):
		draw_arc(player["pos"], 74.0, 0, TAU, 48, Color(0.56, 0.75, 1.0, 0.42), 2.0)
	draw_circle(player["pos"], PLAYER_RADIUS, Color(0.95, 0.95, 1.0))
	draw_arc(player["pos"], PLAYER_RADIUS + 5.0, -PI / 2, -PI / 2 + TAU * float(player["hp"]) / float(player["max_hp"]), 32, Color(0.2, 1.0, 0.45), 4.0)
	for text: Dictionary in float_texts:
		draw_string(ThemeDB.fallback_font, text["pos"], text["text"], HORIZONTAL_ALIGNMENT_CENTER, -1, 16, text["color"])
	draw_set_transform(Vector2.ZERO)
	_draw_ui()

func _draw_beam(beam: Dictionary) -> void:
	var points: Array = beam.get("points", [])
	for i in range(points.size() - 1):
		var start: Vector2 = points[i]
		var finish: Vector2 = points[i + 1]
		var beam_time: float = Time.get_ticks_msec() / 1000.0
		var jitter := Vector2(sin(beam_time * 43.0 + i * 2.1), cos(beam_time * 37.0 + i * 1.7)) * 3.0
		draw_line(start, finish + jitter, beam["color"], float(beam["width"]))
		draw_line(start, finish, Color(1.0, 1.0, 1.0, 0.65), max(1.0, float(beam["width"]) * 0.3))

func _draw_arena() -> void:
	var rect := Rect2(-ARENA_SIZE * 0.5, ARENA_SIZE)
	draw_rect(rect, Color(0.055, 0.06, 0.075), true)
	draw_rect(rect, Color(0.25, 0.3, 0.42), false, 4.0)
	for x in range(int(rect.position.x), int(rect.end.x), 100):
		draw_line(Vector2(x, rect.position.y), Vector2(x, rect.end.y), Color(0.12, 0.14, 0.18), 1.0)
	for y in range(int(rect.position.y), int(rect.end.y), 100):
		draw_line(Vector2(rect.position.x, y), Vector2(rect.end.x, y), Color(0.12, 0.14, 0.18), 1.0)

func _draw_field(field: Dictionary) -> void:
	var color: Color = Color(1.0, 0.45, 0.1, 0.22)
	match field["kind"]:
		"gravity":
			color = Color(0.55, 0.45, 1.0, 0.18)
		"exam_gravity":
			color = Color(0.82, 0.62, 1.0, 0.2)
		"exam_thermal":
			color = Color(1.0, 0.24, 0.08, 0.22)
	draw_circle(field["pos"], field["radius"], color)
	draw_arc(field["pos"], field["radius"], 0, TAU, 80, color.lightened(0.5), 3.0)

func _draw_enemy(enemy: Dictionary) -> void:
	var r: float = enemy["radius"]
	if bool(enemy.get("boss", false)):
		draw_circle(enemy["pos"], r, enemy["color"])
		draw_arc(enemy["pos"], r + 10.0, 0, TAU, 56, Color(1.0, 0.9, 0.55), 5.0)
		draw_arc(enemy["pos"], r * 0.55, Time.get_ticks_msec() / 500.0, Time.get_ticks_msec() / 500.0 + PI * 1.35, 32, Color.WHITE, 3.0)
	elif enemy["shape"] == "square":
		draw_rect(Rect2(enemy["pos"] - Vector2(r, r), Vector2(r * 2, r * 2)), enemy["color"], true)
	elif enemy["shape"] == "diamond":
		draw_colored_polygon([enemy["pos"] + Vector2(0, -r), enemy["pos"] + Vector2(r, 0), enemy["pos"] + Vector2(0, r), enemy["pos"] + Vector2(-r, 0)], enemy["color"])
	else:
		draw_colored_polygon([enemy["pos"] + Vector2(0, -r), enemy["pos"] + Vector2(r * 0.9, r), enemy["pos"] + Vector2(-r * 0.9, r)], enemy["color"])
	var hp_ratio: float = clamp(float(enemy["hp"]) / float(enemy["max_hp"]), 0.0, 1.0)
	draw_rect(Rect2(enemy["pos"] + Vector2(-r, -r - 9), Vector2(r * 2 * hp_ratio, 4)), Color(1.0, 0.15, 0.15), true)
	if int(enemy.get("entropy", 0)) > 0:
		draw_string(ThemeDB.fallback_font, enemy["pos"] + Vector2(-r, r + 20), "熵%d" % int(enemy["entropy"]), HORIZONTAL_ALIGNMENT_CENTER, r * 2.0, 13, Color(0.6, 0.82, 1.0))
	if float(enemy.get("burn_time", 0.0)) > 0.0:
		draw_circle(enemy["pos"] + Vector2(r * 0.6, -r * 0.6), 6.0, Color(1.0, 0.35, 0.08))

func _draw_spawn_warning(warning: Dictionary) -> void:
	var pos: Vector2 = warning["pos"]
	var progress: float = 1.0 - float(warning["time"]) / float(warning["duration"])
	var blink: float = 0.35 + 0.65 * abs(sin(progress * TAU * 5.0))
	var size: float = lerp(36.0, 22.0, progress)
	var color: Color = Color(1.0, 0.05, 0.03, blink)
	draw_line(pos + Vector2(-size, -size), pos + Vector2(size, size), color, 5.0)
	draw_line(pos + Vector2(-size, size), pos + Vector2(size, -size), color, 5.0)
	draw_arc(pos, size * 1.15, 0.0, TAU, 32, Color(1.0, 0.12, 0.08, blink * 0.75), 2.0)

func _draw_ui() -> void:
	var size: Vector2 = get_viewport_rect().size
	var font: Font = ThemeDB.fallback_font
	draw_rect(Rect2(Vector2.ZERO, Vector2(size.x, 104)), Color(0.02, 0.025, 0.035, 0.9), true)
	draw_string(font, Vector2(18, 27), "%s Lv.%d | HP %d/%d | 经验 %d | 知识币 %d | 小关 %d/%d | %.0fs" % [_academic_stage_name(), level, int(player["hp"]), int(player["max_hp"]), xp, money, wave, MAX_WAVES, max(0.0, wave_time)], HORIZONTAL_ALIGNMENT_LEFT, 735, 19, Color.WHITE)
	draw_string(font, Vector2(18, 55), message, HORIZONTAL_ALIGNMENT_LEFT, 725, 16, Color(0.75, 0.88, 1.0))
	var weapon_text: String = "武器 %d/%d：" % [weapons.size(), _weapon_slot_count()]
	for id in weapons:
		weapon_text += " %s Lv.%d" % [_weapon_name(id), weapons[id]["level"]]
	draw_string(font, Vector2(size.x - 520, 54), weapon_text, HORIZONTAL_ALIGNMENT_LEFT, 500, 15, Color(1.0, 0.9, 0.62))
	for enemy: Dictionary in enemies:
		if not bool(enemy.get("boss", false)):
			continue
		var boss_ratio: float = clamp(float(enemy["hp"]) / float(enemy["max_hp"]), 0.0, 1.0)
		draw_string(font, Vector2(18, 84), "%s  %d/%d" % [enemy["boss_name"], int(enemy["hp"]), int(enemy["max_hp"])], HORIZONTAL_ALIGNMENT_LEFT, 280, 15, Color(1.0, 0.84, 0.5))
		draw_rect(Rect2(Vector2(300, 72), Vector2(430, 14)), Color(0.12, 0.08, 0.1), true)
		draw_rect(Rect2(Vector2(300, 72), Vector2(430 * boss_ratio, 14)), enemy["color"], true)
		break
	if game_state == "meta":
		_draw_meta_root_ui(size, font)
	elif game_state == "level_up":
		_draw_level_ui(size, font)
	elif game_state == "shop":
		_draw_shop_ui(size, font)
	if notice_visible:
		_draw_notice_popup(size, font)

func _show_notice(text: String, title: String = "提示") -> void:
	notice_title = title
	notice_text = text
	notice_visible = true
	message = text
	queue_redraw()

func _dismiss_notice() -> void:
	notice_visible = false
	notice_confirm_rect = Rect2()
	queue_redraw()

func _draw_notice_popup(size: Vector2, font: Font) -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.0, 0.0, 0.0, 0.66), true)
	var popup_size := Vector2(520, 250)
	var popup_rect := Rect2(size * 0.5 - popup_size * 0.5, popup_size)
	draw_rect(popup_rect, Color(0.045, 0.055, 0.08, 0.99), true)
	draw_rect(popup_rect, Color(0.95, 0.62, 0.24), false, 3.0)
	draw_string(font, popup_rect.position + Vector2(28, 46), notice_title, HORIZONTAL_ALIGNMENT_LEFT, popup_rect.size.x - 56, 25, Color(1.0, 0.86, 0.58))
	draw_multiline_string(font, popup_rect.position + Vector2(28, 88), notice_text, HORIZONTAL_ALIGNMENT_LEFT, popup_rect.size.x - 56, 18, 4, Color(0.92, 0.95, 1.0))
	notice_confirm_rect = Rect2(
		Vector2(popup_rect.get_center().x - 70, popup_rect.end.y - 58),
		Vector2(140, 36)
	)
	draw_rect(notice_confirm_rect, Color(0.18, 0.34, 0.62), true)
	draw_rect(notice_confirm_rect, Color(0.68, 0.82, 1.0), false, 1.0)
	draw_string(font, notice_confirm_rect.position + Vector2(0, 25), "确定", HORIZONTAL_ALIGNMENT_CENTER, notice_confirm_rect.size.x, 17, Color.WHITE)

func _draw_meta_root_ui(size: Vector2, font: Font) -> void:
	match meta_screen:
		"home":
			_draw_home_ui(size, font)
		"upgrade":
			_draw_meta_ui(size, font)
		"codex":
			_draw_codex_ui(size, font)
		"settings":
			_draw_settings_ui(size, font)

func _draw_home_ui(size: Vector2, font: Font) -> void:
	_draw_panel(Rect2(size * 0.5 - Vector2(390, 285), Vector2(780, 570)), "法则之战")
	var x: float = size.x * 0.5 - 320
	var y: float = size.y * 0.5 - 205
	draw_string(font, Vector2(x, y), "Physical Arena", HORIZONTAL_ALIGNMENT_LEFT, -1, 34, Color(0.9, 0.95, 1.0))
	draw_string(font, Vector2(x, y + 42), "选择难度，然后开始 12 小关挑战。", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(0.76, 0.84, 1.0))
	y += 88
	draw_string(font, Vector2(x, y), "难度选项", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color(1.0, 0.9, 0.62))
	y += 18
	for i in DIFFICULTIES.size():
		var difficulty: Dictionary = DIFFICULTIES[i]
		var rect: Rect2 = Rect2(Vector2(x + i * 165, y + 14), Vector2(150, 84))
		var selected: bool = i == selected_difficulty
		draw_rect(rect, Color(0.12, 0.15, 0.22) if selected else Color(0.07, 0.08, 0.11), true)
		draw_rect(rect, Color(0.9, 0.72, 0.25) if selected else Color(0.36, 0.48, 0.78), false, 2.0)
		draw_string(font, rect.position + Vector2(10, 26), difficulty["name"], HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 20, 18, Color.WHITE)
		draw_multiline_string(font, rect.position + Vector2(10, 48), difficulty["desc"], HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 20, 12, 2, Color(0.8, 0.86, 0.96))
		_add_hotspot(rect, func(index: int = i): _select_difficulty(index))
	y += 138
	_add_button(Rect2(Vector2(size.x * 0.5 - 130, y), Vector2(260, 46)), "开始游戏", _start_run)
	y += 70
	_add_button(Rect2(Vector2(x, y), Vector2(180, 40)), "局外强化", func(): _set_meta_screen("upgrade"))
	_add_button(Rect2(Vector2(x + 230, y), Vector2(180, 40)), "法则图鉴", func(): _set_meta_screen("codex"))
	_add_button(Rect2(Vector2(x + 460, y), Vector2(180, 40)), "游戏设置", func(): _set_meta_screen("settings"))

func _select_difficulty(index: int) -> void:
	if index < 0 or index >= DIFFICULTIES.size():
		_show_notice("该难度不存在，请重新选择。", "无法选择难度")
		return
	if index == selected_difficulty:
		_show_notice("当前已经选择“%s”难度。" % DIFFICULTIES[index]["name"], "难度未改变")
		return
	selected_difficulty = index
	message = "已选择难度：%s。" % DIFFICULTIES[index]["name"]

func _set_meta_screen(screen: String) -> void:
	if not ["home", "upgrade", "codex", "settings"].has(screen):
		_show_notice("目标页面不存在，请重新操作。", "无法打开页面")
		return
	meta_screen = screen

func _draw_meta_ui(size: Vector2, font: Font) -> void:
	_draw_panel(Rect2(size * 0.5 - Vector2(470, 315), Vector2(940, 630)), "局外成长")
	_add_button(Rect2(Vector2(size.x * 0.5 + 330, size.y * 0.5 - 285), Vector2(100, 32)), "返回", func(): _set_meta_screen("home"))
	var x: float = size.x * 0.5 - 430
	var y: float = size.y * 0.5 - 245
	draw_string(font, Vector2(x, y), "奖状等级 %d | 奖状 %d/%d | 可用属性点 %d" % [save.meta_level, save.certificates, save.certificates_to_next_level(), save.unspent_points], HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color.WHITE)
	y += 36
	var stat_labels: Dictionary = {"max_hp": "体魄", "move_speed": "步法", "damage": "法则强度", "cooldown": "推导速度", "luck": "幸运", "pickup": "感知半径", "income": "奖币学", "armor": "护甲", "regen": "再生"}
	var stat_keys: Array = ["max_hp", "move_speed", "damage", "cooldown", "luck", "pickup", "income", "armor", "regen"]
	for index in stat_keys.size():
		var stat: String = stat_keys[index]
		var col: int = index % 3
		var row: int = index / 3
		var sx: float = x + col * 290
		var sy: float = y + row * 42
		var label: String = stat_labels[stat]
		draw_string(font, Vector2(sx, sy + 20), "%s：%d" % [label, save.stats[stat]], HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(0.9, 0.92, 1.0))
		_add_button(Rect2(Vector2(sx + 150, sy), Vector2(80, 30)), "+1", func(stat_name: String = stat): _spend_meta(stat_name))
	y += 145
	draw_string(font, Vector2(x, y), "局外装备（最多装备 2 件，使用奖状解锁）：", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(1.0, 0.9, 0.65))
	y += 32
	var equipment_names: Array = META_EQUIPMENT.keys()
	for index in equipment_names.size():
		var item_name: String = equipment_names[index]
		var item: Dictionary = META_EQUIPMENT[item_name]
		var owned: bool = save.unlocked_equipment.has(item_name)
		var equipped: bool = save.equipped.has(item_name)
		var col: int = index % 2
		var row: int = index / 2
		var ex: float = x + col * 455
		var ey: float = y + row * 42
		var text: String = "%s%s - %s" % ["[已装备] " if equipped else ("[已解锁] " if owned else "[未解锁] "), item_name, item["desc"]]
		draw_string(font, Vector2(ex, ey + 20), text, HORIZONTAL_ALIGNMENT_LEFT, 330, 15, Color(0.86, 0.9, 1.0))
		_add_button(Rect2(Vector2(ex + 335, ey), Vector2(100, 30)), "切换" if owned else "解锁%d" % item["cost"], func(name: String = item_name): _toggle_meta_equipment(name))
	_add_button(Rect2(Vector2(size.x * 0.5 - 110, size.y * 0.5 + 255), Vector2(220, 42)), "返回开始页", func(): _set_meta_screen("home"))

func _draw_settings_ui(size: Vector2, font: Font) -> void:
	_draw_panel(Rect2(size * 0.5 - Vector2(310, 220), Vector2(620, 440)), "游戏设置")
	var x: float = size.x * 0.5 - 250
	var y: float = size.y * 0.5 - 130
	draw_string(font, Vector2(x, y), "显示怪物生成红叉预警：%s" % ("开" if settings["show_warnings"] else "关"), HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color.WHITE)
	_add_button(Rect2(Vector2(x + 360, y - 24), Vector2(100, 32)), "切换", func(): _toggle_setting("show_warnings"))
	y += 64
	draw_string(font, Vector2(x, y), "显示法则联动浮动文字：%s" % ("开" if settings["show_reaction_text"] else "关"), HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color.WHITE)
	_add_button(Rect2(Vector2(x + 360, y - 24), Vector2(100, 32)), "切换", func(): _toggle_setting("show_reaction_text"))
	y += 88
	draw_multiline_string(font, Vector2(x, y), "设置当前仅影响本次运行。后续可扩展为音量、屏幕、特效密度和键位。", HORIZONTAL_ALIGNMENT_LEFT, 500, 16, 3, Color(0.78, 0.84, 0.95))
	_add_button(Rect2(Vector2(size.x * 0.5 - 90, size.y * 0.5 + 145), Vector2(180, 40)), "返回", func(): _set_meta_screen("home"))

func _toggle_setting(key: String) -> void:
	if not settings.has(key):
		_show_notice("该设置项不存在。", "无法修改设置")
		return
	settings[key] = not bool(settings[key])
	message = "设置已更新。"

func _draw_codex_ui(size: Vector2, font: Font) -> void:
	_draw_panel(Rect2(size * 0.5 - Vector2(560, 315), Vector2(1120, 630)), "法则图鉴")
	_add_button(Rect2(Vector2(size.x * 0.5 + 430, size.y * 0.5 - 285), Vector2(90, 32)), "返回", func(): _set_meta_screen("home"))
	var x: float = size.x * 0.5 - 520
	var y: float = size.y * 0.5 - 250
	draw_string(font, Vector2(x, y), "选择联动条目，右侧查看相互作用说明与演示。", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(0.78, 0.86, 1.0))
	y += 40
	var keys: Array = LAW_LINKS.keys()
	keys.sort()
	for i in keys.size():
		var key: String = keys[i]
		var link: Dictionary = LAW_LINKS[key]
		var rect: Rect2 = Rect2(Vector2(x, y + i * 46), Vector2(330, 36))
		var selected: bool = key == codex_selected_link
		draw_rect(rect, Color(0.13, 0.15, 0.22) if selected else Color(0.07, 0.08, 0.11), true)
		draw_rect(rect, Color(0.9, 0.72, 0.25) if selected else Color(0.36, 0.48, 0.78), false, 1.0)
		draw_string(font, rect.position + Vector2(10, 24), link["name"], HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 20, 16, Color.WHITE)
		_add_hotspot(rect, func(selected_key: String = key): _select_codex_link(selected_key))
	_draw_codex_detail(Rect2(Vector2(size.x * 0.5 - 140, size.y * 0.5 - 215), Vector2(620, 435)), font)

func _select_codex_link(key: String) -> void:
	if not LAW_LINKS.has(key):
		_show_notice("该联动条目不存在，请重新选择。", "无法查看条目")
		return
	if codex_selected_link == key:
		_show_notice("当前已经在查看该联动条目。", "条目未改变")
		return
	codex_selected_link = key

func _draw_codex_detail(rect: Rect2, font: Font) -> void:
	var link: Dictionary = LAW_LINKS[codex_selected_link]
	draw_rect(rect, Color(0.055, 0.065, 0.09, 0.96), true)
	draw_rect(rect, Color(0.55, 0.45, 0.92), false, 2.0)
	draw_string(font, rect.position + Vector2(18, 32), link["name"], HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 36, 24, Color.WHITE)
	draw_multiline_string(font, rect.position + Vector2(18, 62), link["desc"], HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 36, 17, 4, Color(0.82, 0.88, 1.0))
	_draw_codex_animation(Rect2(rect.position + Vector2(28, 150), Vector2(rect.size.x - 56, 250)), codex_selected_link)

func _draw_codex_animation(rect: Rect2, link_key: String) -> void:
	draw_rect(rect, Color(0.025, 0.03, 0.045), true)
	draw_rect(rect, Color(0.22, 0.28, 0.46), false, 1.0)
	var t: float = Time.get_ticks_msec() / 1000.0
	var center: Vector2 = rect.get_center()
	var left: Vector2 = center + Vector2(-150, sin(t * 2.2) * 28)
	var right: Vector2 = center + Vector2(150, cos(t * 2.0) * 28)
	var pulse: float = 0.5 + 0.5 * sin(t * 5.0)
	draw_line(left, right, Color(0.75, 0.8, 1.0, 0.45 + pulse * 0.35), 3.0)
	var ids: Array = link_key.split("|")
	_draw_law_symbol(left, ids[0], t)
	_draw_law_symbol(right, ids[1], t + 1.0)
	match link_key:
		"angular_momentum|gravity":
			draw_circle(center, 72, Color(0.55, 0.45, 1.0, 0.18))
			draw_arc(center, 98, t * 2.5, t * 2.5 + PI * 1.55, 48, Color(1.0, 0.78, 0.3), 4.0)
			draw_circle(center + Vector2.RIGHT.rotated(t * 3.5) * 98, 8, Color(1.0, 0.9, 0.4))
		"entropy|thermal_conduction":
			for ring in 4:
				draw_arc(center, 35 + ring * 24 + pulse * 8, 0, TAU, 40, Color(0.55 + ring * 0.1, 0.5, 1.0 - ring * 0.12, 0.55), 3.0)
			draw_circle(center, 28 + pulse * 18, Color(1.0, 0.32, 0.08, 0.35))
		"gravity|momentum":
			draw_arc(center, 70 + pulse * 18, 0, TAU, 48, Color(0.72, 0.62, 1.0), 3.0)
			draw_circle(center + Vector2(cos(t * 5.0), sin(t * 5.0)) * 70, 9, Color(1.0, 0.92, 0.25))
		"friction|gravity":
			draw_circle(center, 92, Color(0.55, 0.45, 1.0, 0.18))
			draw_arc(center, 54 + pulse * 25, 0, TAU, 48, Color(1.0, 0.45, 0.16), 4.0)
		"gravity|thermal_expansion":
			draw_circle(center, 45 + pulse * 80, Color(1.0, 0.25, 0.08, 0.18))
			draw_arc(center, 120 - pulse * 55, 0, TAU, 48, Color(0.65, 0.45, 1.0), 3.0)
		"friction|momentum":
			draw_circle(center + Vector2(cos(t * 4.0), sin(t * 4.0)) * 85, 11, Color(1.0, 0.56, 0.16))
			draw_arc(center, 90, 0, TAU, 48, Color(0.85, 0.85, 0.85, 0.45), 3.0)
		"friction|thermal_expansion":
			draw_circle(center, 70 + pulse * 38, Color(1.0, 0.34, 0.08, 0.22))
			draw_arc(center, 105, 0, TAU, 48, Color(0.85, 0.85, 0.85, 0.5), 4.0)
		"momentum|thermal_expansion":
			draw_circle(center, 45 + pulse * 70, Color(1.0, 0.35, 0.08, 0.2))
			draw_line(center + Vector2(-120, 60), center + Vector2(120, -60), Color(1.0, 0.92, 0.25), 5.0)
		"lorentz|ohm":
			draw_line(center + Vector2(-145, 0), center + Vector2(145, 0), Color(0.25, 0.85, 1.0), 9.0)
			draw_line(center + Vector2(-145, 0), center + Vector2(145, 0), Color.WHITE, 3.0)
			draw_circle(center + Vector2(lerp(-130.0, 130.0, fmod(t * 1.8, 1.0)), 0), 10, Color(1.0, 0.92, 0.35))

func _draw_law_symbol(pos: Vector2, id: String, t: float) -> void:
	var label: String = _weapon_name(id)
	var color: Color = Color(0.8, 0.86, 1.0)
	match id:
		"angular_momentum":
			color = Color(1.0, 0.78, 0.3)
			draw_arc(pos, 42, t, t + PI * 1.7, 36, color, 4.0)
			draw_circle(pos + Vector2.RIGHT.rotated(t * 2.0) * 42, 6, color)
		"entropy":
			color = Color(0.56, 0.76, 1.0)
			for ring in 3:
				draw_arc(pos, 18 + ring * 12, 0, TAU, 30, Color(color.r, color.g, color.b, 0.75 - ring * 0.16), 3.0)
		"gravity":
			color = Color(0.62, 0.48, 1.0)
			draw_circle(pos, 32, Color(color.r, color.g, color.b, 0.25))
			draw_arc(pos, 44 + sin(t * 3.0) * 6.0, 0, TAU, 40, color, 3.0)
		"momentum":
			color = Color(1.0, 0.9, 0.25)
			draw_circle(pos + Vector2(cos(t * 4.0), sin(t * 4.0)) * 12.0, 15, color)
		"friction":
			color = Color(0.82, 0.82, 0.82)
			draw_arc(pos, 42, 0, TAU, 36, color, 4.0)
			draw_line(pos + Vector2(-28, 0), pos + Vector2(28, 0), color, 3.0)
		"thermal_expansion":
			color = Color(1.0, 0.38, 0.1)
			draw_circle(pos, 26 + sin(t * 5.0) * 8.0, Color(color.r, color.g, color.b, 0.35))
		"thermal_conduction":
			color = Color(1.0, 0.42, 0.12)
			draw_circle(pos, 18 + sin(t * 4.0) * 4.0, color)
			draw_circle(pos + Vector2(26, -12), 11, Color(1.0, 0.68, 0.2))
		"ohm":
			color = Color(0.25, 0.86, 1.0)
			draw_line(pos + Vector2(-34, 20), pos + Vector2(-10, -18), color, 5.0)
			draw_line(pos + Vector2(-10, -18), pos + Vector2(8, 18), color, 5.0)
			draw_line(pos + Vector2(8, 18), pos + Vector2(34, -20), color, 5.0)
		"lorentz":
			color = Color(0.42, 0.92, 1.0)
			draw_arc(pos, 38, -PI * 0.4, PI * 1.1, 32, color, 4.0)
			draw_circle(pos + Vector2.RIGHT.rotated(t * 2.5) * 34, 7, Color.WHITE)
	draw_string(ThemeDB.fallback_font, pos + Vector2(-54, 68), label, HORIZONTAL_ALIGNMENT_CENTER, 108, 15, Color.WHITE)

func _draw_level_ui(size: Vector2, font: Font) -> void:
	_draw_panel(Rect2(size * 0.5 - Vector2(360, 180), Vector2(720, 360)), "升级奖励")
	for i in level_offers.size():
		var offer: Dictionary = level_offers[i]
		var rect: Rect2 = Rect2(Vector2(size.x * 0.5 - 315 + i * 220, size.y * 0.5 - 70), Vector2(190, 155))
		_draw_card(rect, offer["name"], offer["desc"])
		_add_button(Rect2(rect.position + Vector2(32, 108), Vector2(126, 32)), "选择", func(o: Dictionary = offer): _take_level_offer(o))

func _draw_shop_ui(size: Vector2, font: Font) -> void:
	_draw_panel(Rect2(size * 0.5 - Vector2(620, 340), Vector2(1240, 680)), "法则商店")
	_draw_shop_stats_panel(Rect2(Vector2(size.x * 0.5 - 585, size.y * 0.5 - 270), Vector2(240, 430)), font)
	_draw_shop_inventory_panel(Rect2(Vector2(size.x * 0.5 - 585, size.y * 0.5 + 165), Vector2(240, 165)), font)
	for i in shop_offers.size():
		var offer: Dictionary = shop_offers[i]
		var data: Dictionary = offer["data"]
		var col: int = i % 3
		var row: int = i / 3
		var rect: Rect2 = Rect2(Vector2(size.x * 0.5 - 325 + col * 280, size.y * 0.5 - 260 + row * 190), Vector2(270, 180))
		var next_level: int = _weapon_level(data["id"]) + 1
		var rarity: String = data.get("rarity", "common")
		var title: String = data["name"] + (" Lv.%d" % next_level if offer["kind"] == "weapon" else "")
		var desc: String = data["desc"]
		if offer["kind"] == "weapon":
			var link_lines: Array = _weapon_link_lines(data["id"])
			if link_lines.is_empty():
				desc += "\n暂无已解锁联动。购买其他法则后可形成组合。"
			else:
				desc += "\n" + _join_lines(link_lines)
		if offer["kind"] == "item":
			title = "[%s] %s" % [RARITY_LABEL[rarity], title]
		elif offer["kind"] == "stat":
			title = "[%s属性] %s" % [RARITY_LABEL[rarity], title]
		var border_color: Color = RARITY_COLOR[rarity].lightened(0.2) if bool(shop_locks[i]) else RARITY_COLOR[rarity]
		_draw_card(rect, title, desc, border_color)
		_add_button(Rect2(rect.position + Vector2(6, 144), Vector2(100, 28)), "购买 %d" % offer["cost"], func(index: int = i): _buy_offer(index))
		_add_button(Rect2(rect.position + Vector2(110, 144), Vector2(58, 28)), "解锁" if bool(shop_locks[i]) else "上锁", func(index: int = i): _toggle_shop_lock(index))
		_add_button(Rect2(rect.position + Vector2(172, 144), Vector2(92, 28)), "刷新%d" % _shop_refresh_cost(), func(index: int = i): _refresh_shop_slot(index))
	_draw_shop_weapon_bar(Rect2(Vector2(size.x * 0.5 - 325, size.y * 0.5 + 130), Vector2(830, 112)), font)
	_add_button(Rect2(Vector2(size.x * 0.5 - 100, size.y * 0.5 + 280), Vector2(200, 40)), "完成挑战" if wave >= MAX_WAVES else "进入下一小关", _next_wave)

func _draw_shop_stats_panel(rect: Rect2, font: Font) -> void:
	draw_rect(rect, Color(0.055, 0.065, 0.09, 0.96), true)
	draw_rect(rect, Color(0.36, 0.48, 0.78), false, 2.0)
	draw_string(font, rect.position + Vector2(14, 26), "当前属性", HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color.WHITE)
	var lines: Array = [
		"生命：%d / %d" % [int(player["hp"]), int(player["max_hp"])],
		"移速：%d" % int(player["speed"]),
		"伤害倍率：%.2f" % float(player["damage"]),
		"冷却倍率：%.2f" % float(player["cooldown"]),
		"幸运：%d" % int(player["luck"]),
		"拾取范围：%.2f" % float(player["pickup"]),
		"奖币概率：%d%%" % int((0.22 + float(player["income"]) + float(player["luck"]) * 0.002) * 100.0),
		"护甲：%.1f" % float(player["armor"]),
		"每秒回复：%.2f" % float(player["regen"]),
		"知识币：%d" % money,
		"商店位置：%d / %d" % [_shop_slot_count(), BASE_SHOP_SLOTS + MAX_SHOP_SLOT_BONUS],
		"本局刷新：%d 次" % shop_refresh_count,
		"下次刷新：%d 币" % _shop_refresh_cost(),
		"武器槽：%d / %d" % [weapons.size(), _weapon_slot_count()],
	]
	for i in lines.size():
		draw_string(font, rect.position + Vector2(14, 56 + i * 25), lines[i], HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 28, 15, Color(0.84, 0.9, 1.0))

func _draw_shop_inventory_panel(rect: Rect2, font: Font) -> void:
	shop_inventory_rect = rect
	shop_inventory_scroll = clamp(shop_inventory_scroll, 0, _shop_inventory_max_scroll())
	draw_rect(rect, Color(0.055, 0.065, 0.09, 0.98), true)
	draw_rect(rect, Color(0.78, 0.58, 0.25), false, 2.0)
	var total_stacks := 0
	for item_id: String in owned_items:
		total_stacks += _item_count(item_id)
	draw_string(font, rect.position + Vector2(12, 25), "书页背包  %d 种 / %d 件" % [owned_items.size(), total_stacks], HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 24, 17, Color(1.0, 0.88, 0.58))
	if owned_items.is_empty():
		draw_string(font, rect.position + Vector2(12, 72), "尚未购买书页道具", HORIZONTAL_ALIGNMENT_CENTER, rect.size.x - 24, 14, Color(0.65, 0.7, 0.8))
		return
	for visible_index in 2:
		var item_index: int = shop_inventory_scroll + visible_index
		if item_index >= owned_items.size():
			break
		var item_id: String = owned_items[item_index]
		var item: Dictionary = _item_data(item_id)
		var rarity: String = item.get("rarity", "common")
		var row := Rect2(rect.position + Vector2(9, 36 + visible_index * 59), Vector2(rect.size.x - 27, 55))
		draw_rect(row, Color(0.075, 0.082, 0.115), true)
		draw_rect(row, RARITY_COLOR[rarity], false, 1.0)
		var stack_suffix: String = " ×%d" % _item_count(item_id) if _item_count(item_id) > 1 else ""
		draw_string(font, row.position + Vector2(8, 18), "[%s] %s%s" % [RARITY_LABEL[rarity], item["name"], stack_suffix], HORIZONTAL_ALIGNMENT_LEFT, row.size.x - 16, 13, RARITY_COLOR[rarity].lightened(0.18))
		draw_multiline_string(font, row.position + Vector2(8, 34), item["desc"], HORIZONTAL_ALIGNMENT_LEFT, row.size.x - 16, 11, 2, Color(0.78, 0.84, 0.94))
	var track := Rect2(rect.position + Vector2(rect.size.x - 12, 38), Vector2(4, 114))
	draw_rect(track, Color(0.15, 0.17, 0.22), true)
	var visible_ratio: float = min(1.0, 2.0 / float(owned_items.size()))
	var thumb_height: float = max(22.0, track.size.y * visible_ratio)
	var max_scroll: int = _shop_inventory_max_scroll()
	var scroll_ratio: float = float(shop_inventory_scroll) / float(max_scroll) if max_scroll > 0 else 0.0
	var thumb := Rect2(track.position + Vector2(0, (track.size.y - thumb_height) * scroll_ratio), Vector2(track.size.x, thumb_height))
	draw_rect(thumb, Color(0.9, 0.7, 0.32), true)

func _draw_shop_weapon_bar(rect: Rect2, font: Font) -> void:
	draw_rect(rect, Color(0.055, 0.06, 0.08, 0.96), true)
	draw_rect(rect, Color(0.55, 0.45, 0.92), false, 2.0)
	draw_string(font, rect.position + Vector2(12, 25), "装备 %d/%d" % [weapons.size(), _weapon_slot_count()], HORIZONTAL_ALIGNMENT_LEFT, 95, 16, Color.WHITE)
	var x: float = rect.position.x + 105
	var y: float = rect.position.y + 5
	if weapons.is_empty():
		draw_string(font, Vector2(x, y + 25), "暂无", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(0.8, 0.84, 0.9))
	for id in weapons.keys():
		var text: String = "%s Lv.%d" % [_weapon_name(id), int(weapons[id]["level"])]
		var weapon_rect := Rect2(Vector2(x, y), Vector2(165, 44))
		draw_rect(weapon_rect, Color(0.09, 0.1, 0.15), true)
		draw_rect(weapon_rect, Color(0.42, 0.5, 0.85), false, 1.0)
		draw_string(font, Vector2(x + 7, y + 27), text, HORIZONTAL_ALIGNMENT_LEFT, 106, 14, Color(0.95, 0.92, 1.0))
		_add_button(Rect2(Vector2(x + 116, y + 8), Vector2(43, 27)), "背包", func(weapon_id: String = id): _move_weapon_to_backpack(weapon_id))
		x += 174
	draw_string(font, rect.position + Vector2(12, 84), "背包", HORIZONTAL_ALIGNMENT_LEFT, 82, 16, Color(0.8, 0.86, 1.0))
	x = rect.position.x + 105
	y = rect.position.y + 61
	if weapon_backpack.is_empty():
		draw_string(font, Vector2(x, y + 25), "空", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(0.65, 0.7, 0.8))
	for id in weapon_backpack.keys():
		var text: String = "%s Lv.%d" % [_weapon_name(id), int(weapon_backpack[id]["level"])]
		var backpack_rect := Rect2(Vector2(x, y), Vector2(165, 44))
		draw_rect(backpack_rect, Color(0.07, 0.075, 0.1), true)
		draw_rect(backpack_rect, Color(0.3, 0.36, 0.56), false, 1.0)
		draw_string(font, Vector2(x + 7, y + 27), text, HORIZONTAL_ALIGNMENT_LEFT, 106, 14, Color(0.82, 0.86, 0.94))
		_add_button(Rect2(Vector2(x + 116, y + 8), Vector2(43, 27)), "装备", func(weapon_id: String = id): _equip_weapon_from_backpack(weapon_id))
		x += 174

func _draw_panel(rect: Rect2, title: String) -> void:
	draw_rect(rect, Color(0.035, 0.045, 0.065, 0.96), true)
	draw_rect(rect, Color(0.38, 0.5, 0.82), false, 2.0)
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(24, 34), title, HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color.WHITE)

func _draw_card(rect: Rect2, title: String, desc: String, border_color: Color = Color(0.45, 0.55, 0.78)) -> void:
	draw_rect(rect, Color(0.08, 0.09, 0.13), true)
	draw_rect(rect, border_color, false, 2.0)
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(12, 25), title, HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 24, 16, border_color.lightened(0.25))
	draw_multiline_string(ThemeDB.fallback_font, rect.position + Vector2(12, 48), desc, HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 24, 12, 5, Color(0.78, 0.84, 0.95))

func _add_button(rect: Rect2, text: String, callback: Callable) -> void:
	draw_rect(rect, Color(0.18, 0.28, 0.52), true)
	draw_rect(rect, Color(0.62, 0.75, 1.0), false, 1.0)
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(0, 22), text, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 16, Color.WHITE)
	buttons.append({"rect": rect, "callback": callback})

func _add_hotspot(rect: Rect2, callback: Callable) -> void:
	buttons.append({"rect": rect, "callback": callback})

func _spend_meta(stat: String) -> void:
	if not save.stats.has(stat):
		_show_notice("该局外属性不存在，无法分配属性点。", "无法强化")
		return
	if save.spend_stat_point(stat):
		message = "已分配局外属性点。"
	else:
		_show_notice("当前没有可用属性点。提升奖状等级后可获得新的属性点。", "属性点不足")

func _toggle_meta_equipment(item_name: String) -> void:
	if not META_EQUIPMENT.has(item_name):
		_show_notice("该局外装备不存在，请重新选择。", "无法操作装备")
		return
	var cost: int = int(META_EQUIPMENT[item_name]["cost"])
	if not save.unlocked_equipment.has(item_name) and save.certificates < cost:
		_show_notice(
			"当前有 %d 张奖状，解锁“%s”需要 %d 张，还差 %d 张。" % [save.certificates, item_name, cost, cost - save.certificates],
			"奖状不足"
		)
		return
	if not save.unlocked_equipment.has(item_name):
		save.certificates -= cost
	save.toggle_equipment(item_name)
	message = "局外装备已更新。"

func _weapon_name(id: String) -> String:
	for data: Dictionary in WEAPON_POOL:
		if data["id"] == id:
			return data["name"]
	return id
