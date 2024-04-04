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
var smartWeaponCount : int

func is_possible(lastTwentyCreatures, cardData: CardData, map: Map, dump : bool) -> bool:
	if cardData.does_change_player_or_bullet_speed():
		if !is_possible_player_or_bullet_speed(cardData, dump):
			return false
	if cardData.does_reference_map():
		if !is_possible_map(cardData, map, dump):
			return false
	if cardData.does_change_range():
		if !is_possible_range(cardData, dump):
			return false
	if cardData.does_change_player_charges():
		if !is_possible_player_charges(cardData, dump):
			return false
	if cardData.does_change_dps():
		if !is_possible_dps(lastTwentyCreatures, cardData, dump):
			return false

	if dump:
		print("Accepting ", cardData.cardName, " as a world card");

	return true

func is_possible_map(cardData : CardData, map : Map, dump: bool) -> bool:
	if cardData.does_requires_castle() && map.has_castle() == false:
		if dump:
			print("Rejecting ", cardData.cardName, " because no castle on map")
		return false
	return true

func is_possible_player_or_bullet_speed(cardData : CardData, dump: bool) -> bool:
	if shipSpeed > 800.0:
		if dump:
			print("Rejecting ", cardData.cardName, " because of ship speed too great (", shipSpeed, ")")
		return false
	if bulletSpeed > 950.0:
		if dump:
			print("Rejecting ", cardData.cardName, " because of bullet speed too great (", bulletSpeed, ")")
		return false
	if shipSpeed >= bulletSpeed:
		if dump:
			print("Rejecting ", cardData.cardName, " because of ship speed (", shipSpeed, ") greater than bullet speed (", bulletSpeed, ")")
		return false
	else:
		return true

func is_possible_range(cardData : CardData, dump: bool) -> bool:
	if bulletRange > 512.0:
		if dump:
			print("Rejecting ", cardData.cardName, " because of bullet range too great (", bulletRange, ")")
		return false
	if showPathDist <= 0.5:
		if dump:
			print("Rejecting ", cardData.cardName, " because of short show path (", showPathDist, ")")
		return false
	else:
		return true

func is_possible_player_charges(cardData : CardData, dump: bool) -> bool:
	if autospendCount > 1:
		if dump:
			print("Rejecting ", cardData.cardName, " because we already have autospend")
		return false
	if tchotchkeCount > 1:
		if dump:
			print("Rejecting ", cardData.cardName, " because we already have tchotchke")
		return false
	if smartWeaponCount > 1:
		if dump:
			print("Rejecting ", cardData.cardName, " because smart weapon on cooldown")
		return false
	return true

func is_possible_dps(lastTwentyCreatures, cardData : CardData, dump: bool) -> bool:
	if bulletsPerSecond > 5.0:
		if dump:
			print("Rejecting ", cardData.cardName, " because of too many bullets per minute (", 60.0 * bulletsPerSecond, ")")
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
			if timeNeededToKillWithPerfectShots * 1.166 < timeSpanOfLastTwentyBeasts:
				if dump:
					print(cardData.cardName, " is ", round(100.0 * timeSpanOfLastTwentyBeasts / timeNeededToKillWithPerfectShots) / 100.0, " times more efficient than current monsters")
				return false
	return true
