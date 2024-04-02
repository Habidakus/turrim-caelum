extends Node

class_name PlayerWorth

var shipSpeed : float
var bulletsPerSecond : float
var bulletRange : float
var bulletSpeed : float
var bulletDamage : float
var autospendCount : int
var tchotchkeCount : int
var showPathDist : float

func is_world_possible(_cardData : CardData) -> bool:
	return true

func is_player_possible(lastTwentyCreatures, _cardData : CardData) -> bool:
	if showPathDist <= 0.5:
		#print("Rejecting ", cardData.cardName, " because of short show path (", showPathDist, ")")
		return false
	if bulletsPerSecond > 5.0:
		#print("Rejecting ", cardData.cardName, " because of too many bullets per minute (", 60.0 * bulletsPerSecond, ")")
		return false
	if bulletRange > 512.0:
		#print("Rejecting ", cardData.cardName, " because of bullet range too great (", bulletRange, ")")
		return false
	if shipSpeed > 800.0:
		#print("Rejecting ", cardData.cardName, " because of ship speed too great (", shipSpeed, ")")
		return false
	if bulletSpeed > 950.0:
		#print("Rejecting ", cardData.cardName, " because of bullet speed too great (", bulletSpeed, ")")
		return false
	if shipSpeed >= bulletSpeed:
		#print("Rejecting ", cardData.cardName, " because of ship speed (", shipSpeed, ") greater than bullet speed (", bulletSpeed, ")")
		return false
	if autospendCount > 1:
		#print("Rejecting ", cardData.cardName, " because we already have autospend")
		return false
	if tchotchkeCount > 1:
		#print("Rejecting ", cardData.cardName, " because we already have tchotchke")
		return false
	
	var earliest = 0
	var latest = 0
	var shotsTaken : int = 0
	var playerCanDamageAllMobs : bool = true
	var creatureCount : int = lastTwentyCreatures.size()
	if creatureCount > 10:
		for previousMob in lastTwentyCreatures:
			# [0] = sec created
			# [1] = hp
			# [2] = armor
			# [3] = shields
			# [4] = children
			if earliest == 0:
				earliest = previousMob[0]
				latest = previousMob[0]
			elif previousMob[0] > latest:
				latest = previousMob[0]
			elif previousMob[0] < earliest:
				earliest = previousMob[0]
			var damagePastArmor : float = (self.bulletDamage - previousMob[2])
			if damagePastArmor > 0.0:
				var shotsToKill : int = (int(ceilf(previousMob[1] / damagePastArmor)) + previousMob[3])
				if previousMob[4] > 0:
					shotsToKill *= (1 + previousMob[4])
				shotsTaken += shotsToKill
			else:
				playerCanDamageAllMobs = false
		var timeNeededToKillWithPerfectShots : float = shotsTaken / bulletsPerSecond
		var timeSpanOfLastTwentyBeasts : float = creatureCount * (latest - earliest) / (creatureCount - 1.0)
		if playerCanDamageAllMobs:
			if timeNeededToKillWithPerfectShots < timeSpanOfLastTwentyBeasts:
				print(_cardData.cardName, " needs ", int(round(timeNeededToKillWithPerfectShots)), " seconds to kill the beasts generated in the last ", int(round(timeSpanOfLastTwentyBeasts)))
				return false;
	# If it passes all our checks, it's a fine player state
	return true
