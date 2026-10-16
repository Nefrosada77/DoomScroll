extends GutTest

func test_combat():
	var test_player = Player.new() #CRIA O PLAYER PARA O TESTE
	add_child_autoqfree(test_player) #ADICIONA O PLAYER COMO NODO
	var test_enemy = Enemy.new() #CRIA O INIMIGO PARA O TESTE
	test_enemy.currHP = 15 #VIDA DO INIMIGO ESTÁ E 15 PARA RECEBER MAIS DANO DO QUE O MAXIMO			
	add_child_autoqfree(test_enemy) #ADICIONA O INIMIGO COMO NODO
	var freeze_skill : Skill = load("res://skills/actives/Freeze.tres") #HABILIDADE PARA O TESTE
	test_player.currMP -= freeze_skill.SkCost #RETIRAR O MP / MANA QUE O JOGADOR USARÁ PARA USAR A HABILIDADE		
	assert_eq(test_player.currMP, 0, "player's current MP should be") #MANA RESTANTE DO PLAYER DEPOIS DE USAR HABILIDADE É O QUE QUERIAMOS
	var damage = (((2 * float(test_player.curr_attack) + 2) * freeze_skill.skPower) / 50) * ((float(test_player.curr_attack) / test_enemy.curr_defense) + 2) #CALCULO DE DANO
	assert_eq(damage,18) # TESTA SE O DANO CALCULADO É O QUE QUEREMOS
	test_enemy.currHP -= damage #RETIRA A VIDA DO INIIMGO BASIADA NO DANO
	if test_enemy.currHP < 0: #VERIFICA SE O PLAYER DEU MAIS DANO QUE A VIDA DO INIMIGO
		test_enemy.currHP = 0 #DEIXA ZERADA PARA NÃO SER MENOR QUE ZERO
	assert_eq(test_enemy.currHP, 0) #VIDA DO INIMIGO É O QUE ESPERAVAMOS

func test_crit_chance():
	var crits : int = 0 #QUANTIDADE DE CRITICOS NO TESTE
	var test_player = Player.new() #CRIA O PLAYER PARA O TESTE
	add_child_autoqfree(test_player) #ADICIONA O PLAYER COMO NODO
	var test_skill : Skill = load("res://skills/actives/Freeze.tres")  #HABILIDADE PARA O TESTE
	var crit : bool
	for i in range(100): #TESTA 100 VEZES
		crit = 0.01 + test_skill.crit_bonus + test_player.crit_chance > randf_range(.0, 1.) #CHANCE DE CRITICO
		if crit: #SE CRITICO ADICIONA 1 PARA A CONTAGEM
			crits += 1
	assert_almost_eq(crits, 1, 1, "crit chance should be close to") #ESERADO É QUE ACERTE CRITICO 1% DAS VEZES COM UM INTERVALO DE ERRO DE 1%
