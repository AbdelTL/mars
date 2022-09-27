#  Pojet AO Printemps 2021-2022
#  Date de rendu: 12/13/17 11:00AM

################################################################################################################################# 
##  Ce fichier contient un squelete de code pour le jeu du puissance 4.
##  L'ensemble des fonctions d'affichage est d�j� en place. L'affichage repose sur l'�criture de carr�s de 8x8px.
##  Les fonctions � compl�ter sont les suivantes :
##  
################################################################################################################################# 
.data
Colors:	#  Contient les couleurs
 .word 0x0000FF # [0] Bleu   0x0000FF	Grille
 .word 0xFF0000 # [1] Rouge  0xFF0000	Jeton joueur 2
 .word 0xE5C420 # [2] Jaune  0xE5C420	Jeton joueur 1
 .word 0xFFFFFF # [3] Blanc  0xFFFFFF	Fond


#  Un cercle est d�finit par une suite de lignes horizontales.
#  Chaque ligne est d�finie par un offset suivit d'une longeur (ex : 2, 4, on d�cale de deux carr�s et on d�ssine 4 carr�s
CircleDef: 
	.word 2, 4, 1, 6, 0, 8, 0, 8, 0, 8, 0, 8, 1, 6, 2, 4

displayStart: .asciiz "Bienvenue dans ce jeu du puissance 4!\nC'est un jeu � deux joueurs.\nLe joueur 1 va commencer.\nEntrez un nombre entre 1 et 7 pour choisir la colonne o� jouer.\nUne fois qu'un joeuur a jou�, attendez que la console demande une nouvelle action pour jouer!\n\nBon Jeu!\n\n"
displayP1: .asciiz "\nTour du joueur 1 : "
displayP2: .asciiz "\nTour du joueur 2 : "
displayP1Win: .asciiz "Le joueur 1 a gagne !\n"
displayP2Win: .asciiz "Le joueur 2 a  gagne !\n"
displayInstructions: .asciiz "Le joueur Choisissez un nombre entre 1 et 7 (inclus)\n"
displayInstruction: .asciiz "veullez Choisir un nombre entre 1 et 7 (inclus) : "	#message d'erreur demander pour rejouer
displayFull: .asciiz "la colonne choisie est pleine. Choisissez en une autre.\n"
displayTie: .asciiz "Il y a egalite !\n"
arrayPlayed: .byte 0:42      # le tableau de presentation de jeu et jetons en representant de $a0 = 1 pour joueur 1 et $a0 = 2 pour joueur 2 
.text

Init:
la $a0, ($sp)
li $v0, 1
syscall

#  D�ssine le plateau
jal DrawGameBoard

#  D�but du jeu
la $a0, displayStart	
li $v0, 4
syscall

################################   Fonction Main ################################  
main:

#  R�cup�re l'instruction du joueur 1
playerOne:
la $a0, displayP1
li $v0, 4
syscall
li $v0, 5
syscall
# input check verifie si le joueur a mis un nombre entre 1 et 7





#  Place le jeton et controle si il y a une erreur
li $a0, 1
jal UpdateRecord

#  D�ssine le jeton
li $a0, 1
jal DrawPlayerChip

#  Test si le joueur 1 � gagner sinon on reviens et on pass � la suite (instruction "playerTwo:")
jal WinCheck

#  R�cup�re l'instruction du joueur 2
playerTwo:
la $a0, displayP2
li $v0, 4
syscall
li $v0, 5
syscall
# input check verifie si le joueur a mis un nombre entre 1 et 7



#  Place le jeton et contr�le si il y a une erreur
li $a0, 2
jal UpdateRecord

#  D�ssine le jeton
li $a0, 2
jal DrawPlayerChip

#  Test si le joueur 1 � gagner sinon on passe � la suite (instruction "j main")
jal WinCheck

j main	#  Passe au porchain tour
################################   Fin de la fonction Main ################################  



################################   D�but des proc�dures d'affichage ################################  
##################### Il n'est pas obligatoire de comprendre ce qu'elles font. ##################### 
# Procedure: DrawPlayerChip
# Input: $a0 - Num�ro du joueur
# Input: $v0 - Position (entre 0 et 41)
DrawPlayerChip:
	
	addiu $sp, $sp, -12
	sw $ra, ($sp)
	sw $a0, 4($sp)
	sw $v0, 8($sp)
	
	#  place la couleur du jeton en argument
	move $a2, $a0
	
	#  On calcul la position
	li $t0, 7
	div $v0, $t0
	mflo $t0	# Division (Y)
	mfhi $t1	# Reste (X)

	#  Y-Position = 63-[(Y+1)*9+4] = 50-9Y (dans $t0)
	li $t2, 50
	mul $t0, $t0, 9
	mflo $t0
	sub $t0, $t2, $t0 
	
	# X-Position = [X*9]+1 (dans $t1)
	mul $t1, $t1, 9
	addi $t1, $t1, 1
	
	#  Copie les positions dans les registres d'arguments
	move $a0, $t1
	move $a1, $t0
	
	jal DrawCircle
	
	lw $v0, 8($sp)
	lw $a0, 4($sp)
	lw $ra, ($sp)
	addiu $sp, $sp, 4
	jr $ra

# Procedure: DrawGameBoard
# Affiche la grille
DrawGameBoard:
	addiu $sp, $sp, -4
	sw $ra, ($sp)
	
	#  Fond en blanc
	li $a0, 0
	li $a1, 0
	li $a2, 3	
	li $a3, 64
	jal DrawSquare #  Affiche un carr� blanc de 64x64 en position 0,0)
	
	#  Ligne du haut
	li $a0, 0	
	li $a1, 0	
	li $a2, 0	
	li $a3, 64	
	jal DrawHorizontalLine
	li $a1, 1
	jal DrawHorizontalLine
	li $a1, 2	
	jal DrawHorizontalLine
	li $a1, 3	
	jal DrawHorizontalLine
	li $a1, 4	
	jal DrawHorizontalLine
	
	#  Ligne du bas
	li $a0, 0	
	li $a1, 58	
	li $a2, 0	
	li $a3, 64	
	jal DrawHorizontalLine
	li $a1, 59
	jal DrawHorizontalLine
	li $a1, 60	
	jal DrawHorizontalLine
	li $a1, 61	
	jal DrawHorizontalLine
	li $a1, 62	
	jal DrawHorizontalLine
	li $a1, 63	
	jal DrawHorizontalLine


	#  Lignes verticales
	li $a0, 0	
	li $a1, 0	
	li $a2, 0	
	li $a3, 64	
	jal DrawVerticalLine	
	li $a0, 9	# (X = 9)
	jal DrawVerticalLine
	li $a0, 18	# (X = 18)
	jal DrawVerticalLine
	li $a0, 27	# (X = 27)
	jal DrawVerticalLine
	li $a0, 36	# (X = 36)
	jal DrawVerticalLine
	li $a0, 45	# (X = 45)
	jal DrawVerticalLine
	li $a0, 54	# (X = 54)
	jal DrawVerticalLine
	li $a0, 63	# (X = 63)
	jal DrawVerticalLine

	#  Lignes horizontales
	li $a0, 0	
	li $a1, 13	
	li $a2, 0	
	li $a3, 64	
	jal DrawHorizontalLine
	li $a1, 22
	jal DrawHorizontalLine
	li $a1, 31	
	jal DrawHorizontalLine
	li $a1, 40	
	jal DrawHorizontalLine
	li $a1, 49	
	jal DrawHorizontalLine

	lw $ra, ($sp)
	addiu $sp, $sp, 4
	jr $ra


# Procedure: DrawCircle
# Input - $a0 = X 
# Input - $a1 = Y
# Input - $a2 = Color (0-5)
# Affiche le Jeton
DrawCircle:
	#  Fait de a place sur la pile
	addiu $sp, $sp, -28 	
	#  Y ajoute les arguments suivants $ra, $s0, $a0, $a2
	sw $ra, 20($sp)
	sw $s0, 16($sp)
	sw $a0, 12($sp)
	sw $a2, 8($sp)
	li $s2, 0	#  Initaitllise le compteur et on passe dans la boucle de la fonction
	
CircleLoop:
	la $t1, CircleDef
	#  Utilise le compteur pour r�cup�er le bon indice dans CircleDef
	addi $t2, $s2, 0	
	mul $t2, $t2, 8		
	add $t2, $t1, $t2	
	lw $t3, ($t2)		
	add $a0, $a0, $t3	
	
	#  On d�ssine la ligne
	addi $t2, $t2, 4	
	lw $a3, ($t2)		
	sw $a1, 4($sp)		
	sw $a3, 0($sp)		
	sw $s2, 24($sp)		
	jal DrawHorizontalLine
	
	#  On remet en place les arguments
	lw $a3, 0($sp)
	lw $a1, 4($sp)
	lw $a2, 8($sp)
	lw $a0, 12($sp)
	lw $s2, 24($sp)
	addi $a1, $a1, 1	#  Incremente Y value
	addi $s2, $s2, 1	#  Incremente le compteur
	bne $s2, 8, CircleLoop	#  On boucle pour �crire les 8 lignes
	
	
	#  R�staure les valeurs de $ra, $s0, $sp
	lw $ra, 20($sp)
	lw $s0, 16($sp)
	addiu $sp, $sp, 28
	jr $ra
	
# Procedure: DrawSquare
# Input - $a0 = X 
# Input - $a1 = Y
# Input - $a2 = Color (0-5)
# Input - $a3 = W 
# D�ssine un carr� de taille WxW en position (X, Y)
DrawSquare:
	addiu $sp, $sp, -24 	# Sauvegarde $ra, $s0, $a0, $a2
	sw $ra, 20($sp)
	sw $s0, 16($sp)
	sw $a0, 12($sp)
	sw $a2, 8($sp)
	move $s0, $a3		
	
BoxLoop:
	sw $a1, 4($sp)	
	sw $a3, 0($sp)	
	jal DrawHorizontalLine
	
	# R�staure $a0-3
	lw $a3, 0($sp)
	lw $a1, 4($sp)
	lw $a2, 8($sp)
	lw $a0, 12($sp)
	addi $a1, $a1, 1	# Incr�mente Y 
	addi $s0, $s0, -1	# D�cr�mente le nombre de ligne
	bne $zero, $s0, BoxLoop	# Jusqu'� ce que le compteur soit � z�ro
	
	# R�staure $ra, $s0, $sp
	lw $ra, 20($sp)
	lw $s0, 16($sp)
	addiu $sp, $sp, 24	# Reset $sp
	jr $ra
	
# Procedure: DrawHorizontalLine
# Input - $a0 = X 
# Input - $a1 = Y
# Input - $a2 = Color (0-5)
# Input - $a3 = W
# D�ssine une ligne horizontale de longueur W en position (X, Y)
DrawHorizontalLine:
	addiu $sp, $sp, -28 	
	# Sauvegarde $ra, $a1, $a2
	sw $ra, 16($sp)
	sw $a1, 12($sp)
	sw $a2, 8($sp)
	sw $a0, 20($sp)
	sw $a3, 24($sp)
	
HorizontalLoop:
	# Sauvegarde $a0, $a3 
	sw $a0, 4($sp)
	sw $a3, 0($sp)
	jal DrawPixel
	# R�staure tout sauf $ra
	lw $a0, 4($sp)
	lw $a1, 12($sp)
	lw $a2, 8($sp)
	lw $a3, 0($sp)	
	addi $a3, $a3, -1		# D�cr�mente la longueur W
	addi $a0, $a0, 1		# Incr�mente X 
	bnez $a3, HorizontalLoop	# Boucle tant que W > 0 	
	lw $ra, 16($sp)			# R�staure $ra
	lw $a0, 20($sp)
	lw $a3, 24($sp)
	addiu $sp, $sp, 28		# R�staure $sp
	jr $ra
	
# Procedure: DrawVerticalLine
# Input - $a0 = X 
# Input - $a1 = Y
# Input - $a2 = Color (0-5)
# Input - $a3 = W
# D�ssine une ligne verticale de longeur W en position (X, Y)
DrawVerticalLine:
	addiu $sp, $sp, -28
	# Sauvegarde $ra, $a1, $a2
	sw $ra, 16($sp)
	sw $a1, 12($sp)
	sw $a2, 8($sp)
	sw $a0, 20($sp)
	sw $a3, 24($sp)
	
VerticalLoop:
	# Save $a0, $a3 (changes with next procedure call)
	sw $a1, 4($sp)
	sw $a3, 0($sp)
	jal DrawPixel
	# Restore all but $ra
	lw $a1, 4($sp)
	lw $a0, 20($sp)
	lw $a2, 8($sp)
	lw $a3, 0($sp)	
	addi $a3, $a3, -1		# D�cr�mente la longueur W
	addi $a1, $a1, 1		# Incr�mente Y 
	bnez $a3, VerticalLoop		# Boucle tant que W > 0 	
	lw $ra, 16($sp)			# R�staure $ra
	lw $a1, 12($sp)
	lw $a3, 24($sp)
	addiu $sp, $sp, 28		# R�staure $sp
	jr $ra
	
# Procedure: DrawPixel
# Input - $a0 = X
# Input - $a1 = Y
# Input - $a2 = Color (0-5)
# D�ssine un pixel sur la Bitmap en �crivant au bon endroit sur la m�moire (sur le tas/heap) via la fonction GetAddress
DrawPixel:
	addiu $sp, $sp, -8
	# Save $ra, $a2
	sw $ra, 4($sp)
	sw $a2, 0($sp)
	jal GetAddress		# Calcule l'adresse m�moire
	lw $a2, 0($sp)		
	sw $v0, 0($sp)		
	jal GetColor		# R�cup�re la couleur
	lw $v0, 0($sp)		
	sw $v1, ($v0)		# Ecrit la couleur en m�moire
	lw $ra, 4($sp)		
	addiu $sp, $sp, 8	
	jr $ra


# Procedure: GetAddress
# Input - $a0 = X
# Input - $a1 = Y
# Output - $v0 = l'adresse m�moire exacte o� �crire le pixel
GetAddress:
	sll $t0, $a0, 2			# Multiplie X par 4
	sll $t1, $a1, 8			# Multiplie Y par 64*4 (512/8= 64 * 4 words)
	add $t2, $t0, $t1		# Additionne les deux 
	addi $v0, $t2, 0x10040000	# Ajout de l'adresse point� par Bitmap (heap) 
	jr $ra

# Procedure: GetColor
# Input - $a2 = Index dans Colors (0-5)
# Output - $v1 = valeur Hexad�cimale
# Retourne la valeur Hexad�cimale de la couleur demand�e
GetColor:
	la $t0, Colors		
	sll $a2, $a2, 2		
	add $a2, $a2, $t0	
	lw $v1, ($a2)		
	jr $ra

################################   Fin des proc�dures d'affichage ################################  



################################ D�but UpdateRecord ################################    	
UpdateRecord: 
				
  	li $t1,6
  	subi $v0,$v0, 1		# comencement a 1 pas a 0
	bgt $v0,$t1,then   	# verifirer si l'utilisateur a mis un nombre compri entre 1 et 7
### boocle pour parcourir et presiser la palce des element #
 places:
	lb $t2, arrayPlayed($v0)	#Load byte du arrayplayed
	bnez  $t2, rec
	sb $a0, arrayPlayed($v0)	# on modifie la valeur du tableau par a0 (1 ou 2) 
	bgt $v0, 41, fullColumn
	jr $ra	
	
   rec: addiu $v0, $v0, 7 	#incrementer de 7 le valeur de v0 si la case contien a0 cad (1 ou 2)
      	j  places
  				
then:	la $a0, displayInstruction	#
	li $v0, 4			# si le nombre est superieur a 7 il
	syscall	
	li $v0, 5			# execute ces 
	syscall				#
	j UpdateRecord
fullColumn:
	la $a0, displayFull
	li $v0, 4
	syscall
	li $v0, 5			# execute ces 
	syscall				#
	j UpdateRecord

	
################################ Fin UpdateRecord ###############################
	
			
################################ D�but WinCheck ################################  
WinCheck:    	

     	li $t7, 7
     	li $t6, 1		#Counteur pour voir si  il y a 4 jeton
	move $t2, $v0		
	move $t4, $v0
####verification a gauche###
leftCheck:
     	la $t0, arrayPlayed($t2)
	div $t2, $t7		#division de t2 avec t7
	mfhi $t3		#modulo de t2 avec t7
	beqz $t3, rightCheck
	
	lb $t1, -1($t0)		# la place precedente de v0
     	bne $t1, $a0, rightCheck# si la place de de v0 -1 c-a-d la case precedente est aussi la meme pour mon a1 alors on execute les instruction suivante sinon on jump vers check right	
     	addiu $t6, $t6, 1	#	
     	addiu $t2, $t2, -1	#
	bgt $t6, 3, PlayerWon	#	
     	j leftCheck		#
     	
     	
     	
     	
     	
     	
###verification a droite####	
rightCheck:
	la $t0, arrayPlayed($t4)	
	div $t4, $t7		
	mfhi $t5
	beq $t3, 6, endCheckHorz	#
	lb $t1, 1($t0)			#la place suivante de v0
	bne $t1, $a0, endCheckHorz	#si la place de de v0 +1 c-a-d la case suivante est aussi la meme pour mon a1 alors on execute les instruction suivante sinon on jump vers endCheckHoriz
	addiu $t6, $t6, 1	
	addiu $t4, $t4, 1	
	bgt $t6, 3, PlayerWon	
	j rightCheck
endCheckHorz:





####      verticale     #####
        li $t7, 7
     	li $t6, 1		#Counteur pour voire si  il y a 4 jeton
	move $t2, $v0		
	move $t4, $v0


onTop:
     	la $t0 , arrayPlayed ($t2)
        bgtu $t2, 34, onBot	 # si le location de jeton est plus de 34 sauter a checkdown car on est a la plus heut haut ligen possible 
        lb $t1, 7($t0)			
     	bne $t1, $a0, onBot  # si la valeur n,est pas egal a joueur , sauter a checkdown	
     	addiu $t6, $t6, 1	 # sinon incrementer le conteur et verifier la ligne prochaine 	
     	addiu $t2, $t2, 7
	bgt $t6, 3, PlayerWon	 # si le joueur a plus que 3 jeton voire 4 , sauter a playerwon 	
     	j onTop 

onBot:
	la $t0, arrayPlayed($t4)  # aller au plus bas possible 
        bltu $t4, 7, endVert
     	lb $t1, -7($t0)		   #en dessous de la location actuel 
	bne $t1, $a0, endVert	   # si la valeur n'est pas le numero de joueur , fin de verifier 
	addiu $t6, $t6, 1	   #sinon incrementer le counteur
	addiu $t4, $t4, -7	   # aller a al procahinvaleur en dessous de location actuel 
	bgt $t6, 3, PlayerWon      # si le joueur a plus que 3 jeton voire 4 , sauter a playerwon 	   
	j onBot

endVert:  
     
#####    diagonale     ####

####     barre oblique ####
#Dès le début, allez vers le HAUT-DROITE (UR) aussi loin que possible
        li $t6, 1		
	move $t2, $v0		
	move $t4, $v0	

onTopRight:
        la $t0,arrayPlayed($t2) 

        bgtu $t2, 34, onbotRight	
	div $t2, $t7
	mfhi $t3
	beq $t3, 6, onbotRight      # si le modulo resultat = 6 alors on est en  emplacement le plus à droite
	
	#Sinon, regardez la fente au-dessus de nous et à droite
        lb $t1, 8($t0)		#UR de location actuel 	
     	bne $t1, $a0, onbotRight		
     	addiu $t6, $t6, 1		 
     	addiu $t2, $t2, 8        
	bgt $t6, 3, PlayerWon		
     	j onTopRight
#Depuis le début, allez vers le BAS-GAUCHE (DL) aussi loin que possible    	    				
onbotRight:
	la $t0,arrayPlayed($t4)
#Si nous sommes à la ligne du bas OU à la colonne la plus à gauche, terminez la vérification de FSDiag
        bltu $t4, 7, enddiag	# verification de ligne de bas 
	div $t4, $t7
	mfhi $t3
	beq $t3, 0, enddiag	#verification de la colonne la plus a gauche 
	
#sinon regardez la fente en dessous de nous et sur celle de gauche	
	lb $t1, -8($t0)		# DL de la location actuelle 
	bne $t1, $a0, enddiag	
	addiu $t6, $t6, 1	
	addiu $t4, $t4, -8	
	bgt $t6, 3, PlayerWon	
	j onbotRight
	
enddiag: 
	
 	
####   diagonale avec barre oblique inversée ####

        li $t6, 1		
	move $t2, $v0		
	move $t4, $v0	

onTopLeft:
     	la $t0,arrayPlayed($t2)	
#Si nous sommes à la rangée du haut OU nous sommes à la colonne la plus à gauche, alors passez en bas à droite
        bgtu $t2, 34, onBotRight	# verification de  la rangée du haut
	div $t2, $t7
	mfhi $t3
	beq $t3, 0, onBotRight    #verification de la colonne la plus à gauche	
     	
# Sinon, regardez la fente au-dessus de nous et à gauche    	
     	lb $t1, 6($t0)		 # Haut et gauche de la position actuelle	
     	bne $t1, $a0, onBotRight		
     	addiu $t6, $t6, 1		
     	addiu $t2, $t2, 6
	bgt $t6, 3, PlayerWon		
     	j onTopLeft
     	
onBotRight:
	la $t0,arrayPlayed($t4)
	
#Si nous sommes dans la rangée du bas OU dans la colonne la plus à droite, terminez la vérification de BSDiag
	bltu $t4, 7, onBackDiag    #Essai de la rangée du bas
	div $t4, $t7
	mfhi $t3
	beq $t3, 6, onBackDiag	  #Test de la colonne la plus à droite
	
#Sinon, regardez la fente en dessous de nous et sur celle de droite	
	lb $t1, -6($t0)		# BR  (bottom row) de location actuelle 
	bne $t1, $a0, onBackDiag	
	addiu $t6, $t6, 1	
	addiu $t4, $t4, -6
	bgt $t6, 3, PlayerWon		
	j onBotRight
	
onBackDiag:





#fin des check
#jump to game tie 
	li $t0,35	
	li $t2, 0		#conteur: combien decolumn sont plein
	la $t3, arrayPlayed($t0)
topLeftToRight:
	lb  $t1,($t3)
	
    	beqz  $t1,endTopLeftToRight #si $t1 = soit 1 soit 0 alors on continue dans la boucle sinon on sort

    	addi $t3,$t3,1
	addi $t2,$t2,1
	
    	beq $t2,7,GameTie
    	j topLeftToRight
endTopLeftToRight:
     	jr $ra


################################  Fin WinCheck ################################  
GameTie:
	la $a0, displayTie
	li $v0, 4
	syscall
	li $v0, 10
	syscall

PlayerWon:
	beq $a0, 1 player1Win	#si joueur 1 a gagnee jump to player1win
	
	#Player 2 Won
	la $a0, displayP2Win
	li $v0, 4
	syscall
	li $v0, 10
	syscall
	
	#Player 1 Won
player1Win:
	la $a0, displayP1Win
	li $v0, 4
	syscall
	li $v0, 10
	syscall



