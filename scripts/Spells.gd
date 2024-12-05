extends Node

# Define spell identifiers using an enum
enum Spell {
	FIREBOLT,
	HEAL,
	MAGIC_MISSILE
}

# Map spell identifiers to their descriptions
const SPELL_DESCRIPTIONS = {
	Spell.FIREBOLT: "fire bolt",
	Spell.HEAL: "cleanse my weakness",
	Spell.MAGIC_MISSILE: "magic missile"
}

func fuzzy_match_spell(input_string: String, threshold: float = 0.7) -> Spell:
	var best_match = -1
	var highest_score = 0.0
	
	for spell_id in SPELL_DESCRIPTIONS.keys():
		var description = SPELL_DESCRIPTIONS[spell_id]
		var score = similarity_ratio(input_string, description)
		
		if score > highest_score:
			highest_score = score
			best_match = spell_id
	
	if highest_score >= threshold:
		return best_match
	else:
		return -1  # Unknown spell


func similarity_ratio(a: String, b: String) -> float:
	var len_a = a.length()
	var len_b = b.length()
	var dp = PackedInt64Array()
	
	# Initialize dynamic programming table
	for i in range(len_a + 1):
		dp.append(i)
	
	for i in range(1, len_b + 1):
		var prev = dp[0]
		dp[0] = i
		for j in range(1, len_a + 1):
			var temp = dp[j]
			if a[j - 1] == b[i - 1]:
				dp[j] = prev
			else:
				dp[j] = min(dp[j - 1], dp[j], prev) + 1
			prev = temp
	
	# Levenshtein distance
	var lev_distance = dp[len_a]
	# Normalize similarity ratio
	var max_len = max(len_a, len_b)
	return 1.0 - float(lev_distance) / max_len
