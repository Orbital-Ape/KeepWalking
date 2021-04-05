
var entity = [{"group": "Red Head", "name": "Conscript", "Type": "Human", "Level": 1, "atributes": {
        "initiative": 2, 
        "speed": 2, 
        "mind": 1, 
        "strength": 1, 
        "perception": 2, 
        "endurance": 1}, "appearance": "conscript.png"},
    {"group": "Red Head", "name": "Comrade", "Type": "Human", "Level": 3, "atributes": {
        "initiative": 3, 
        "speed": 3, 
        "mind": 3, 
        "strength": 2, 
        "perception": 3, 
        "endurance": 3}, "appearance": "comrade.png"}
]

#groups will be stored by "name" in every map terrain - tile -, spawning pool
#then they'll be given to the Main on encounters for spawning purpose
var groups = [
    {"name": "Red Head Conscripting Party", "entities": ["conscript", "conscript", "comrade"], 
    "positioning_area": [Rect2(Vector2(48, 36), Vector2(37, 37)), Rect2(Vector2(128, 36), Vector2(37, 37)), 
    Rect2(Vector2(80, 48), Vector2(48, 32))]}
]