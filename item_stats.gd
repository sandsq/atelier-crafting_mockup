extends VBoxContainer

func draw_bonuses(bonuses: Dictionary[Stats.WeaponStats, int]):
	for label_child in self.get_children():
		label_child.queue_free()
	for bonus_stat in bonuses:
		var stat_label = Label.new()
		## this will be integers because the enums don't have names. fix this later
		stat_label.text = "%s: +%s" % [bonus_stat, bonuses[bonus_stat]]
		self.add_child(stat_label)
