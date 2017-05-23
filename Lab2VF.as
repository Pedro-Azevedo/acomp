;===============================================================================
; Programa Mastermind
;
;
; Autor: Diogo, Leonor e Pedro
; Data: 				Ultima Alteracao:01/05/17
;===============================================================================

;===============================================================================
; ZONA I: Definicao de constantes
;         Pseudo-instrucao : EQU
;===============================================================================
; STACK POINTER
	SP_INICIAL      EQU     FDFFh	

; DADOS DE JOGO
	NUM_COR			EQU		0006h		;numero de cores versao standard
	NUM_PECAS		EQU		0004h		;numero de peças versao standard
	NUM_JOGADAS		EQU		000Ah		;numero de tentativas versao standard
	RIGHT_POS		EQU 	0000h		;numero de cores certas na posicao certa
	RIGHT_COL		EQU		0000h		;numero de cores certas na posicao errada
	MASCARA			EQU		9C16h		;mascara para geração

; JANELA DA PLACA
	DISP7S1         EQU     FFF0h
	DISP7S2         EQU     FFF1h
	DISP7S3         EQU     FFF2h
	DISP7S4			EQU		FFF3h

; I/O a partir de FF00H
	IO_CURSOR       EQU     FFFCh
	IO_WRITE        EQU     FFFEh
	IO_STAT			EQU		FFFDh
	IO_READ			EQU		FFFFh


; INTERRUPCOES
	TAB_INTTemp     EQU     FE0Fh
	MASCARA_INT		EQU		FFFAh
	TAB_INT0		EQU		FE00h

	LIMPAR_JANELA   EQU     FFFFh
	XY_INICIAL      EQU     0004h
	XY_INTROD		EQU		2207h
	FIM_TEXTO       EQU     '@'

; TEMPORIZADOR
	TempValor		EQU	FFF6h
	TempControlo	EQU	FFF7h

;===============================================================================
; ZONA II: Definicao de variaveis
;===============================================================================
                ORIG    8000h
;Variáveis de texto do tabuleiro
PlanoJogo       STR     ' |!   !   !   !   !| P/  B|', FIM_TEXTO
Limites       	STR	'<=========================>', FIM_TEXTO
Separador       STR     ' -------------------------', FIM_TEXTO
EcraInicialS1	STR	'   _   _     _    ___  _____  ___  ___   _   _   _ _       __', FIM_TEXTO
EcraInicialS2	STR	'  / \ / \   /_\  |___    |   |___ |___| / \ / \   |  |\ | |  \', FIM_TEXTO
EcraInicialS3	STR	' /   V   \ /   \  ___|   |   |___ |\   /   V   \ _|_ | \| |__/', FIM_TEXTO
EcraInicialS4 	STR 	'               Bem-vindo(a) ao jogo Mastermind!', FIM_TEXTO 
EcraInicialS5	STR	'	 		1 - Jogar', FIM_TEXTO
EcraInicialS6	STR	'			2 - Como Jogar?', FIM_TEXTO
EcraInicialR1 	STR 	'O objetivo do Mastermind e descobrir uma combinacao de cores determinada', FIM_TEXTO 
EcraInicialR2 	STR     'aleatoriamente pelo computador.Em cada jogada, o jogador apresenta uma', FIM_TEXTO
EcraInicialR3	STR	'combinacao de cores a que o computador responde, mostrando o numero P de', FIM_TEXTO 
EcraInicialR4	STR	'cores na posicao correta e o numero B de cores presentes na combinacao,', FIM_TEXTO
EcraInicialR5	STR	'mas noutra posicao. Face a resposta do computador, o jogador apresenta', FIM_TEXTO 
EcraInicialR6	STR	'uma nova combinacao, juntando cores que ainda nao foram escolhidas,', FIM_TEXTO
EcraInicialR7	STR	'trocando a ordem das cores, ou ambos. O codigo de cores e o seguinte:', FIM_TEXTO
EcraInicialR8 	STR  	'A -----> Amarelo 		B-----> Branco 		E----->Encarnado', FIM_TEXTO 
EcraInicialR9 	STR	'P -----> Preto 		V-----> Verde		Z----->Azul', FIM_TEXTO
EcraInicialR10 	STR	'Deve inserir a cor com o CAPS LOCK do seu teclado desligado, para o jogo', FIM_TEXTO
EcraInicialR11 	STR	'reconhecer.O jogo progride ate que a combinacao seja descoberta ou que o', FIM_TEXTO
EcraInicialR12	STR	'numero limite de jogadas seja atingido. Prima 1 para jogar.', FIM_TEXTO
Message1 		STR 'YOU LOST! GAME OVER', FIM_TEXTO
Message2 		STR 'YOU WON! CONGRATULATIONS!', FIM_TEXTO 

;Variaveis de geração de peças
PecaA		WORD	0000h
PecaB		WORD	0000h
PecaC		WORD	0000h
PecaD		WORD	0000h		;4 words para cada peça versao standard
SeedIni		WORD	998Ch		;seed de geração´
TentA		WORD	0000h
TentB		WORD	0000h
TentC		WORD	0000h
TentD		WORD	0000h

;Variaveis para o cronometro
Aux7			WORD	0000h
Aux6			WORD	0002h
Aux5			WORD	0000h
Aux4			WORD	0000h
EndofTimeFlag	WORD 	0000h

;===============================================================================
; ZONA III: Codigo
;===============================================================================
                ORIG    0000h
                JMP     inicio


;===============================================================================
; RotinaInt0: Rotina de interrupcao 0 (Aparece a sequência gerada)
;===============================================================================
RotinaInt0:     PUSH 	R1
				CALL	MostraPecas				;Mostra a solucao
				MOV 	R1, M[EndofTimeFlag]	;Como a solucao foi mostrada, vamos forcar o jogo a terminar
				MOV 	R1, 0001H  				;Para isso ativamos a flag usada quando o cronometro para de contar 
				MOV 	M[EndofTimeFlag], R1
				POP 	R1
                RTI

;===============================================================================
; LimpaJanela: Rotina que limpa a janela de texto.
;===============================================================================
LimpaJanela:    PUSH R2
                MOV     R2, LIMPAR_JANELA
				MOV     M[IO_CURSOR], R2
                POP R2
                RET

;===============================================================================
; EscCar: Rotina que efectua a escrita de um caracter para o ecran.
;         O caracter pode ser visualizado na janela de texto.
;               Entradas: R1 - Caracter a escrever
;               Saidas: ---
;               Efeitos: alteracao da posicao de memoria M[IO]
;===============================================================================
EscCar:         MOV     M[IO_WRITE], R1
                RET  

;===============================================================================
; EscString: Rotina que efectua a escrita de uma cadeia de caracter, terminada
;            pelo caracter FIM_TEXTO, na janela de texto numa posicao 
;            especificada. Pode-se definir como terminador qualquer caracter 
;            ASCII. 
;               Entradas: pilha - posicao para escrita do primeiro carater 
;                         pilha - apontador para o inicio da "string"
;               Saidas: ---
;               Efeitos: ---
;===============================================================================
EscString:      PUSH    R1
                PUSH    R2
				PUSH    R3
                MOV     R2, M[SP+6]   ; Apontador para inicio da "string"
                MOV     R3, M[SP+5]   ; Localizacao do primeiro carater
Ciclo:          MOV     M[IO_CURSOR], R3
                MOV     R1, M[R2]
                CMP     R1, FIM_TEXTO
                BR.Z    FimEsc
                CALL    EscCar
                INC     R2
                INC     R3
                BR      Ciclo
FimEsc:         POP     R3
                POP     R2
                POP     R1
                RETN    2                ; Actualiza STACK



;===============================================================================
; EscEcraInicial: Rotina que escreve o ecrã inicial
;===============================================================================
EscEcraInicial: 	PUSH	R1
					CALL    LimpaJanela
					MOV     R1, XY_INICIAL	    ; Coloca R1 a apontar para a pos inicial
					ADD     R1, 0100h			; Mover o cursor para escrever o texto
					PUSH    EcraInicialS1       ; Passagem de parametros pelo STACK
            		PUSH    R1                  ; Passagem de parametros pelo STACK
					CALL	EscString
	       			ADD     R1, 0100h			; Mover o cursor para escrever o texto
          			PUSH    EcraInicialS2       ; Passagem de parametros pelo STACK
            		PUSH    R1                  ; Passagem de parametros pelo STACK
            		CALL    EscString
					ADD		R1, 0100h			; Mover o cursor para escrever o texto
            		PUSH    EcraInicialS3       ; Passagem de parametros pelo STACK
           			PUSH    R1                  ; Passagem de parametros pelo STACK
            		CALL    EscString
            		ADD		R1, 0400h			; Mover o cursor para escrever o texto
            		PUSH    EcraInicialS4       ; Passagem de parametros pelo STACK
           			PUSH    R1                  ; Passagem de parametros pelo STACK
            		CALL    EscString
					ADD		R1, 0100h			; Mover o cursor para escrever o texto
            		PUSH    EcraInicialS5       ; Passagem de parametros pelo STACK
           			PUSH    R1                  ; Passagem de parametros pelo STACK
            		CALL    EscString
					ADD		R1, 0100h			; Mover o cursor para escrever o texto
            		PUSH    EcraInicialS6       ; Passagem de parametros pelo STACK
           			PUSH    R1                  ; Passagem de parametros pelo STACK
            		CALL    EscString
					POP 	R1
					RET

;===============================================================================
; EscEcraRegras: Rotina que escreve o ecrã com as regras do jogo
;===============================================================================
EscEcraRegras: 		PUSH	R1
					CALL    LimpaJanela
					MOV     R1, XY_INICIAL	    ; coloca R1 a apontar para a pos inicial
					ADD     R1, 0100h			; Mover o cursor para escrever o texto
					PUSH    EcraInicialR1       ; Passagem de parametros pelo STACK
            		PUSH    R1                  ; Passagem de parametros pelo STACK
					CALL	EscString
	       			ADD     R1, 0100h			; Mover o cursor para escrever o texto
          			PUSH    EcraInicialR2       ; Passagem de parametros pelo STACK
            		PUSH    R1                  ; Passagem de parametros pelo STACK
            		CALL    EscString
					ADD		R1, 0100h			; Mover o cursor para escrever o texto
            		PUSH    EcraInicialR3       ; Passagem de parametros pelo STACK
           			PUSH    R1                  ; Passagem de parametros pelo STACK
            		CALL    EscString
            		ADD		R1, 0100h			; Mover o cursor para escrever o texto
            		PUSH    EcraInicialR4       ; Passagem de parametros pelo STACK
           			PUSH    R1                  ; Passagem de parametros pelo STACK
            		CALL    EscString
					ADD		R1, 0100h			; Mover o cursor para escrever o texto
            		PUSH    EcraInicialR5       ; Passagem de parametros pelo STACK
           			PUSH    R1                  ; Passagem de parametros pelo STACK
            		CALL    EscString
					ADD		R1, 0100h			; Mover o cursor para escrever o FIM_TEXTO
            		PUSH    EcraInicialR6       ; Passagem de parametros pelo STACK
           			PUSH    R1                  ; Passagem de parametros pelo STACK
            		CALL    EscString
					PUSH    EcraInicialR7       ; Passagem de parametros pelo STACK
            		PUSH    R1                  ; Passagem de parametros pelo STACK
					CALL	EscString
	       			ADD     R1, 0100h			; Mover o cursor para escrever o texto
          			PUSH    EcraInicialR8       ; Passagem de parametros pelo STACK
            		PUSH    R1                  ; Passagem de parametros pelo STACK
            		CALL    EscString
					ADD		R1, 0100h			; Mover o cursor para escrever o texto
            		PUSH    EcraInicialR9       ; Passagem de parametros pelo STACK
           			PUSH    R1                  ; Passagem de parametros pelo STACK
            		CALL    EscString
            		ADD		R1, 0100h			; Mover o cursor para escrever o texto
            		PUSH    EcraInicialR10      ; Passagem de parametros pelo STACK
           			PUSH    R1                  ; Passagem de parametros pelo STACK
            		CALL    EscString
					ADD		R1, 0100h			; Mover o cursor para escrever o texto
            		PUSH    EcraInicialR11      ; Passagem de parametros pelo STACK
           			PUSH    R1                  ; Passagem de parametros pelo STACK
            		CALL    EscString
					ADD		R1, 0100h			; Mover o cursor para escrever o texto
            		PUSH    EcraInicialR12      ; Passagem de parametros pelo STACK
           			PUSH    R1                  ; Passagem de parametros pelo STACK
            		CALL    EscString
					POP 	R1
					RET

;===============================================================================
;  Tabuleiro: gera o tabuleiro onde o jogo será jogado
;===============================================================================
Tabuleiro:			PUSH	R3
					PUSH	R1
					MOV		R3, 000bh			; numero de linhas do tabuleiro(10 para jogar + 1 para a solucao)
					CALL    LimpaJanela
					MOV     R1, XY_INICIAL	    ; coloca R1 a apontar para a pos inicial
            		BR  	cimabaixo 
meio:				ADD     R1, 0100h			; Mover o cursor para escrever o texto
					PUSH    PlanoJogo           ; Passagem de parametros pelo STACK
            		PUSH    R1                  ; Passagem de parametros pelo STACK
					CALL	EscString
					CALL	MostraPecas			; Linha Inicial do tabuleiro
	        		ADD     R1, 0100h			; Mover o cursor para escrever o texto
          			PUSH    Separador           ; Passagem de parametros pelo STACK
            		PUSH    R1                  ; Passagem de parametros pelo STACK
            		CALL    EscString
					DEC		R3 					; por cada linha de tabuleiro, decrementa o numero de linhas
					CMP		R3, R0		    	; todos os espacos de jogo estao criados quando R3=0
					BR.NZ	meio 				; enquanto nao chegar a zero salta para a etiqueta "meio" para continuar a escrever
cimabaixo:			ADD		R1, 0100h			; Mover o cursor para escrever o texto
            		PUSH    Limites             ; Passagem de parametros pelo STACK
            		PUSH    R1                  ; Passagem de parametros pelo STACK
            		CALL    EscString
					CMP		R3, 000bh			; Na primeira iteração, salta para a etiqueta "meio"
					BR.Z	meio
					POP 	R1
					POP		R3
					RET

;===============================================================================
;  GeraRand: Gera número da Cor aleatória
;===============================================================================
GeraRand:			PUSH 	R1
					PUSH 	R2
					MOV		R2, NUM_COR			;move o numero de cores (dará o range de numeros a gerar - 0 a 5)
					MOV		R1, M[SeedIni]		;move o valor da seed 
					DIV		R1, R2				;o resto da divisão é armazenado em R2 (0 a 5)
					MOV 	M[R3], R2			;a cada numero corresponde uma cor 
					POP 	R2
					POP 	R1
					RET	

;===============================================================================
;  CriaSemente:	Cria a semente utilizada para obter a cor
;===============================================================================
CriaSemente: 		PUSH 	R1
					PUSH 	R2
					MOV 	R1, M[SeedIni]		;move o valor da Seed
					MOV 	R2, MASCARA 		;move o valor da mascara
					TEST 	R1, 0001h 			; testar o bit menos significativo
					BR.Z 	bit0   				; Se esse bit for zero, salta logo para a etiqueta bit0
					XOR 	R1, R2   			; Se esse bit for 1, Ni<-Ni xor MASCARA
bit0: 				ROR 	R1, 1   			; Efetua a rotação
					MOV 	M[SeedIni], R1  	; Guarda o valor obtido na Seed
					POP 	R2
					POP 	R1 
					RET
;===============================================================================
;  GeraTudo: Gera todos os números e converte-os para cor
;===============================================================================
GeraTudo:			PUSH	R1
					PUSH	R3
					MOV		R1, NUM_PECAS		;guarda o numero NUM_PECAS a gerar
					MOV		R3, PecaA			;guarda o endereco da primeira peca
gerador:			CALL 	CriaSemente 		;criar semente
					CALL 	GeraRand       		;gerar numero aleatorio 
					CALL 	ConverteCor    		;converter o numero gerado para uma cor 
					INC		R3					;R3 é incrementado para passar ao endereco da peca seguinte
					DEC		R1  				;Decrementa o numero de pecas a gerar
					BR.NZ	gerador  			;Enquanto nao for zero gerar nova peca
					POP		R3
					POP		R1
					RET
;===============================================================================
;  ConverteCor: converte do numero para a respetica cor
;===============================================================================
ConverteCor:		PUSH	R1  				
					MOV		R1, M[R3]   		;guarda a peca (posicao de memoria apontada por R3)		
					ADD		R1, 'A' 			;converte o numero para uma letra de A a Z
					CMP		R1, 'A' 			;compara com 'A' -> cor amarela
					BR.Z	end   				;se for, salta logo para o fim da rotina
					CMP		R1, 'B' 	   		;compara com 'B' -> cor branca
					BR.Z	end    				;se for, salta logo para o fim da rotina
					CMP		R1, 'E' 			;compara com 'E' -> cor encarnada
					BR.Z	end  				;se for, salta logo para o fim da rotina
												;as restantes cores terão de ser obtidas com mais deslocamentos na tabela ASCII
					CMP		R1, 0043h  			;compara com 0043h. Se for, escolhemos a cor preta 'P' 
					BR.NZ	npreto   			;se a comparacao falhar, salta para o proximo teste
					ADD		R1, 000dh           ;para obter o preto 'P' adicionamos 0050h('P')-0043h = 000dh
					BR		end 				;salta logo para o fim da rotina
npreto:				CMP		R1, 0044h           ;compara com 0044h. Se for, escolhemos a cor verde 'V' 
					BR.NZ	nverde  			;se a comparacao falhar, salta para o proximo teste
					ADD		R1, 0012h  			;para obter o verde 'V' adicionamos 0056h('V')-0044h = 0012h
					BR		end  				;salta logo para o fim da rotina
nverde:				ADD		R1, 0014h 			;se todos os testes falharam, trata-se da cor azul('Z'): 005ah('Z')-0046h = 0014h
end:				MOV		M[R3], R1   		;atualizamos a peca (posicao de memoria apontada por R3) com a cor convertida
					POP 	R1
					RET
		
;===============================================================================
;  MeteX: mete as pecas aleatorias com o valor X para se iniciarem assim na 
;		  primeira linha de jogo (onde sera mostrada a solucao)
;===============================================================================
MeteX:				PUSH	R1
					PUSH	R2
					PUSH	R3
					MOV		R3, NUM_PECAS  		;numero NUM_PECAS de pecas a inicializar
					MOV		R1, PecaA  			;guarda o endereco da primeira peca
					MOV		R2, 'X'  			;guarda o valor 'X' a colocar nas pecas
nextmete:			MOV		M[R1], R2  			;atribui esse valor a peca
					INC		R1  				;avanca para a peca a seguir 
					DEC		R3     				;decrementa o numero de pecas
					BR.NZ	nextmete   			;enquanto o numero de pecas nao for zero, continua a inicializar
					POP		R3
					POP 	R2
					POP		R1
					RET
;===============================================================================
; MostraPecas: mostra as pecas geradas
;===============================================================================
MostraPecas: 		PUSH 	R1
					PUSH 	R2
					PUSH 	R3
					PUSH 	R4
					MOV		R3, 0208h    		;mover o cursor para escrever o texto
					MOV		R2, NUM_PECAS   	;mover o numero de pecas a mostrar
					MOV		R4, PecaA  			;mover o endereco da primeira peca
aparece:        	MOV		M[IO_CURSOR], R3
					MOV		R1, M[R4]
					CALL	EscCar
					ADD		R3, 0004h    		;desloca o cursor
					INC		R4    				;avanca nas pecas
					DEC		R2   				;decrementa o numero de pecas a mostrar
					BR.NZ	aparece   			;enquanto esse numero nao for zero continua a mostrar as pecas
					POP		R4
					POP		R3
					POP		R2
					POP		R1
					RET

;===============================================================================
;  Jogada: leitura e escrita no ecra das peças em cada jogada
;===============================================================================
Jogada:				PUSH	R1
					PUSH	R2
					PUSH	R3
					PUSH	R4
					PUSH	R5
					PUSH	R6
					PUSH	R7
					MOV		R3, PecaA  			;Guardar o endereco da primeira peca
					MOV		R4, M[R3]  			;Guardar a primeira peca
					INC		R3  				;Incrementar o endereco
					MOV		R5, M[R3]  			;Guardar a segunda peca
					INC		R3   				;Incrementar o endereco
					MOV		R6, M[R3]  			;Guardar a terceira peca 
					INC		R3   				;Incrementar o endereco
					MOV		R7, M[R3]  			;Guardar a quarta peca
					MOV		R3, TentA  			;Guardar o endereco da primeira tentativa
					MOV		R2, M[SP+9] 		;Guardar a posicao do cursor        	
waitforit:			MOV 	R1, M[EndofTimeFlag];Guardar a flag de fim do cronometro (assinala fim do jogo)
					CMP 	R1, 0001h  			;Se for 1 e porque o jogo terminou
					BR.NZ 	continue			;Se for 0, o jogo ainda nao acabou e salta para a etiqueta continue
					BR 		ending1  			;Se for 1 salta para a etiqueta ending1
help:				BR 		waitforit   		;Etiqueta auxiliar para saltos para a etiqueta waitforit
continue:			MOV		R1, M[IO_STAT] 		;Detetar se foi premida uma tecla
					CMP		R1, R0          	;Se for, a comparacao com R0 vai ser diferente de zero
					BR.Z	waitforit       	;Se nao for, continua a esperar
					MOV		M[IO_CURSOR], R2 	;Mover a posicao do cursor 
					MOV		R1, M[IO_READ]   	;Guardar o que foi lido
												;Testar se o carater lido corresponde uma cor
												;Se for saltar para a etiqueta "valida"
					CMP		R1, 'a'
					BR.Z	valida
					CMP		R1, 'b'
					BR.Z	valida
					CMP		R1, 'e'
					BR.Z	valida
					CMP		R1, 'p'
					BR.Z	valida
					CMP		R1, 'v'
					BR.Z	valida
					CMP		R1, 'z'
					BR.Z	valida
backup:				BR 		help			 	;Se todos os testes de validacao falharem, voltar a esperar por outra tecla
ending1: 			BR 		ending2   			;Etiqueta auxiliar para saltar para a etiqueta ending2
valida:				SUB		R1, 0020h  			;Subtrair 'a'-'A'=0020h para converter para uma letra maiuscula
					CALL	EscCar
					MOV		M[R3], R1  			;Guardar a tentativa
					ADD		R2, 0004h   		;Modificar o cursor para escrever
					INC		R3  				;Avanca o endereco para a proxima tentativa
					MOV		R1, TentD  			;Guarda o endereco da ultima tentativa 
					INC		R1  				;Incrementa o endereço (para uma tentativa invalida)
					CMP		R3, R1  			;Compara a tentativa atual com a invalida
					BR.NZ	backup  			;Enquanto nao for igual, volta a efetuar uma tentativa 
					BR  	validacao  			;Foi igual, salta para a etiqueta validacao
ending2:			BR 		fimjogada   		;Etiqueta auxiliar para saltar para a etiqueta fimjogada
validacao:			MOV		R1, RIGHT_POS  		;Guarda o numero de cores certas na posicao certa
					PUSH	R2  				
					PUSH	R1
					CALL	ValidaJogadaP
					MOV		R3, M[RIGHT_POS]   	;Compara o numero de cores certas na posicao certa com 4
					CMP 	R3, 0004h 
					BR.Z 	fimjogada  		    ; Se for 4 entao o utilizador acertou na sequencia, e saltamos para o fim da rotina
					ADD		R2, 0004h  			;Modificar o cursor para escrever
					PUSH	R2
					PUSH	R1
					CALL	ValidaJogadaB
					MOV		R3, PecaA   		;Guardar de novo o endereco da primeira peca 
					MOV		M[R3], R4  			;Guardar na memoria a primeira peca
					INC		R3   				;Avancar o endereco das pecas
					MOV		M[R3], R5   		;Guardar na memoria a segunda peca 
					INC		R3   				;Avancar o endereco das pecas 
					MOV		M[R3], R6   		;Guardar na memoria a terceira peca 
					INC		R3  				;Avancar o endereco das pecas 
					MOV		M[R3], R7   		;Guardar na memoria a quarta peca
					BR 		fimjogada
fimjogada:			POP		R7
					POP		R6
					POP		R5
					POP		R4
					POP		R3
					POP		R2
					POP		R1
					RETN	1

;===============================================================================
;  ValidaJogadaP: Validacao da sequencia inserida: numero de cores certas e na
; 				  posicao certa
;===============================================================================
ValidaJogadaP:		PUSH	R1
					PUSH	R2
					PUSH	R3
					PUSH	R4
					PUSH	R5
					PUSH	R6
					PUSH	R7
					MOV		R4, TentA			;Guardar o endereco da primeira tentativa
					MOV		R3, PecaA  			;Guardar o endereco da primeira peca
					MOV		R2, NUM_PECAS   	;Guardar o numero de pecas
					MOV		R1, M[SP+9]   		;Guardar o o numero de cores certas na posicao certa
Teste:				MOV		R5, M[R3]  			;Guardar a peca
					MOV		R6, M[R4]  			;Guardar a tentativa
					CMP		R6, R5     			;Comparar a tentativa e a peca
					BR.NZ 	FailedPosition      ;Se o teste falhar salta para a etiqueta "FailedPosition"
					INC 	R1    				;Incrementar o numero de cores certas na posicao certa
					MOV		M[R3], R0   		;Colocar a zero a peca
					MOV		M[R4], R0      		;Colocar a zero a tentativa
FailedPosition:		INC 	R3  				;Avancar nas pecas  
					INC 	R4  				;Avancar nas tentativas 
					DEC 	R2  				;Decrementar o numero de pecas
					BR.NZ	Teste   			;Enquanto o numero de pecas nao for zero continuar a testar
					MOV 	R7, M[SP+10]   		;Guardar o cursor para escrever na janela
					MOV		M[IO_CURSOR], R7  	;Aplicar esse cursor 
					MOV 	M[RIGHT_POS], R1
					ADD		R1, '0'  			;Converter o numero de cores certas na posicao certa para o respetivo caracter ASCII 
					CALL	EscCar
					POP		R7
					POP 	R6
					POP 	R5
					POP 	R4
					POP 	R3
					POP 	R2
					POP 	R1 
					RETN	2

;===============================================================================
;  ValidaJogadaB: Validacao da sequencia inserida
;===============================================================================
ValidaJogadaB:		PUSH	R1
					PUSH	R2
					PUSH	R3
					PUSH	R4
					PUSH	R5
					PUSH	R6
					PUSH	R7
					MOV 	R1, 0000h  			;Colocar o registo 1 a zero, que vai contar o numero de cores certas na posicao errada 
					MOV 	R3, NUM_PECAS       ;Guardar o numero de tentativas (=numero de pecas)
					MOV 	R5, TentA   		;Guardar o endereco da primeira tentativa
TestarTent:			MOV		R7, M[R5]    		;Guardar a atual tentativa
					CMP		R7, R0  			;Comparar a tentativa com zero(ja que se for zero significa que passou o teste ValidaJogadaP)
					BR.Z	NextTent  			;Se for zero, saltar logo para a etiqueta NextTent
					MOV     R2, NUM_PECAS   	;Se nao for zero, guardar noutro registo o numero de pecas
					MOV		R4, PecaA  			;Guardar o endereco da primeira peca
TestarPeca:			MOV 	R6, M[R4]   		;Guardar a peca atual
					CMP		R6, R0   			;Comparar a peca com zero(ja que se for zero significa que passou o teste ValidaJogadaP)
					BR.Z	NextPeca  			;Se for zero, saltar logo para a etiqueta NextPeca
					CMP 	R7, R6   			;Comparar a peca e a tentativa
					BR.NZ 	NextPeca 			;Se o teste nao for zero, saltar logo para a etiqueta NextPeca
					MOV		M[R5], R0   		;Se for zero, colocar a tentativa a zero 
					MOV		M[R4], R0   		;E colocar a peca a zero 
					INC 	R1  				;Incrementar o numero de cores certas na posicao errada
					BR 		NextTent  			;Saltar para a etiqueta NextTent
NextPeca: 			INC 	R4  				;Avancar nos enderecos das pecas 
					DEC		R2   				;Decrementar o numero de pecas 
					BR.NZ 	TestarPeca 			;Enquanto nao chegar a zero, saltar para a etiqueta TestarPeca
NextTent: 			INC 	R5   				;Avancar nos enderecos das tentativas 
					DEC 	R3 					;Decrementar o numero de tentativas 
					BR.NZ 	TestarTent    		;Enquanto nao chegar a zero, saltar para a etiqueta TestarTent
					MOV 	R7, M[SP+10]   		;Guardar o cursor para escrever na janela
					MOV		M[IO_CURSOR], R7 	;Aplicar esse cursor
					ADD		R1, 0030h  			;Converter o numero de cores certas na posicao errada para o respetivo caracter ASCII 
					CALL	EscCar      		
					POP		R7
					POP 	R6
					POP 	R5
					POP 	R4
					POP 	R3
					POP 	R2
					POP 	R1 
					RETN 	2

;===============================================================================
;InitInt: Inicializa TVI, Mascara de INT e Temporizador
;               Entradas: ---
;               Saidas: ---
;               Efeitos: ---
;===============================================================================
InitInt:        	MOV     R1, RotinaInt0
                	MOV     M[TAB_INT0], R1
					MOV     R1, RotinaIntTemp
                	MOV     M[TAB_INTTemp], R1
					MOV		R1,8003h 
					MOV		M[MASCARA_INT], R1
					MOV		R1,000ah 
					MOV		M[TempValor], R1
					MOV		R1,0001h 
					MOV		M[TempControlo], R1
                	ENI
                	RET



;===============================================================================
; RotinaIntTemp: Rotina de interrupcao do temporizador
;               Entradas: R4 
;               Saidas:   R4 
;               Efeitos: (1) Activa Leds com valor de R4
;                        (2) Reprograma temporizador
;===============================================================================
RotinaIntTemp:  	PUSH 	R1
					PUSH 	R2
					PUSH 	R3
					PUSH 	R4
					PUSH 	R5
					PUSH 	R6
					PUSH 	R7
					MOV 	R2, M[EndofTimeFlag];Guardar a variável de fim do cronometro(acabou o jogo)
					MOV 	R3, M[RIGHT_POS]  	;Guardar a variavel de corescertas na posicao certa
					MOV 	R7, M[Aux7]         ;Guardar a variável dezenas de minuto (sempre 0)
					MOV		R6, M[Aux6]			;Guardar a variável unidades de minuto (0 a 2)
					MOV		R5, M[Aux5]  		;Guardar a variável dezenas de segundo (0 a 5)
					MOV     R4, M[Aux4]  		;Guardar a variável unidades de segundo (0 a 9)
					CMP 	R2, 0001H    		;Verificar se a flag de fim do cronometro esta ativa 
					BR.Z    GoToEnd 			;Se estiver saltar logo para o fim(o cronometro ja terminou)
					CMP 	R3, 0004H  			;Verificar se o utilizador ja acertou na sequencia completa 
					BR.Z 	alreadywon          ;Se sim, saltar logo para a etiqueta alreadywon
					CMP 	R6, 0002H 			;Comparar com 2(Inicio da Contagem)
					BR.Z 	Write 				;Se for o inicio, saltar logo para a etiqueta "Write"
					CMP 	R6, FFFFh 			;Comparar com -1(Fim da contagem de minutos)
					BR.Z 	GoToEnd 			;Se for o final, saltar logo para o final, sem escrita
Next:           	DEC 	R4  				;Decrementar o número de segundos
					CMP 	R4, FFFFh 			;Comparar com -1(Fim da contagem de unidades de segundo)
					BR.Z 	Restore1  			;Se for o final, saltar para a etiqueta Restore1 
					BR 		Write 				;Se nao for o final, saltar para a escrita 
Restore1:			MOV 	R4, 0009h 			;Voltar a colocar as unidades de segundo a 9 
					DEC 	R5 					;Decrementar as dezenas de segundo 
					CMP 	R5, FFFFh 			;Comparar com -1(Fim da contagem de dezenas de segundo)
					BR.Z 	Restore2   			;Se for o final, saltar para a etiqueta Restore2
					BR 		Write 				;Se nao for o final, saltar para a escrita
Restore2: 			MOV 	R5, 0005h  			;Voltar a colocar as dezenas de segundo a 5
					DEC		R6 					;Decrementar os minutos 
					CMP 	R6, FFFFh 			;Comparar com -1(Fim da contagem de minutos)
GoToEnd:			BR.Z 	Finish   			;Se for o final, saltar para a etiqueta End
					BR      Write   			;Se nao for o final, saltar para a etiqueta Write
alreadywon:			BR 	    End   				;Etiqueta auxiliar para saltar para o fim(End)
Write:          	MOV     M[DISP7S1], R4 		;Escrever as unidades de segundo no primeiro display 
					MOV 	M[DISP7S2], R5      ;Escrever as dezenas de segundo no segundo display 
					MOV     M[DISP7S3], R6 		;Escrever as unidades de minuto no terceiro display
					MOV		M[DISP7S4], R7  	;Escrever as dezenas de minuto no quarto display
					CMP 	R6, 0002h 			;Comparar o valor dos minutos om 2 (primeira iteracao)
					BR.NZ 	Ignore 				;Se nao for igual, saltar logo para a etiqueta Ignore
					DEC 	R6 					;Se for entao deve-se 1-decrementar os minutos 
					MOV 	R5, 0005h  			;2-Por as dezenas de segundo a 5 
					MOV 	R4, 000ah			;3-Por as unidades de segundo a 10(pois serao decrementadas quando a rotina voltar a ser iterada)
Ignore:				MOV		R1, 000ah 			
					MOV		M[TempValor], R1 	;Colocar na posicao de memoria apontada por TempValor o valor 10 para o cronometro avancar segundo a segundo
					MOV		R1,0001h 
					MOV		M[TempControlo], R1 ;Colocar na posicao de memoria apontada por TempControlo o valor 1 para o cronometro avancar efetivamente
					BR 		End 				;Saltar para o fim(o cronometro ainda nao acabou)
Finish:             MOV     R2, 0001h   		;Ativar a flag do fim do cronometro
					MOV 	M[EndofTimeFlag], R2;Guardar a flag na memoria				
End:				MOV 	M[Aux6], R6 		;Guardar na memoria o valor das unidades de minuto 
					MOV 	M[Aux5], R5 		;Guardar na memoria o valor das dezenas de segundo 
					MOV		M[Aux4], R4 		;Guardar na memoria o valor das unidades de segundo 
					POP 	R7
					POP 	R6
					POP 	R5
					POP 	R4
					POP 	R3
					POP 	R2
					POP		R1
                	RTI

;===============================================================================
; GameOverLose: Mensagem de final do jogo em que o utilizador perdeu
;===============================================================================

GameOverLose: 	PUSH R1
				MOV  R1, 0000h
				PUSH Message1
				PUSH R1
				CALL EscString
				POP  R1
				RET


;===============================================================================
; GameOverWin: Mensagem de final do jogo em que o utilizador ganhou
;===============================================================================

GameOverWin: 	PUSH R1
				MOV  R1, 0000h
				PUSH Message2
				PUSH R1
				CALL EscString
				POP  R1
				RET

		
;===============================================================================
;                                Programa principal
;===============================================================================
inicio:         	MOV     R1, SP_INICIAL   	
                	MOV     SP, R1
                	MOV 	R3, 0000h 			;Registo para guardar um "tempo" ficticio enquanto o jogo nao comeca 
                	CALL 	EscEcraInicial 		;Escrever o Menu Inicial
notstart:       	INC 	R3   				;Incrementar esse "tempo" enquanto nao for premida uma tecla
					MOV		R2, M[IO_STAT] 		;Detetar se foi premida uma tecla
					CMP		R2, R0   			;Se for, a comparacao com R0 vai ser diferente de zero
					BR.Z	notstart    		;Se nao for, continua a esperar
					INC 	R3 					;Incrementar esse tempo quando a tecla é pressionada
					MOV		R1, M[IO_READ]   	;Guardar o que foi lido
					CMP		R1, '2' 			;Comparar com a opcao 2 (Mostrar Regras)
					BR.NZ	skipregras   		;Se nao for igual, saltar logo para a etiqueta "skipregras" 
					INC 	R3      			;Incrementar esse tempo se for escolhida a opcao de mostrar regras
					CALL	EscEcraRegras       ;Se for igual, escrever o menu de regras
					BR		notstart    		;Saltar de novo para a etiqueta notstart
skipregras:			INC  	R3     				;Incrementar esse tempo quando a tecla é pressionada
					CMP		R1, '1'  			;Comparar a tecla pressionada com a opcao 1(Jogar)
					BR.NZ	notstart      		;Se nao for igual, saltar de novo para a etiqueta "notstart"(a tecla pressionada nao e valida)
					MOV 	R4, M[SeedIni]      ;Se for igual, comecar por duardar a Seed
					MOV 	R4, R3    			;Mover o valor obtido do tempo ficticio para a seed
					MOV 	M[SeedIni], R4      ;Guardar a seed na memoria 
					MOV 	R3, XY_INICIAL      ;Guardar a posicao inicial do cursor de texto
					MOV		M[IO_CURSOR], R3    ;Carregar essa posicao no cursor 
					MOV		R2, M[IO_READ]      ;Guardar o carater que foi lido 
					CALL 	LimpaJanela         
					CALL 	MeteX               
					CALL 	Tabuleiro
					CALL 	GeraTudo
					CALL 	InitInt
					MOV		R1, NUM_JOGADAS     ;Guardar o numero de jogadas 
					MOV		R2, 1608h	        ;Guardar a nova posicao de escrita no ecra
tentar:				PUSH	R2
					MOV 	R3, M[EndofTimeFlag];Guardar a flag do fim do cronometro
					CMP 	R3, 0001h  			;Verificar se a flag esta ativa 
					BR.Z 	FimLose  			;Se estiver, saltar para a etiqueta FimLose (o jogador perdeu)
					CALL 	Jogada
					MOV 	R4, M[RIGHT_POS]  	;Guardar o numero de cores certas na posicao certa
					CMP 	R4, 0004h   		;Verificar se o utilizador ja acertou na sequencia
					BR.Z 	FimWin  			;Se ja tiver acertado, saltar para a etiqueta FimWin(o jogador ganhou)
					SUB		R2, 0200h           ;Passar à linha superior (proxima jogada)
					DEC		R1                  ;Decrementar o numero de jogadas 
					BR.NZ	tentar              ;Enquanto nao for zero, continuar a jogar
FimLose:           	CALL 	GameOverLose   		;Se o jogador perceu, escrever essa mensagem
					BR 		Fim       			
FimWin:				CALL 	GameOverWin  		;Se o jogador ganhou, escrever essa mensagem
Fim:				CALL 	MostraPecas   		;No final, mostrar qual a sequencia
					BR      Fim
;==================================================================================
