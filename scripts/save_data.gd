extends Node
class_name SaveData

const SAVE_PATH := "user://physical_arena_save.cfg"

var meta_level := 1
var certificates := 0
var unspent_points := 0
var stats := {
	"max_hp": 0,
	"move_speed": 0,
	"damage": 0,
	"cooldown": 0,
	"luck": 0,
	"pickup": 0,
	"income": 0,
	"armor": 0,
	"regen": 0,
}
var equipped := []
var unlocked_equipment := ["惯性靴"]

func load_game() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	meta_level = int(cfg.get_value("meta", "level", meta_level))
	certificates = int(cfg.get_value("meta", "certificates", cfg.get_value("meta", "xp", certificates)))
	unspent_points = int(cfg.get_value("meta", "points", unspent_points))
	var loaded_stats: Dictionary = cfg.get_value("meta", "stats", stats)
	for key in stats.keys():
		stats[key] = int(loaded_stats.get(key, stats[key]))
	equipped = cfg.get_value("meta", "equipped", equipped)
	unlocked_equipment = cfg.get_value("meta", "unlocked_equipment", unlocked_equipment)

func save_game() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("meta", "level", meta_level)
	cfg.set_value("meta", "certificates", certificates)
	cfg.set_value("meta", "points", unspent_points)
	cfg.set_value("meta", "stats", stats)
	cfg.set_value("meta", "equipped", equipped)
	cfg.set_value("meta", "unlocked_equipment", unlocked_equipment)
	cfg.save(SAVE_PATH)

func add_certificates(amount: int) -> int:
	certificates += amount
	var gained := 0
	while certificates >= certificates_to_next_level():
		certificates -= certificates_to_next_level()
		meta_level += 1
		unspent_points += 2
		gained += 1
	save_game()
	return gained

func certificates_to_next_level() -> int:
	return 45 + int(pow(meta_level, 1.35) * 24.0)

func xp_to_next_level() -> int:
	return certificates_to_next_level()

func spend_stat_point(stat_name: String) -> bool:
	if unspent_points <= 0 or not stats.has(stat_name):
		return false
	stats[stat_name] += 1
	unspent_points -= 1
	save_game()
	return true

func toggle_equipment(item_name: String) -> void:
	if not unlocked_equipment.has(item_name):
		unlocked_equipment.append(item_name)
	if equipped.has(item_name):
		equipped.erase(item_name)
	else:
		if equipped.size() >= 2:
			equipped.pop_front()
		equipped.append(item_name)
	save_game()
