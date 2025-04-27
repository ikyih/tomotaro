--[[
------------------------------Basic Table of Contents------------------------------
Line 17, Atlas ---------------- Explains the parts of the atlas.
Line 29, Joker 2 -------------- Explains the basic structure of a joker
Line 88, Runner 2 ------------- Uses a bit more complex contexts, and shows how to scale a value.
Line 127, Golden Joker 2 ------ Shows off a specific function that's used to add money at the end of a round.
Line 163, Merry Andy 2 -------- Shows how to use add_to_deck and remove_from_deck.
Line 207, Sock and Buskin 2 --- Shows how you can retrigger cards and check for faces
Line 240, Perkeo 2 ------------ Shows how to use the event manager, eval_status_text, randomness, and soul_pos.
Line 310, Walkie Talkie 2 ----- Shows how to look for multiple specific ranks, and explains returning multiple values
Line 344, Gros Michel 2 ------- Shows the no_pool_flag, sets a pool flag, another way to use randomness, and end of round stuff.
Line 418, Cavendish 2 --------- Shows yes_pool_flag, has X Mult, mainly to go with Gros Michel 2.
Line 482, Castle 2 ------------ Shows the use of reset_game_globals and colour variables in loc_vars, as well as what a hook is and how to use it.
--]]

--Creates an atlas for cards to use
SMODS.Atlas {
	-- Key for code to find it with
	key = "ModdedVanilla",
	-- The name of the file, for the code to pull the atlas from
	path = "ModdedVanilla.png",
	-- Width of each sprite in 1x size
	px = 70,
	-- Height of each sprite in 1x size
	py = 94
}


SMODS.Joker {
	key = 'houses',
	loc_txt = {
		name = 'Mii Homes',
		text = {
			"On the first blind every ante, the first card played will be doubled."
		}
	},
	config = { extra = { mult = 4 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.mult } }
	end,
	rarity = 1,
	atlas = 'ModdedVanilla',
	pos = { x = 0, y = 0 },
	cost = 2,
	calculate = function(self, card, context)
		if context.cardarea == G.play and context.repetition and not context.repetition_only and (
                context.other_card == context.scoring_hand[1]) and G.GAME.blind.name == 'Small Blind' then
			if context.other_card:is_2() or context.other_card:is_3() or context.other_card:is_4() or context.other_card:is_5() or context.other_card:is_6() or context.other_card:is_7() or context.other_card:is_8() or context.other_card:is_9() or context.other_card:is_10() or context.other_card:is_J() or context.other_card:is_K() or context.other_card:is_Q() or context.other_card:is_A() then
				return {
					message = 'Again!',
					repetitions = card.ability.extra.repetitions,
					card = context.other_card
				}
			end
		end
	end
}


SMODS.Joker {
	key = 'roof',
	loc_txt = {
		name = 'The Roof',
		text = {
			"Creates a {C:tarot}Tarot{} not in your collection",
			"or gives an {C:tarot}Arcana Pack{} when sold."
		}
	},
	config = {},
	rarity = 1,
	atlas = 'ModdedVanilla',
	pos = { x = 1, y = 0 },
	cost = 3,
	loc_vars = function(self, info_queue, card)
		return {}
	end,
	calculate = function(self, card, context)
		if context.selling_self then
			local all_tarots_owned = true
			for _, tarot in ipairs(G.P_CENTERS['Tarot']) do
				if not G.COLLECTIONS.TAROT[tarot.key] then
					all_tarots_owned = false
					break
				end
			end

			if all_tarots_owned then
				-- Give Arcana Pack
				G.E_MANAGER:add_event(Event({
					func = function()
						G.GAME.pack_choices = {G.P_CENTERS["Arcana"]}
						G.STATE = G.STATES.PACK_SELECT
						return true
					end
				}))
				return {
					message = "Arcana Pack!"
				}
			else
				local available_tarots = {}
				for _, tarot in ipairs(G.P_CENTERS['Tarot']) do
					if not G.COLLECTIONS.TAROT[tarot.key] then
						table.insert(available_tarots, tarot)
					end
				end
				if #available_tarots > 0 then
					local chosen_tarot = pseudorandom_element(available_tarots)
					G.hand:add_card(Card(G.CARD_SET.TAROT, chosen_tarot.key))
					return {
						message = "Tarot!"
					}
				end
			end
		end
	end
}

SMODS.Joker {
	key = 'miiapartments',
	loc_txt = {
		name = 'Mii Apartments',
		text = {
			"Played cards have a {C:attention}1 in 4{} chance to be",
			"{C:attention}Polychrome{}, {C:blue}Foil{}, {C:purple}Holographic{},",
			"or {C:dark_edition}Debuffed{} for one turn."
		}
	},
	config = {},
	rarity = 2,
	atlas = 'ModdedVanilla',
	pos = { x = 2, y = 0 },
	cost = 6,
	loc_vars = function(self, info_queue, card)
		return {}
	end,
	calculate = function(self, card, context)
		if context.cardarea == G.play and context.other_card and not context.before then
			if pseudorandom(1, 4) == 1 then -- 1 in 4 chance
				local effects = {"Polychrome", "Foil", "Holographic", "Negative"}
				local chosen_effect = pseudorandom_element(effects)
				
				if chosen_effect == "Polychrome" then
					context.other_card:set_edition({G.E_POLYCHROME})
				elseif chosen_effect == "Foil" then
					context.other_card:set_edition({G.E_FOIL})
				elseif chosen_effect == "Holographic" then
					context.other_card:set_edition({G.E_HOLOGRAPHIC})
				elseif chosen_effect == "Negative" then
					context.other_card:set_edition({G.E_NEGATIVE})
				end
				
				return {
					message = chosen_effect .. "!",
					card = context.other_card
				}
			end
		end
	end
}