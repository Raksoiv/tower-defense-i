extends Resource
class_name GameSettings


var vol_scale := -60
export(float) var master_vol
export(float) var music_vol setget music_vol_set, music_vol_get
export(float) var sound_vol setget sound_vol_set, sound_vol_get


func music_vol_set(new_value: float):
    music_vol = new_value


func music_vol_get() -> float:
    return -60 + (music_vol * master_vol * 60)


func sound_vol_set(new_value: float):
    sound_vol = new_value


func sound_vol_get() -> float:
    return -60 + (sound_vol * master_vol * 60)
