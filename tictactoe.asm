### JOGO DA VELHA
##
## @author Bruno Adriano
##         Geovana Silveira
##
## Instrucoes:
## Abra o Bitmap Display
## Configuracoes do Bitmap:
## Unit Width in Pixels : 1
## Unit Height in Pixels: 1
## Display Width in Pixels: 256
## Display Height in Pixels: 256
## Base address for display: 0x10010000(static data)
##
## OBS:
## Jogador 1: X
## Jogador 2: O

##### As posicoes informadas pelos jogadores serao interpretadas da seguinte forma no tabuleiro:
##### 7 | 8 | 9
##### 4 | 5 | 6
##### 1 | 2 | 3


### Os seguintes dados foram salvos em kdata para evitar conflito com as posicoes .data que foram utilizadas para desenhar a interface 
.kdata 
	valores: .word 0, 0, 0, 0, 0, 0, 0, 0, 0 #Valores das jogadas (1 = x, 2 = 0)
	descricao: .asciiz "JOGO DA VELHA! O primeiro jogador a formar uma sequencia na diagonal, vertical ou horizontal ganha.\n"	
	informePosicao: .asciiz "Digite uma posição [1 - 9]:"	
	posicaoinvalida_msg: .asciiz "Posicao invalida!\n"
	jogador1_msg: .asciiz "Digite uma posição jogador 1: "
	jogador2_msg: .asciiz "Digite uma posição jogador 2: "
	fimjogadas_msg: .asciiz "Deu velha!\n"
	jogador1venceu_msg: .asciiz "Jogador 1 venceu!\n"
	jogador2venceu_msg: .asciiz "Jogador 2 venceu!\n"
	jogarnovamente_msg: .asciiz "Deseja jogar novamente? \n"
	
.text
.globl main
main:

	#Carrega valores essenciais
	la $s0, valores #ENDEREÇO DOS VALORES
	li $s1, 1 #CONTADOR DE JOGADAS

	#Exibe mensagem inicial
	li $v0, 4
	la $a0, descricao
	syscall
	
	#Carrega tabuleiro
	jal imprime_tabuleiro
	nop
	
jogada_jogador1:
	#Pergunta a jogada ao jogador1
	li $v0, 4
	la $a0, jogador1_msg
	syscall
	
	#Le a jogada do jogador 1
	li $v0, 5
	syscall
	move $a0, $v0
	#Guarda em s2 a jogada
	move $s2, $v0
	
	#Pula para checar se jogada é valida
	jal checar_jogada_valida
	nop
	beq $v0, 1, jogada_foi_validada
	nop
	#Se a jogada nao for valida exibe mensagem e le jogada novamente
	li $v0, 4
	la $a0, posicaoinvalida_msg
	syscall
	j jogada_jogador1
	nop
	#Se a jogada foi valida ele registra a jogada na memoria e desenha no bitmap
jogada_foi_validada:
	li $a0, 1
	jal registrar_jogada
	nop
	move $a2, $s2 #Move para a2 a posicao que deve ser desenhado no bitmap
	jal desenha_xis
	nop

##### AQUI VAO CHECAGENS #####
	li $v1, 0
	#Pula para checar se ele venceu
	jal checar_jogador1_venceu
	nop
	beq $v1, 1, fim
	nop
	#Pula para checar se jogadas > 9
	jal checar_fim_das_jogadas
	nop
	beq $v1, 1, fim
	nop

#############################
jogada_jogador2:
	#Pergunta ao jogador2
	li $v0, 4
	la $a0, jogador2_msg
	syscall
	
	#Le a jogada do jogador2
	li $v0, 5
	syscall
	move $a0, $v0
	move $s3, $v0 #Salva em s3 a pos da jogada
	jal checar_jogada_valida
	nop
	beq $v0, 1, jogada_foi_validada2
	nop
	li $v0, 4
	la $a0, posicaoinvalida_msg
	syscall
	j jogada_jogador2
	nop
	
jogada_foi_validada2:
	li $a0, 2
	jal registrar_jogada
	nop
	move $a2, $s3
	jal desenha_y
	nop
	
##### SEGUNDA PARTE CHECAGENS #######
	li $v1, 0

	jal checar_jogador2_venceu
	nop
	beq $v1, 1, fim
	nop

	jal checar_fim_das_jogadas
	nop
	beq $v1, 1, fim
	nop
	
	j jogada_jogador1
	nop	
	
#### AQUI VAO CHECAGENS ####	
			
fim:
	li $v0, 50
	la $a0, jogarnovamente_msg
	syscall
	
	beq $a0, 0, zerar_tudo
	nop

	li $v0, 10
	syscall
				
					
						
							
									
############## IMPRIME TABULEIRO #######################################################	
imprime_tabuleiro:
# PASSANDO A COR DESEJADA EM HEXADECIMAL
li $t1, 0x00FF00
#Endereco inicial onde sera desenhado
lui $t0, 0x1001
#1024 x 80 equivale a distancia vertical do inicio do bitmap e aonde sera desenhado o primeiro pixel
li $t5, 1024
li $t6, 80
mult $t5, $t6
mflo $t6
#VERTICAL
add $t0, $t0, $t6
#HORIZONTAL
#A soma do endereco inicial com 56 significa incrementar em 56 pixels a distancia horizontal
addi $t0, $t0, 56
# contador
li $t2, 0
primeira_linha_horizontal:
	# STORE NA COR NO ENDEREÇO DESEJADO
	sw $t1, 0($t0)
	# AUMENTANDO DE 4 EM 4 PARA IR PARA A DIREITA
	addi $t0, $t0, 4
	# INCRIMENTAR CONTADOR
	addi $t2, $t2, 1
	bne $t2, 224, primeira_linha_horizontal
	nop
	
#Muda a posição para a segunda linha
lui $t0, 0x1001
li $t5, 1024
li $t6, 150
mult $t5, $t6
mflo $t6
#VERTICAL
add $t0, $t0, $t6
#Horizontal
addi $t0, $t0, 56
li $t2, 0
segunda_linha_horizontal:
	sw $t1, 0($t0)
	addi $t0, $t0, 4
	addi $t2, $t2, 1
	bne $t2, 224, segunda_linha_horizontal
	nop
# Desenha linhas verticais
lui $t0, 0x1001
li $t6, 10
mult $t5, $t6
mflo $t6
#VERTICAL
add $t0, $t0, $t6
#HORIZONTAL
addi $t0, $t0, 320
li $t2, 0
primeira_linha_vertical:
	addi $t0, $t0, 1024
	sw $t1, 0($t0)
	addi $t2, $t2, 1
	bne $t2, 200, primeira_linha_vertical
	nop
	
lui $t0, 0x1001
#HORIZONTAL
addi $t0, $t0, 660
li $t2, 0
#vertical
li $t6, 10
mult $t5, $t6
mflo $t6
add $t0, $t0, $t6
segunda_linha_vertical:
	addi $t0, $t0, 1024
	sw $t1, 0($t0)
	addi $t2, $t2, 1
	bne $t2, 200, segunda_linha_vertical
	nop


	jr $ra
	nop

#########################################################################################




#################### CHECAR JOGADA VALIDA ############################

checar_jogada_valida:
	#Checa se número é >= 1
	move $t0, $a0
	bge $t0, 1, validade_1
	nop
	j jogada_invalida
	nop

	#Checa se número é <= 9	
validade_1:
	ble $t0, 9, validade_2
	nop
	j jogada_invalida
	nop
	
validade_2:
	#Checa se campo já foi preenchido
	subu $t1, $t0, 1
	li $t2, 4 #tamanho do word
	mult $t1, $t2
	mflo $t3
	la $t4, valores
	add $t4, $t4, $t3
	lw $t5, 0($t4) # $t5 Carrega o valor da memoria referente a posição selecionada pelo jogador
	beq $t5, $0, jogada_valida #Se o campo na memória for 0, a jogada é valida
	nop
	j jogada_invalida
	nop
	
	#Se a jogada for invalida retorna 0
jogada_invalida:	
	li $v0, 0
	jr $ra
	nop
	#Se a jogada for valida retorna 1
jogada_valida:
	li $v0, 1
	jr $ra
	nop
	
###################################################################################



####################### JOGADA VALIDADA ############################################
registrar_jogada:
	#Se a0 = 1 jogada efetuada pelo jogador1, se a0 = 2 jogada efetuada pelo jogador2
	beq $a0, 1, jogada_efetuada_pelo_jogador1
	nop
	beq $a0, 2, jogada_efetuada_pelo_jogador2
	nop

jogada_efetuada_pelo_jogador1:
	addi $s1, $s1, 1 #Incrementa contador de jogadas
	la $t0, valores
	li $t1, 1
	li $t2, 4
	move $t3, $s2
	subu $t3, $t3, 1
	mult $t3, $t2
	mflo $t4
	add $t0, $t0, $t4
	sw $t1, 0($t0)
	jr $ra
	nop
	
jogada_efetuada_pelo_jogador2:
	addi $s1, $s1, 1 #Incrementa contador de jogadas
	la $t0, valores
	li $t1, 2
	li $t2, 4
	move $t3, $s3
	subu $t3, $t3, 1
	mult $t3, $t2
	mflo $t4
	add $t0, $t0, $t4
	sw $t1, 0($t0)
	jr $ra
	nop
	
######################################################################################

############# CHECAR FIM DAS JOGADAS #################################################
checar_fim_das_jogadas:	
	li $t0, 10
	beq $s1, $t0, fim_das_jogadas
	nop
	
	li $v1, 0
	jr $ra
	nop
	
fim_das_jogadas:

	li $v0, 4
	la $a0, fimjogadas_msg
	syscall
	
	li $v1, 1
	jr $ra
	nop
	
#####################################################################################


################# CHECAR JOGADOR 1 VENCEU ##########################################
# Se for encontrado uma sequencia de 1,1,1 na memoria referente a uma linha horizontal, vertical ou diagonal, entao o jogador1 venceu
checar_jogador1_venceu:
	la $t0, valores
	lw $t1, 0($t0)
	lw $t2, 4($t0)
	lw $t3, 8($t0)
	
primeira_tentativa_jogador1:
	beq $t1, 1, jogador1_valido1
	nop
	j segunda_tentativa
	nop
jogador1_valido1:
	beq $t2, 1, jogador1_valido2
	nop
	j segunda_tentativa
	nop
jogador1_valido2:
	beq $t3, 1, jogador1_venceu
	nop
	j segunda_tentativa
	nop
segunda_tentativa:
	lw $t1, 12($t0)
	lw $t2, 16($t0)
	lw $t3, 20($t0)
	beq $t1, 1, jogador1_valido1_segunda
	nop
	j terceira_tentativa
	nop
jogador1_valido1_segunda:
	beq $t2, 1, jogador1_valido2_segunda
	nop
	j terceira_tentativa
	nop
jogador1_valido2_segunda:
	beq $t3, 1, jogador1_venceu
	nop
	j terceira_tentativa
	nop
terceira_tentativa:
	lw $t1, 24($t0)
	lw $t2, 28($t0)
	lw $t3, 32($t0)
	beq $t1, 1, jogador1_valido1_terceira
	nop
	j quarta_tentativa
	nop
jogador1_valido1_terceira:
	beq $t2, 1, jogador1_valido2_terceira
	nop
	j quarta_tentativa
	nop
jogador1_valido2_terceira:
	beq $t3, 1, jogador1_venceu
	nop
	j quarta_tentativa
	nop
quarta_tentativa: #TESTAR AS VERTICAIS AGORA
	lw $t1, 0($t0)
	lw $t2, 12($t0)
	lw $t3, 24($t0)
	beq $t1, 1, jogador1_valido1_quarta
	nop
	j quinta_tentativa
	nop
jogador1_valido1_quarta:
	beq $t2, 1, jogador1_valido2_quarta
	nop
	j quinta_tentativa
	nop
jogador1_valido2_quarta:
	beq $t3, 1, jogador1_venceu
	nop
	j quinta_tentativa
	nop
quinta_tentativa:
	lw $t1, 4($t0)
	lw $t2, 16($t0)
	lw $t3, 28($t0)
	beq $t1, 1, jogador1_valido1_quinta
	nop
	j sexta_tentativa
	nop
jogador1_valido1_quinta:
	beq $t2, 1, jogador1_valido2_quinta
	nop
	j sexta_tentativa
	nop
jogador1_valido2_quinta:
	beq $t3, 1, jogador1_venceu
	nop
	j sexta_tentativa
	nop
sexta_tentativa:
	lw $t1, 8($t0)
	lw $t2, 20($t0)
	lw $t3, 32($t0)
	beq $t1, 1, jogador1_valido1_sexta
	nop
	j setima_tentativa
	nop
jogador1_valido1_sexta:
	beq $t2, 1, jogador1_valido2_sexta
	nop
	j setima_tentativa
	nop
jogador1_valido2_sexta:
	beq $t3, 1, jogador1_venceu
	nop
	j setima_tentativa
	nop
setima_tentativa: #testar diagonais agora
	lw $t1, 0($t0)
	lw $t2, 16($t0)
	lw $t3, 32($t0)
	beq $t1, 1, jogador1_valido1_setima
	nop
	j oitava_tentativa
	nop
jogador1_valido1_setima:
	beq $t2, 1, jogador1_valido2_setima
	nop
	j oitava_tentativa
	nop
jogador1_valido2_setima:
	beq $t3, 1, jogador1_venceu
	nop
	j oitava_tentativa
	nop
oitava_tentativa:
	lw $t1, 8($t0)
	lw $t2, 16($t0)
	lw $t3, 24($t0)
	beq $t1, 1, jogador1_valido1_oitava
	nop
	j jogador1_nao_ganhou
	nop
jogador1_valido1_oitava:
	beq $t2, 1, jogador1_valido2_oitava
	nop
	j jogador1_nao_ganhou
	nop
jogador1_valido2_oitava:
	beq $t3, 1, jogador1_venceu
	nop
	j jogador1_nao_ganhou
	nop
jogador1_nao_ganhou:
	li $v1, 0
	jr $ra
	nop
jogador1_venceu:
	li $a1, 1
	li $v0, 55
	la $a0, jogador1venceu_msg
	syscall

	li $v1, 1
	jr $ra
	nop
	
####################################################################################


############### CHECAR JOGADOR 2 VENCEU ############################################
# Se for encontrado uma sequencia de 1,1,1 na memoria referente a uma linha horizontal, vertical ou diagonal, entao o jogador2 venceu
checar_jogador2_venceu:
	la $t0, valores
	lw $t1, 0($t0)
	lw $t2, 4($t0)
	lw $t3, 8($t0)
	
primeira_tentativa_jogador2:
	beq $t1, 2, jogador2_valido
	nop
	j segunda_tentativa_j2
	nop
jogador2_valido:
	beq $t2, 2, jogador2_valido2
	nop
	j segunda_tentativa_j2
	nop
jogador2_valido2:
	beq $t3, 2, jogador2_venceu
	nop
	j segunda_tentativa_j2
	nop
segunda_tentativa_j2:
	lw $t1, 12($t0)
	lw $t2, 16($t0)
	lw $t3, 20($t0)
	beq $t1, 2, jogador2_valido1_segunda
	nop
	j terceira_tentativa_j2
	nop
jogador2_valido1_segunda:
	beq $t2, 2, jogador2_valido2_segunda
	nop
	j terceira_tentativa_j2
	nop
jogador2_valido2_segunda:
	beq $t3, 2, jogador2_venceu
	nop
	j terceira_tentativa_j2
	nop
terceira_tentativa_j2:
	lw $t1, 24($t0)
	lw $t2, 28($t0)
	lw $t3, 32($t0)
	beq $t1, 2, jogador2_valido1_terceira
	nop
	j quarta_tentativa_j2
	nop
jogador2_valido1_terceira:
	beq $t2, 2, jogador2_valido2_terceira
	nop
	j quarta_tentativa_j2
	nop
jogador2_valido2_terceira:
	beq $t3, 2, jogador2_venceu
	nop
	j quarta_tentativa_j2
	nop
quarta_tentativa_j2:
	lw $t1, 0($t0)
	lw $t2, 12($t0)
	lw $t3, 24($t0)
	beq $t1, 2, jogador2_valido1_quarta
	nop
	j quinta_tentativa_j2
	nop
jogador2_valido1_quarta:
	beq $t2, 2, jogador2_valido2_quarta
	nop
	j quinta_tentativa_j2
	nop
jogador2_valido2_quarta:
	beq $t3, 2, jogador2_venceu
	nop
	j quinta_tentativa_j2
	nop
quinta_tentativa_j2:
	lw $t1, 4($t0)
	lw $t2, 16($t0)
	lw $t3, 28($t0)
	beq $t1, 2, jogador2_valido1_quinta
	nop
	j sexta_tentativa_j2
	nop
jogador2_valido1_quinta:
	beq $t2, 2, jogador2_valido2_quinta
	nop
	j sexta_tentativa_j2
	nop
jogador2_valido2_quinta:
	beq $t3, 2, jogador2_venceu
	nop
	j sexta_tentativa_j2
	nop
sexta_tentativa_j2:
	lw $t1, 8($t0)
	lw $t2, 20($t0)
	lw $t3, 32($t0)
	beq $t1, 2, jogador2_valido1_sexta
	nop
	j setima_tentativa_j2
	nop
jogador2_valido1_sexta:
	beq $t2, 2, jogador2_valido2_sexta
	nop
	j setima_tentativa_j2
	nop
jogador2_valido2_sexta:
	beq $t3, 2, jogador2_venceu
	nop
	j setima_tentativa_j2
	nop
setima_tentativa_j2:
	lw $t1, 0($t0)
	lw $t2, 16($t0)
	lw $t3, 32($t0)
	beq $t1, 2, jogador2_valido1_setima
	nop
	j oitava_tentativa_j2
	nop
jogador2_valido1_setima:
	beq $t2, 2, jogador2_valido2_setima
	nop
	j oitava_tentativa_j2
	nop
jogador2_valido2_setima:
	beq $t3, 2, jogador2_venceu
	nop
	j oitava_tentativa_j2
	nop
oitava_tentativa_j2:
	lw $t1, 8($t0)
	lw $t2, 16($t0)
	lw $t3, 24($t0)
	beq $t1, 2, jogador2_valido1_oitava
	nop
	j jogador2_nao_venceu
	nop
jogador2_valido1_oitava:
	beq $t2, 2, jogador2_valido2_oitava
	nop
	j jogador2_nao_venceu
	nop
jogador2_valido2_oitava:
	beq $t3, 2, jogador2_venceu
	nop
	j jogador2_nao_venceu
	nop
jogador2_nao_venceu:
	li $v1, 0
	jr $ra
	nop
jogador2_venceu:
	li $a1, 1
	li $v0, 55
	la $a0, jogador2venceu_msg
	syscall
	li $v1, 1
	jr $ra
	nop
###################################################################################



######### DESENHAR X ####################
desenha_xis:

	li $t1, 0x00FF00
	lui $t0, 0x1001
	ori $t2, $0, 0

##### As posicoes informadas pelos jogadores serao interpretadas da seguinte forma no tabuleiro:
##### 7 | 8 | 9
##### 4 | 5 | 6
##### 1 | 2 | 3

beq $a2, 1, xis_sete
nop

beq $a2, 2, xis_oito
nop

beq $a2, 3, xis_nove
nop

beq $a2, 4, xis_quatro
nop

beq $a2, 5, xis_cinco
nop

beq $a2, 6, xis_seis
nop

beq $a2, 7, xis_um
nop

beq $a2, 8, xis_dois
nop

beq $a2, 9, xis_tres
nop

xis_um:	
	#VERTICAL
	li $t3, 30
	li $t4, 1024
	mult $t3, $t4
	mflo $t5
	add $t0, $t0, $t5
	#HORIZONTAL
	addi $t0, $t0, 140
	j primeira_linha
	nop
	
xis_dois:
	#VERTICAL
	li $t3, 30
	li $t4, 1024
	mult $t3, $t4
	mflo $t5
	add $t0, $t0, $t5
	#HORIZONTAL
	addi $t0, $t0, 440	
	j primeira_linha
	nop	
xis_tres:
	#VERTICAL
	li $t3, 30
	li $t4, 1024
	mult $t3, $t4
	mflo $t5
	add $t0, $t0, $t5
	#HORIZONTAL
	add $t0, $t0, 760
	j primeira_linha
	nop	
xis_quatro:
	#VERTICAL
	li $t3, 100
	li $t4, 1024
	mult $t3, $t4
	mflo $t5
	add $t0, $t0, $t5
	#HORIZONTAL
	add $t0, $t0, 140	
	j primeira_linha
	nop
xis_cinco:
	#VERTICAL
	li $t3, 100
	li $t4, 1024
	mult $t3, $t4
	mflo $t5
	add $t0, $t0, $t5
	#HORIZONTAL
	add $t0, $t0, 440
	j primeira_linha
	nop
xis_seis:
	#VERTICAL
	li $t3, 100
	li $t4, 1024
	mult $t3, $t4
	mflo $t5
	add $t0, $t0, $t5
	#HORIZONTAL
	add $t0, $t0, 760
	j primeira_linha
	nop	
xis_sete:
	#VERTICAL
	li $t3, 170
	li $t4, 1024
	mult $t3, $t4
	mflo $t5
	add $t0, $t0, $t5
	#HORIZONTAL
	addi $t0, $t0, 140
	j primeira_linha
	nop
xis_oito:
	#VERTICAL
	li $t3, 170
	li $t4, 1024
	mult $t3, $t4
	mflo $t5
	add $t0, $t0, $t5
	#HORIZONTAL
	add $t0, $t0, 440
	j primeira_linha
	nop
xis_nove:
	#VERTICAL
	li $t3, 170
	li $t4, 1024
	mult $t3, $t4
	mflo $t5
	add $t0, $t0, $t5
	#HORIZONTAL
	add $t0, $t0, 760
	j primeira_linha
	nop
	
primeira_linha:
	addi $t0, $t0, 1024
	addi $t0, $t0, 4
	sw $t1, 0($t0)
	addi $t2, $t2, 1
	bne $t2, 30, primeira_linha
	nop
	subu $t0, $t0, 120
	ori $t2, $0, 0
segunda_linha:
	sub $t0, $t0, 1024
	addi $t0, $t0, 4
	sw $t1, 0($t0)
	addi $t2, $t2, 1	
	bne $t2, 30, segunda_linha
	nop
	jr $ra
	nop

# - FIM DESENHAR X - #

####### DESENHAR 0 ###########
desenha_y:
				
	li $t1, 0x00FF00	
	lui $t0, 0x1001
	ori $t2, $0, 0

beq $a2, 1, y_sete
nop

beq $a2, 2, y_oito
nop

beq $a2, 3, y_nove
nop

beq $a2, 4, y_quatro
nop

beq $a2, 5, y_cinco
nop

beq $a2, 6, y_seis
nop

beq $a2, 7, y_um
nop

beq $a2, 8, y_dois
nop

beq $a2, 9, y_tres
nop

y_um:
	#HORIZONTAL
	addi $t0, $t0, 120
	#VERTICAL
	li $t3, 30
	li $t4, 1024
	mult $t3, $t4
	mflo $t5
	add $t0, $t0, $t5
	j desenhar_y
	nop

y_dois:
	#HORIZONTAL
	addi $t0, $t0, 420
	#VERTICAL
	li $t3, 30
	li $t4, 1024
	mult $t3, $t4
	mflo $t5
	add $t0, $t0, $t5
	j desenhar_y
	nop
y_tres:
	#HORIZONTAL
	addi $t0, $t0, 740
	#VERTICAL
	li $t3, 30
	li $t4, 1024
	mult $t3, $t4
	mflo $t5
	add $t0, $t0, $t5
	j desenhar_y
	nop
y_quatro:
	#HORIZONTAL
	addi $t0, $t0, 120
	#VERTICAL
	li $t3, 100
	li $t4, 1024
	mult $t3, $t4
	mflo $t5
	add $t0, $t0, $t5
	j desenhar_y
	nop
y_cinco:
	#HORIZONTAL
	addi $t0, $t0, 420
	#VERTICAL
	li $t3, 100
	li $t4, 1024
	mult $t3, $t4
	mflo $t5
	add $t0, $t0, $t5
	j desenhar_y
	nop
y_seis:
	#HORIZONTAL
	addi $t0, $t0, 740
	#VERTICAL	
	li $t3, 100
	li $t4, 1024
	mult $t3, $t4
	mflo $t5
	add $t0, $t0, $t5
	j desenhar_y
	nop
y_sete:
	#HORIZONTAL
	addi $t0, $t0, 120
	#VERTICAL
	li $t3, 170
	li $t4, 1024
	mult $t3, $t4
	mflo $t5
	add $t0, $t0, $t5
	j desenhar_y
	nop
y_oito:
	#HORIZONTAL
	addi $t0, $t0, 420
	#VERTICAL
	li $t3, 170
	li $t4, 1024
	mult $t3, $t4
	mflo $t5
	add $t0, $t0, $t5
	j desenhar_y
	nop
y_nove:
	#HORIZONTAL
	addi $t0, $t0, 740
	#VERTICAL
	li $t3, 170
	li $t4, 1024
	mult $t3, $t4
	mflo $t5
	add $t0, $t0, $t5
	j desenhar_y
	nop
	
desenhar_y:	
	segunda_parte:
		addi $t0, $t0, 108
		addi $t0, $t0, 30720
		li $t2, 0
	segunda_linha_h:
		sw $t1, 0($t0)
		subu $t0, $t0, 4
		addi $t2, $t2, 1
		bne $t2, 15, segunda_linha_h
		nop
	terceira_parte:
		ori $t2, $0, 0
	primeira_diagonal:
		sw $t1, 0($t0)
		subu $t0, $t0, 1024
		sub $t0, $t0, 4
		addi $t2, $t2, 1
		bne $t2, 9, primeira_diagonal
		nop
	quarta_parte:
		ori $t2, $0, 0
	primeira_linha_v:
		sw $t1, 0($t0)	
		subu $t0, $t0, 1024
		addi $t2, $t2, 1
		bne $t2, 15, primeira_linha_v
		nop
	quinta_parte:
		ori $t2, $0, 0
	segunda_diagonal:
		sw $t1, 0($t0)
		addi $t0, $t0, 4
		subu $t0, $t0, 1024
		addi $t2, $t2, 1
		bne $t2, 9, segunda_diagonal
		nop
	sexta_parte:
		ori $t2, $0, 0
	segunda_linha_ho:
		sw $t1, 0($t0)
		addi $t0, $t0, 4
		addi $t2, $t2, 1
		bne $t2, 15, segunda_linha_ho
		nop
	setima_parte:
		ori $t2, $0, 0
	terceira_diagonal:
		sw $t1, 0($t0)
		addi $t0, $t0, 4
		addi $t0, $t0, 1024
		addi $t2, $t2, 1
		bne $t2, 9, terceira_diagonal
		nop
	oitava_parte:
		ori $t2, $0, 0
	segunda_vertical:
		sw $t1, 0($t0)
		addi $t0, $t0, 1024
		addi $t2, $t2, 1
		bne $t2, 15, segunda_vertical
		nop
	nona_parte:
		ori $t2, $0, 0
	quarta_diagonal:
		sw $t1, 0($t0)
		addi $t0, $t0, 1024
		subu $t0, $t0, 4
		addi $t2, $t2, 1
		bne $t2, 9, quarta_diagonal
		nop
		
		jr $ra
		nop
		
######### FIM DESENHAR Y #################

######### ZERAR MEMORIA E TELA ###########
zerar_tudo:
	li $s1, 1
	la $t0, valores
	sw $0, 0($t0)
	sw $0, 4($t0)
	sw $0, 8($t0)
	sw $0, 12($t0)
	sw $0, 16($t0)
	sw $0, 20($t0)
	sw $0, 24($t0)
	sw $0, 28($t0)
	sw $0, 32($t0)
	
	lui $t1, 0x1001
	li $t2, 0
	
#Pinta tudo de preto
loop:
	sw $0, ($t1)
	addi $t1, $t1, 4
	addi $t2, $t2, 1
	bne $t2, 65536, loop
	nop
	
	j main
	nop
	
