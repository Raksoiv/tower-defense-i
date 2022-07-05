extends Resource
class_name GameSettings


var vol_scale := -60
export(float) var master_vol setget master_vol_set, master_vol_get
export(float) var music_vol setget music_vol_set, music_vol_get
export(float) var sound_vol setget sound_vol_set, sound_vol_get


func master_vol_set(new_value: float):
    master_vol = clamp(new_value, 0, 1)


func master_vol_get() -> float:
    return -60 + (master_vol * 60)


func music_vol_set(new_value: float):
    music_vol = clamp(new_value, 0, 1)


func music_vol_get() -> float:
    return -60 + (music_vol * 60)


func sound_vol_set(new_value: float):
    sound_vol = clamp(new_value, 0, 1)


func sound_vol_get() -> float:
    return -60 + (sound_vol * 60)
