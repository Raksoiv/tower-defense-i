extends Resource
class_name GameSettings


var vol_min := 0.1
var vol_max := 1

export(float) var master_vol setget master_vol_set, master_vol_get
export(float) var music_vol setget music_vol_set, music_vol_get
export(float) var sound_vol setget sound_vol_set, sound_vol_get

# Converts range [0.1, 1] to [-60, 0] in a log curve
func _vol_to_db(vol: float) -> float:
	return 26 * log(vol)


func master_vol_set(new_value: float):
	master_vol = clamp(new_value, vol_min, vol_max)
	AudioServer.set_bus_volume_db(0, _vol_to_db(master_vol))


func master_vol_get() -> float:
	return _vol_to_db(master_vol)


func master_vol_real() -> float:
	return master_vol


func music_vol_set(new_value: float):
	music_vol = clamp(new_value, vol_min, vol_max)
	AudioServer.set_bus_volume_db(1, _vol_to_db(music_vol))


func music_vol_get() -> float:
	return _vol_to_db(music_vol)


func music_vol_real() -> float:
	return music_vol


func sound_vol_set(new_value: float):
	sound_vol = clamp(new_value, vol_min, vol_max)
	AudioServer.set_bus_volume_db(2, _vol_to_db(sound_vol))


func sound_vol_get() -> float:
	return _vol_to_db(sound_vol)


func sound_vol_real() -> float:
	return sound_vol
