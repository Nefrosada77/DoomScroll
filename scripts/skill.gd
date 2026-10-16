extends Resource
class_name Skill

enum skillHit {SINGLEENEMY, RANDENEMY, ALLENEMY, SINGLEALLY, ALLALLY, ALL, NONE}
enum skillType {ATTACK, PASSIVE, SUPPORT, HEAL}

@export var skID : int
@export_range(0.0, 1, 0.01) var use_weight : float
@export var SkName : String
@export var SkDesc : String
@export var SkCost : int
@export var skType : skillType
@export var skPower : int
@export var SkHit : skillHit
@export_range(.0,1.,0.01) var crit_bonus : float = .0
@export var minhits : int = 1
@export var maxhits : int = 1
@export var SkIcon : Texture2D
@export var reward : bool = false
@export var sellable : bool = false
@export_range(0.0, 1, 0.001) var reward_chance : float
