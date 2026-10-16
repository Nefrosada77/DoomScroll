extends GutTest

#TESTE PARA ADIÇÃO DE HABILIDADE
func test_add_skill():
	var player = Player.new() #CRIAR PERSONAGEM PARA O TESTE
	var skill = load("res://skills/actives/Freeze.tres") #HABILIDADE ATIVA PARA O TESTE
	add_child_autofree(player) #ADICIONAR O PLAYER COMO NODO DA FASE
	player.skills.append(load("res://skills/actives/Freeze.tres")) #ADICIONAR 4 SKILLS PARA ENCHER A LISTA AO MAXIMO.
	player.skills.append(load("res://skills/actives/Freeze.tres"))
	player.skills.append(load("res://skills/actives/Freeze.tres"))
	player.skills.append(load("res://skills/actives/Freeze.tres"))
	if skill.skType == Skill.skillType.PASSIVE: #CHECAR SE A SKILL A SER ADICIONADA SERÁ UMA PASSIVA OU ATIVA, POIS SÃO ALOCADAS EM LUGARES DIFERENTES
		if len(player.passiveSkills) < 4: #VERIFICAR SE A LISTA DE HABILIDADES PASSIVAS ESTÁ NO MÁIMO
			player.passiveSkills.append(skill) #CASO NÃO ESTIVER, A HABILIDADE SERÁ ADICIONADA NA LISTA
	else:
		if len(player.skills) < 4: #VERIFICAR SE A LISTA DE HABILIDADES ATIVAS ESTÁ NO MÁIMO
			player.skills.append(skill) #CASO NÃO ESTIVER, A HABILIDADE SERÁ ADICIONADA NA LISTA
	assert_eq(player.passiveSkills, []) #VERIFICAR SE A LISTA ESTÁ VAZIA POIS NO TESTE NÃO SERÁ USADA UMA HABILIDADE PASSIVA
	assert_eq(player.skills, [load("res://skills/actives/Freeze.tres"),load("res://skills/actives/Freeze.tres"),load("res://skills/actives/Freeze.tres"),load("res://skills/actives/Freeze.tres")]) #VERIFICAR SE A LISTA ESTÁ COM APENAS A HABILIDADE PEDIDA PARA SER ADICIONADA, VAI FALHAR POIS NO TESTE A LISTA ESTÁ CHEIA

#TESTE PARA REMOÇÃO DE HABILIDADE
func test_remove_passive_skill():
	var player = Player.new()  #CRIAR PERSONAGEM PARA O TESTE
	add_child_autofree(player) #ADICIONAR O PLAYER COMO NODO DA FASE
	var skill = load("res://skills/passives/attack_plus.tres") #HABILIDADE PASSIVA PARA O TESTE 
	player.skills.append(load("res://skills/actives/Freeze.tres")) #HABILIDADE ATIVA PARA O TESTE 
	if skill.skType == Skill.skillType.PASSIVE: #CHECAR SE A SKILL A SER ADICIONADA SERÁ UMA PASSIVA OU ATIVA, POIS SÃO ALOCADAS EM LUGARES DIFERENTES
		if len(player.passiveSkills) > 0: #VERIFICA SE A LISTA DE HABILIDADES PASSIVAS ESTÁ VAZIA
			player.passiveSkills.erase(skill) #CASO NÃO ESTEJA SERÁ REMOVIDA A HABILIDADE DESEJADA
		
	else:
		if len(player.skills) > 0: #VERIFICA SE A LISTA DE HABILIDADES ATIVAS ESTÁ VAZIA
			player.skills.erase(skill) #CASO NÃO ESTEJA SERÁ REMOVIDA A HABILIDADE DESEJADA
	assert_eq(player.passiveSkills, []) #TESTA O RESULTADO
	assert_eq(player.skills, [load("res://skills/actives/Freeze.tres")]) #TESTA O RESULTADO PARA VER SE NÃO REMOVEU A HABILIDADE ERRADA

#TESTE PARA VER SE NÃO IRÁ ADICIONAR MAIS HABILIDADES QUE DEVERIA
func test_capacity():
	var player = Player.new() #CRIAR PERSONAGEM PARA O TESTE
	add_child_autofree(player) #ADICIONAR O PLAYER COMO NODO DA FASE
	var skill = load("res://skills/actives/Freeze.tres") #HABILIDADE ATIVA PARA O TESTE 
	for i in range(6): #PERCORRER MAIS QUE O LIMITE DE HABILIDADES
		if skill.skType == Skill.skillType.PASSIVE: #VERIFICA SE A LISTA DE HABILIDADES PASSIVAS ESTÁ VAZIA
			if len(player.passiveSkills) < 4: #VERIFICAR SE A LISTA DE HABILIDADES PASSIVAS ESTÁ NO MÁIMO
				player.passiveSkills.append(skill) #CASO NÃO ESTIVER, A HABILIDADE SERÁ ADICIONADA NA LISTA
		else:
			if len(player.skills) < 4: #VERIFICAR SE A LISTA DE HABILIDADES ATIVAS ESTÁ NO MÁIMO
				player.skills.append(skill) #CASO NÃO ESTIVER, A HABILIDADE SERÁ ADICIONADA NA LISTA
	assert_eq(player.passiveSkills, []) #TESTA O RESULTADO
	assert_eq(player.skills, [load("res	://skills/actives/Freeze.tres"),load("res://skills/actives/Freeze.tres"),load("res://skills/actives/Freeze.tres"),load("res://skills/actives/Freeze.tres")]) #ESPERADO TER APENAS 4 HABILIDADES NA LISTA
