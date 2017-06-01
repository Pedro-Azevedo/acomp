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
	VECSIZE 	EQU 0007h
	NUM_COR		EQU	0006h		;numero de cores 
	NUM_JOGADAS EQU 000ah
	MASCARA		EQU	9C16h		;mascara para geração

; JANELA DA PLACA
	DISP7S1         EQU     FFF0h
	DISP7S2         EQU     FFF1h
	DISP7S3         EQU     FFF2h
	DISP7S4			EQU		FFF3h
	LCD_WRITE		EQU		FFF5h
	LCD_CURSOR		EQU		FFF4h	

; I/O a partir de FF00H
	IO_CURSOR       EQU     FFFCh
	IO_WRITE        EQU     FFFEh
	IO_STAT		EQU	FFFDh
	IO_READ		EQU	FFFFh

; INTERRUPCOES
	TAB_INTTemp     EQU     FE0Fh
	MASCARA_INT	EQU	FFFAh
	TAB_INT0	EQU	FE00h

	LIMPAR_JANELA   EQU     FFFFh
	XY_INICIAL      EQU     0004h
	XY_INTROD	EQU	2207h
	FIM_TEXTO       EQU     '@'

; TEMPORIZADOR
	TempValor	EQU	FFF6h
	TempControlo	EQU	FFF7h

;===============================================================================
; ZONA II: Definicao de variaveis
;===============================================================================
 		ORIG    8000h
;Variáveis de texto do tabuleiro
PlanoJogo       STR     ' |!   !   !   !   !| P/  B|', FIM_TEXTO
PlanoJogo2      STR 	' |!   !   !   !   !   !| P/  B|', FIM_TEXTO
PlanoJogo3      STR     ' |!   !   !   !   !   !   !| P/  B|', FIM_TEXTO
Limites       	STR	'<=========================>', FIM_TEXTO
Limites2	STR 	'<===============================>', FIM_TEXTO
Limites3   	STR 	'<==================================>', FIM_TEXTO
Separador       STR     ' -------------------------', FIM_TEXTO
Separador2      STR     ' -------------------------------', FIM_TEXTO
Separador3      STR     ' ----------------------------------', FIM_TEXTO
EcraInicialS1	STR	'   _   _     _    ___  _____  ___  ___   _   _   _ _       __', FIM_TEXTO
EcraInicialS2	STR	'  / \ / \   /_\  |___    |   |___ |___| / \ / \   |  |\ | |  \', FIM_TEXTO
EcraInicialS3	STR	' /   V   \ /   \  ___|   |   |___ |\   /   V   \ _|_ | \| |__/', FIM_TEXTO
EcraInicialS4 	STR 	'               Bem-vindo(a) ao jogo Mastermind!', FIM_TEXTO 
EcraInicialS5	STR	'	 		1 - Jogar', FIM_TEXTO
EcraInicialS6	STR	'			R - Como Jogar?', FIM_TEXTO
EcraInicialS7	STR	'			M - MultiPlayer',FIM_TEXTO
EcraInicialS8   STR 	' 			D - Dificuldade',FIM_TEXTO
EcraInicialS9	STR	'Nota: o jogo comeca em modo standard (4 pecas:2 min) podes altera-lo em "D"',FIM_TEXTO
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
EcraInicialR12	STR	'numero limite de jogadas seja atingido.', FIM_TEXTO
EcraInicialR13	STR	'Prima S para sair', FIM_TEXTO	
EcraInicialM1	STR	'		    	BEM VINDO AO MODO MULTIPLAYER', FIM_TEXTO
EcraInicialMX	STR	'=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=',FIM_TEXTO
EcraInicialM2	STR	'Escolha o numero de jogadores: ',FIM_TEXTO
EcraInicialM3	STR	'    	2	  3	    4	      5	        6',FIM_TEXTO
EcraInicialD1 	STR 	'      ANTES DE INICIAR O JOGO, ESCOLHA A DIFICULADE DE ALGUNS PARAMETROS', FIM_TEXTO
EcraInicialD2   STR 	'Escolha o tempo: ', FIM_TEXTO
EcraInicialD3	STR	'    	1	  2	    4',FIM_TEXTO 
EcraInicialD4   STR 	'Escolha o numero de cores: ', FIM_TEXTO
EcraInicialD5	STR	'    	4	  5	    6',FIM_TEXTO 
EcraInicialNJ1	STR	'Prima N para passar a',FIM_TEXTO 
EcraInicialNJ2	STR	'vez ao jogador seguinte!',FIM_TEXTO
EcraFinalW1	STR	'PARABENS! GANHASTE',FIM_TEXTO	
EcraFinalW2	STR	'Jogador',FIM_TEXTO
EcraFinalW3	STR	'Tentativas:',FIM_TEXTO
EcraFinalW4	STR	'Tempo Restante:',FIM_TEXTO
EcraFinalD1	STR	'      Parece que houve um...',FIM_TEXTO
EcraFinalD2	STR	'                                                  ...empate!',FIM_TEXTO
EcraFinalD3	STR	'~~~~~~~~~~~~~~~~~~~~REPETE O JOGO PARA DESEMPATAR!~~~~~~~~~~~~~~~~~~~~~~',FIM_TEXTO
EcraFinalL1	STR	'==================OH QUE PENA! PERDERAM TODOS O JOGO.===================',FIM_TEXTO
Message1 	STR 	'PERDESTE! FIM DO JOGO', FIM_TEXTO
Message2 	STR 	'CONSEGUISTE! PARABENS!', FIM_TEXTO
Message3    STR 	'Prima Q para um novo jogo', FIM_TEXTO 
;Variaveis de geração de peças
PecaA		WORD	0000h
PecaB		WORD	0000h
PecaC		WORD	0000h
PecaD		WORD	0000h		;4 words para cada peça versao standard
PecaE		WORD	0000h		;5 ou 6 words no caso da versao adptada
PecaF		WORD	0000h	
AuxPecaA    WORD 	0000h
AuxPecaB  	WORD    0000h 
AuxPecaC 	WORD 	0000h 
AuxPecaD 	WORD 	0000h 
AuxPecaE 	WORD 	0000h 
AuxPecaF   	WORD 	0000h 	
SeedIni		WORD	998Ch		;seed de geração´
TentA		WORD	0000h
TentB		WORD	0000h
TentC		WORD	0000h
TentD		WORD	0000h
TentE		WORD	0000h
TentF		WORD	0000h
;Variaveis para o cronometro
Aux7		WORD	0000h
Aux6		WORD	0004h
Aux5		WORD	0000h
Aux4		WORD	0000h
RIGHT_POS	WORD 	0000h		;numero de cores certas na posicao certa
RIGHT_COL	WORD	0000h		;numero de cores certas
EndofTimeFlag	WORD 	0000h
;VariaveisJogada
SPecaA		WORD	0000h
SPecaB		WORD	0000h
SPecaC		WORD	0000h
SPecaD		WORD	0000h
SPecaE		WORD	0000h
SPecaF		WORD	0000h
;Variaveis Multiplayer
NumJgds		WORD	0000h
WinTent		WORD	0000h
WinNmbr		WORD	0000h
RealTime6	WORD	0000h
RealTime5	WORD	0000h
RealTime4	WORD	0000h
RealTent	WORD	000Bh
RealNmbr	WORD	0000h
DrawFlag	WORD	0000h
MultiFlag	WORD	0000h
;Variaveis Nivel
NumPecas 	WORD 	0004h
CronTmp 	WORD 	0002h
;Variaveis Estatisticas
ContagemJogos 	WORD 	0000h 
ContaJogadas 	WORD 	0000h
MelhorTempoMin 	TAB 	VECSIZE
MelhorTempoDec	TAB 	VECSIZE 
MelhorTempoSeg 	TAB 	VECSIZE 
MediaTempoMin	TAB   	VECSIZE
MediaTempoDec 	TAB 	VECSIZE
MediaTempoSeg 	TAB 	VECSIZE 
SumTempoMin		TAB 	VECSIZE 
SumTempoDec 	TAB 	VECSIZE 
SumTempoSeg 	TAB 	VECSIZE
SumNumJogadas 	TAB 	VECSIZE
MediaNumJogadas TAB 	VECSIZE 
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
		MOV 	R1, 0001h 				;Para isso ativamos a flag usada quando o cronometro para de contar 
		MOV 	M[EndofTimeFlag], R1
		POP 	R1
                RTI
;===============================================================================
; LimpaJanela: Rotina que limpa a janela de texto.
;===============================================================================
LimpaJanela:    PUSH 	R2
                MOV     R2, LIMPAR_JANELA
		MOV     M[IO_CURSOR], R2
                POP 	R2
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
; CLRLCD: Rotina para limpar LCD
;               Entradas:  
;               Saidas:    
;               Efeitos: 
;===============================================================================
CLRLCD:         PUSH    R1
                MOV     R1, 8020h
				MOV		M[LCD_CURSOR], R1
                POP     R1
                RET
;===============================================================================
; ESCLCD: Rotina para escrita no LCD
;               Entradas: R4, R1 
;               Saidas:    
;               Efeitos: 
;===============================================================================
EscLCD:         PUSH    R1 
				PUSH    R2
				PUSH 	R3 
				MOV     R1, 8000h     		;Escrita de Jog#
                MOV     R2, 'J'
				MOV		M[LCD_CURSOR], R1
				MOV		M[LCD_WRITE], R2
				INC 	R1 
				MOV 	R2, 'O' 
				MOV		M[LCD_CURSOR], R1
				MOV		M[LCD_WRITE], R2
				INC 	R1 
				MOV 	R2, 'G' 
				MOV		M[LCD_CURSOR], R1
				MOV		M[LCD_WRITE], R2
				INC 	R1 
				MOV 	R2, M[WinNmbr]
				ADD 	R2, 0030h           ;Conversão para o caracter ASCII
				MOV		M[LCD_CURSOR], R1
				MOV		M[LCD_WRITE], R2
				INC 	R1
				INC 	R1
				INC 	R1 
				INC 	R1
				MOV 	R2, 'J' 
				MOV		M[LCD_CURSOR], R1
				MOV		M[LCD_WRITE], R2 
				INC 	R1 
				MOV 	R2, 'G' 
				MOV		M[LCD_CURSOR], R1
				MOV		M[LCD_WRITE], R2
				INC 	R1 
				MOV 	R2, 'D' 
				MOV		M[LCD_CURSOR], R1
				MOV		M[LCD_WRITE], R2
				INC 	R1 
				MOV 	R2, 'S' 
				MOV		M[LCD_CURSOR], R1
				MOV		M[LCD_WRITE], R2
				INC 	R1 
				MOV 	R2, ':' 
				INC 	R1 
				MOV 	R3, M[WinNmbr]	
				MOV     R2,MediaNumJogadas
				ADD 	R2, R3 
				MOV 	R2, M[R2]
				ADD 	R2, 0030h
				MOV		M[LCD_CURSOR], R1
				MOV		M[LCD_WRITE], R2
				MOV 	R1,8010h
				MOV 	R2, 'T' 
				MOV		M[LCD_CURSOR], R1
				MOV		M[LCD_WRITE], R2 
				INC 	R1 
				MOV 	R2, 'E' 
				MOV		M[LCD_CURSOR], R1
				MOV		M[LCD_WRITE], R2
				INC 	R1 
				MOV 	R2, 'M' 
				MOV		M[LCD_CURSOR], R1
				MOV		M[LCD_WRITE], R2
				INC 	R1 
				MOV 	R2, 'P' 
				MOV		M[LCD_CURSOR], R1
				MOV		M[LCD_WRITE], R2
				INC 	R1 
				MOV 	R2, 'O' 
				MOV		M[LCD_CURSOR], R1
				MOV		M[LCD_WRITE], R2
				INC 	R1 
				MOV 	R2, ':' 
				MOV		M[LCD_CURSOR], R1
				MOV		M[LCD_WRITE], R2
				INC 	R1
				INC     R1
				MOV     R2,MediaTempoMin
				ADD 	R2, R3 
				MOV 	R2, M[R2]
				ADD 	R2, 0030h
				MOV		M[LCD_CURSOR], R1
				MOV		M[LCD_WRITE], R2
				INC 	R1 
				MOV 	R2, ':' 
				MOV		M[LCD_CURSOR], R1
				MOV		M[LCD_WRITE], R2
				INC   	R1
				MOV     R2,MediaTempoDec
				ADD 	R2, R3 
				MOV 	R2, M[R2]
				ADD 	R2, 0030h
				MOV		M[LCD_CURSOR], R1
				MOV		M[LCD_WRITE], R2
				INC 	R1 
				MOV     R2,MediaTempoSeg
				ADD 	R2, R3 
				MOV 	R2, M[R2]
				ADD 	R2, 0030h
				MOV		M[LCD_CURSOR], R1
				MOV		M[LCD_WRITE], R2
				INC 	R1 
				INC 	R1
				MOV     R2,MelhorTempoMin
				ADD 	R2, R3 
				MOV 	R2, M[R2]
				ADD 	R2, 0030h
				MOV		M[LCD_CURSOR], R1
				MOV		M[LCD_WRITE], R2
				INC 	R1 
				MOV 	R2, ':' 
				MOV		M[LCD_CURSOR], R1
				MOV		M[LCD_WRITE], R2
				INC 	R1
				MOV     R2,MelhorTempoDec
				ADD 	R2, R3 
				MOV 	R2, M[R2]
				ADD 	R2, 0030h
				MOV		M[LCD_CURSOR], R1
				MOV		M[LCD_WRITE], R2
				INC 	R1
				MOV     R2,MelhorTempoSeg
				ADD 	R2, R3 
				MOV 	R2, M[R2]
				ADD 	R2, 0030h
				MOV		M[LCD_CURSOR], R1
				MOV		M[LCD_WRITE], R2
				POP 	R3
                POP     R2
                POP     R1
                RET

;===============================================================================
; EscEcraInicial: Rotina que escreve o ecrã inicial
;===============================================================================
EscEcraInicial: PUSH	R1
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
		ADD	R1, 0100h			; Mover o cursor para escrever o texto
            	PUSH    EcraInicialS3       ; Passagem de parametros pelo STACK
           	PUSH    R1                  ; Passagem de parametros pelo STACK
            		CALL    EscString
            	ADD	R1, 0400h			; Mover o cursor para escrever o texto
            	PUSH    EcraInicialS4       ; Passagem de parametros pelo STACK
           	PUSH    R1                  ; Passagem de parametros pelo STACK
            		CALL    EscString
		ADD	R1, 0100h			; Mover o cursor para escrever o texto
            	PUSH    EcraInicialS5       ; Passagem de parametros pelo STACK
           	PUSH    R1                  ; Passagem de parametros pelo STACK
            		CALL    EscString
		ADD	R1, 0100h			; Mover o cursor para escrever o texto
            	PUSH    EcraInicialS6       ; Passagem de parametros pelo STACK
           	PUSH    R1                  ; Passagem de parametros pelo STACK
            		CALL    EscString
		ADD	R1, 0100h			; Mover o cursor para escrever o texto
            	PUSH    EcraInicialS7      ; Passagem de parametros pelo STACK
           	PUSH    R1                  ; Passagem de parametros pelo STACK
            		CALL    EscString
            	ADD 	R1, 0100h
            	PUSH    EcraInicialS8      ; Passagem de parametros pelo STACK
           	PUSH    R1                  ; Passagem de parametros pelo STACK
            		CALL    EscString
		ADD 	R1, 0400h
            	PUSH    EcraInicialS9      ; Passagem de parametros pelo STACK
           	PUSH    R1                  ; Passagem de parametros pelo STACK
            		CALL    EscString
		POP 	R1
		RET
;===============================================================================
; EscEcraRegras: Rotina que escreve o ecrã com as regras do jogo
;===============================================================================
EscEcraRegras: 	PUSH	R1
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
		ADD	R1, 0100h			; Mover o cursor para escrever o texto
            	PUSH    EcraInicialR3       ; Passagem de parametros pelo STACK
           	PUSH    R1                  ; Passagem de parametros pelo STACK
            		CALL    EscString
            	ADD	R1, 0100h			; Mover o cursor para escrever o texto
            	PUSH    EcraInicialR4       ; Passagem de parametros pelo STACK
           	PUSH    R1                  ; Passagem de parametros pelo STACK
            		CALL    EscString
		ADD	R1, 0100h			; Mover o cursor para escrever o texto
            	PUSH    EcraInicialR5       ; Passagem de parametros pelo STACK
           	PUSH    R1                  ; Passagem de parametros pelo STACK
            		CALL    EscString
		ADD	R1, 0100h			; Mover o cursor para escrever o FIM_TEXTO
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
		ADD	R1, 0100h			; Mover o cursor para escrever o texto
            	PUSH    EcraInicialR9       ; Passagem de parametros pelo STACK
           	PUSH    R1                  ; Passagem de parametros pelo STACK
            		CALL    EscString
            	ADD	R1, 0100h			; Mover o cursor para escrever o texto
            	PUSH    EcraInicialR10      ; Passagem de parametros pelo STACK
           	PUSH    R1                  ; Passagem de parametros pelo STACK
            		CALL    EscString
		ADD	R1, 0100h			; Mover o cursor para escrever o texto
            	PUSH    EcraInicialR11      ; Passagem de parametros pelo STACK
           	PUSH    R1                  ; Passagem de parametros pelo STACK
            		CALL    EscString
		ADD	R1, 0100h			; Mover o cursor para escrever o texto
            	PUSH    EcraInicialR12      ; Passagem de parametros pelo STACK
           	PUSH    R1                  ; Passagem de parametros pelo STACK
            		CALL    EscString
		ADD	R1, 0400h			; Mover o cursor para escrever o texto
            	PUSH    EcraInicialR13      ; Passagem de parametros pelo STACK
           	PUSH    R1                  ; Passagem de parametros pelo STACK
            		CALL    EscString
		POP 	R1
		RET
;===============================================================================
; EscEcraMulti: Rotina que escreve o ecrã com as regras do jogo
;===============================================================================
EscEcraMulti: 	PUSH	R1
			CALL    LimpaJanela
		MOV     R1, XY_INICIAL	    ; coloca R1 a apontar para a pos inicial
		ADD     R1, 0100h			; Mover o cursor para escrever o texto
		PUSH    EcraInicialMX       ; Passagem de parametros pelo STACK
            	PUSH    R1                  ; Passagem de parametros pelo STACK
			CALL	EscString
		ADD     R1, 0200h
		PUSH    EcraInicialM1       ; Passagem de parametros pelo STACK
            	PUSH    R1                  ; Passagem de parametros pelo STACK
			CALL	EscString
		ADD     R1, 0200h
		PUSH    EcraInicialMX       ; Passagem de parametros pelo STACK
            	PUSH    R1                  ; Passagem de parametros pelo STACK
			CALL	EscString
		ADD     R1, 0200h
		PUSH    EcraInicialM2	   ; Passagem de parametros pelo STACK
            	PUSH    R1                  ; Passagem de parametros pelo STACK
			CALL	EscString
		ADD     R1, 0200h
		PUSH    EcraInicialM3       ; Passagem de parametros pelo STACK
            	PUSH    R1                  ; Passagem de parametros pelo STACK
			CALL	EscString
		POP 	R1
		RET
;===============================================================================
; EscEcraDific1: Rotina que escreve o ecrã com as regras do jogo
;===============================================================================
EscEcraDific1: 	PUSH	R1
			CALL    LimpaJanela
		MOV     R1, XY_INICIAL	    ; coloca R1 a apontar para a pos inicial
		ADD     R1, 0100h			; Mover o cursor para escrever o texto
		PUSH    EcraInicialD1       ; Passagem de parametros pelo STACK
            	PUSH    R1                  ; Passagem de parametros pelo STACK
			CALL	EscString
		ADD     R1, 0200h
		PUSH    EcraInicialD2       ; Passagem de parametros pelo STACK
            	PUSH    R1                  ; Passagem de parametros pelo STACK
			CALL	EscString
		ADD     R1, 0200h
		PUSH    EcraInicialD3       ; Passagem de parametros pelo STACK
            	PUSH    R1                  ; Passagem de parametros pelo STACK
			CALL	EscString
		POP 	R1
		RET
;===============================================================================
; EscEcraDific: Rotina que escreve o ecrã com as regras do jogo
;===============================================================================
EscEcraDific2: 	PUSH	R1
			CALL    LimpaJanela
		MOV     R1, XY_INICIAL	    ; coloca R1 a apontar para a pos inicial
		ADD     R1, 0100h			; Mover o cursor para escrever o texto
		PUSH    EcraInicialD1       ; Passagem de parametros pelo STACK
            	PUSH    R1                  ; Passagem de parametros pelo STACK
			CALL	EscString
		ADD     R1, 0200h
		PUSH    EcraInicialD4	   ; Passagem de parametros pelo STACK
            	PUSH    R1                  ; Passagem de parametros pelo STACK
			CALL	EscString
		ADD     R1, 0200h
		PUSH    EcraInicialD5       ; Passagem de parametros pelo STACK
            	PUSH    R1                  ; Passagem de parametros pelo STACK
			CALL	EscString
		POP 	R1
		RET
;===============================================================================
;  Tabuleiro4: gera o tabuleiro onde o jogo será jogado
;===============================================================================
Tabuleiro4:	PUSH	R1
		PUSH	R3
		MOV	R3, 000bh			; numero de linhas do tabuleiro(10 para jogar + 1 para a solucao)
			CALL    LimpaJanela
		MOV     R1, XY_INICIAL	    ; coloca R1 a apontar para a pos inicial
            	BR 	cimabaixo4 
meio4:		ADD     R1, 0100h			; Mover o cursor para escrever o texto
		PUSH    PlanoJogo           ; Passagem de parametros pelo STACK
        	PUSH    R1                  ; Passagem de parametros pelo STACK
			CALL	EscString
			CALL	PecasaX			; Linha Inicial do tabuleiro
	        ADD     R1, 0100h			; Mover o cursor para escrever o texto
          	PUSH    Separador           ; Passagem de parametros pelo STACK
            	PUSH    R1                  ; Passagem de parametros pelo STACK
            		CALL    EscString
		DEC	R3 					; por cada linha de tabuleiro, decrementa o numero de linhas
		CMP	R3, R0		    	; todos os espacos de jogo estao criados quando R3=0
		BR.NZ	meio4 				; enquanto nao chegar a zero salta para a etiqueta "meio" para continuar a escrever
cimabaixo4:	ADD	R1, 0100h			; Mover o cursor para escrever o texto
            	PUSH    Limites             ; Passagem de parametros pelo STACK
            	PUSH    R1                  ; Passagem de parametros pelo STACK
            		CALL    EscString
		CMP	R3, 000bh			; Na primeira iteração, salta para a etiqueta "meio"
		BR.Z	meio4
		POP 	R3
		POP	R1
		RET
;===============================================================================
;  Tabuleiro5: gera o tabuleiro onde o jogo será jogado
;===============================================================================
Tabuleiro5:	PUSH	R1
		PUSH	R3
		MOV		R3, 000bh			; numero de linhas do tabuleiro(10 para jogar + 1 para a solucao)
			CALL    LimpaJanela
		MOV     R1, XY_INICIAL	    ; coloca R1 a apontar para a pos inicial
            	BR  	cimabaixo5 
meio5:		ADD     R1, 0100h			; Mover o cursor para escrever o texto
		PUSH    PlanoJogo2           ; Passagem de parametros pelo STACK
            	PUSH    R1                  ; Passagem de parametros pelo STACK
			CALL	EscString
			CALL	MostraPecas			; Linha Inicial do tabuleiro
	        ADD     R1, 0100h			; Mover o cursor para escrever o texto
          	PUSH    Separador2           ; Passagem de parametros pelo STACK
            	PUSH    R1                  ; Passagem de parametros pelo STACK
            		CALL    EscString
		DEC	R3 					; por cada linha de tabuleiro, decrementa o numero de linhas
		CMP	R3, R0		    	; todos os espacos de jogo estao criados quando R3=0
		BR.NZ	meio5 				; enquanto nao chegar a zero salta para a etiqueta "meio" para continuar a escrever
cimabaixo5:	ADD	R1, 0100h			; Mover o cursor para escrever o texto
            	PUSH    Limites2             ; Passagem de parametros pelo STACK
            	PUSH    R1                  ; Passagem de parametros pelo STACK
            		CALL   EscString
		CMP	R3, 000bh			; Na primeira iteração, salta para a etiqueta "meio"
		BR.Z	meio5
		POP 	R3
		POP	R1
		RET
;===============================================================================
;  Tabuleiro6: gera o tabuleiro onde o jogo será jogado
;===============================================================================
Tabuleiro6:	PUSH	R1
		PUSH	R3
		MOV		R3, 000bh			; numero de linhas do tabuleiro(10 para jogar + 1 para a solucao)
			CALL    LimpaJanela
		MOV     R1, XY_INICIAL	    ; coloca R1 a apontar para a pos inicial
            	BR  	cimabaixo6 
meio6:		ADD     R1, 0100h			; Mover o cursor para escrever o texto
		PUSH    PlanoJogo3           ; Passagem de parametros pelo STACK
	        PUSH    R1                  ; Passagem de parametros pelo STACK
			CALL	EscString
			CALL	MostraPecas			; Linha Inicial do tabuleiro
	        ADD     R1, 0100h			; Mover o cursor para escrever o texto
          	PUSH    Separador3           ; Passagem de parametros pelo STACK
            	PUSH    R1                  ; Passagem de parametros pelo STACK
            		CALL    EscString
		DEC	R3 					; por cada linha de tabuleiro, decrementa o numero de linhas
		CMP	R3, R0		    	; todos os espacos de jogo estao criados quando R3=0
		BR.NZ	meio6 				; enquanto nao chegar a zero salta para a etiqueta "meio" para continuar a escrever
cimabaixo6:	ADD	R1, 0100h			; Mover o cursor para escrever o texto
            	PUSH    Limites3             ; Passagem de parametros pelo STACK
            	PUSH    R1                  ; Passagem de parametros pelo STACK
            		CALL   EscString
		CMP	R3, 000bh			; Na primeira iteração, salta para a etiqueta "meio"
		BR.Z	meio6
		POP 	R3
		POP	R1
		RET
;===============================================================================
;  GeraRand: Gera número da Cor aleatória
;===============================================================================
GeraRand:	PUSH 	R1
		PUSH 	R2
		MOV	R2, NUM_COR			;move o numero de cores (dará o range de numeros a gerar - 0 a 5)
		MOV	R1, M[SeedIni]		;move o valor da seed 
		DIV	R1, R2				;o resto da divisão é armazenado em R2 (0 a 5)
		MOV 	M[R3], R2			;a cada numero corresponde uma cor 
		POP 	R2
		POP 	R1
		RET	
;===============================================================================
;  CriaSemente:	Cria a semente utilizada para obter a cor
;===============================================================================
CriaSemente: 	PUSH 	R1
		PUSH 	R2
		MOV 	R1, M[SeedIni]		;move o valor da Seed
		MOV 	R2, MASCARA 		;move o valor da mascara
		TEST 	R1, 0001h 			; testar o bit menos significativo
		BR.Z 	bit0   				; Se esse bit for zero, salta logo para a etiqueta bit0
		XOR 	R1, R2   			; Se esse bit for 1, Ni<-Ni xor MASCARA
bit0: 		ROR 	R1, 1   			; Efetua a rotação
		MOV 	M[SeedIni], R1  	; Guarda o valor obtido na Seed
		POP 	R2
		POP 	R1 
		RET
;===============================================================================
;  GeraTudo: Gera todos os números e converte-os para cor
;===============================================================================
GeraTudo:	PUSH	R1
			PUSH	R3
			MOV	R1, M[NumPecas]		;guarda o numero NUM_PECAS a gerar
			MOV	R3, PecaA			;guarda o endereco da primeira peca
gerador:	CALL 	CriaSemente 		;criar semente
			CALL 	GeraRand       		;gerar numero aleatorio 
			CALL 	ConverteCor    		;converter o numero gerado para uma cor 
			INC	R3					;R3 é incrementado para passar ao endereco da peca seguinte
			DEC	R1  				;Decrementa o numero de pecas a gerar
			BR.NZ	gerador  			;Enquanto nao for zero gerar nova peca
			POP	R3
			POP	R1
			RET
;===============================================================================
;  ConverteCor: converte do numero para a respetica cor
;===============================================================================
ConverteCor:	PUSH	R1  				
		MOV	R1, M[R3]   		;guarda a peca (posicao de memoria apontada por R3)		
		ADD	R1, 'A' 			;converte o numero para uma letra de A a Z
		CMP	R1, 'A' 			;compara com 'A' -> cor amarela
		BR.Z	end   				;se for, salta logo para o fim da rotina
		CMP	R1, 'B' 	   		;compara com 'B' -> cor branca
		BR.Z	end    				;se for, salta logo para o fim da rotina
		CMP	R1, 'E' 			;compara com 'E' -> cor encarnada
		BR.Z	end  				;se for, salta logo para o fim da rotina
							;as restantes cores terão de ser obtidas com mais deslocamentos na tabela ASCII
		CMP	R1, 0043h  			;compara com 0043h. Se for, escolhemos a cor preta 'P' 
		BR.NZ	npreto   			;se a comparacao falhar, salta para o proximo teste
		ADD	R1, 000dh           ;para obter o preto 'P' adicionamos 0050h('P')-0043h = 000dh
		BR	end 				;salta logo para o fim da rotina
npreto:		CMP	R1, 0044h           ;compara com 0044h. Se for, escolhemos a cor verde 'V' 
		BR.NZ	nverde  			;se a comparacao falhar, salta para o proximo teste
		ADD	R1, 0012h  			;para obter o verde 'V' adicionamos 0056h('V')-0044h = 0012h
		BR	end  				;salta logo para o fim da rotina
nverde:		ADD	R1, 0014h 			;se todos os testes falharam, trata-se da cor azul('Z'): 005ah('Z')-0046h = 0014h
end:		MOV	M[R3], R1   		;atualizamos a peca (posicao de memoria apontada por R3) com a cor convertida
		POP 	R1
		RET
		
;===============================================================================
;  MeteX: mete as pecas aleatorias com o valor X para se iniciarem assim na 
;		  primeira linha de jogo (onde sera mostrada a solucao)
;===============================================================================
MeteX:		PUSH	R1
		PUSH	R2
		PUSH	R3
		MOV	R3, M[NumPecas]  		;numero NUM_PECAS de pecas a inicializar
		MOV	R1, AuxPecaA  			;guarda o endereco da primeira peca
		MOV	R2, 'X'  			;guarda o valor 'X' a colocar nas pecas
nextmete:	MOV	M[R1], R2  			;atribui esse valor a peca
		INC	R1  				;avanca para a peca a seguir 
		DEC	R3     				;decrementa o numero de pecas
		BR.NZ	nextmete   			;enquanto o numero de pecas nao for zero, continua a inicializar
		POP	R3
		POP 	R2
		POP	R1
		RET
;===============================================================================
; MostraPecas: mostra as pecas geradas
;===============================================================================
MostraPecas: 	PUSH 	R1
		PUSH 	R2
		PUSH 	R3
		PUSH 	R4
		MOV	R3, 0208h    		;mover o cursor para escrever o texto
		MOV	R2, M[NumPecas]   	;mover o numero de pecas a mostrar
		MOV	R4, PecaA  			;mover o endereco da primeira peca
aparece:        MOV	M[IO_CURSOR], R3
		MOV	R1, M[R4]
			CALL	EscCar
		ADD	R3, 0004h    		;desloca o cursor
		INC	R4    				;avanca nas pecas
		DEC	R2   				;decrementa o numero de pecas a mostrar
		BR.NZ	aparece   			;enquanto esse numero nao for zero continua a mostrar as pecas
		POP	R4
		POP	R3
		POP	R2
		POP	R1
		RET

;===============================================================================
; PecasaX: mostra as pecas geradas
;===============================================================================
PecasaX: 	PUSH 	R1
			PUSH 	R2
			PUSH 	R3
			PUSH 	R4
			MOV	R3, 0208h    		;mover o cursor para escrever o texto
			MOV	R2, M[NumPecas]   	;mover o numero de pecas a mostrar
			MOV	R4, AuxPecaA  			;mover o endereco da primeira peca
apareceX:    MOV	M[IO_CURSOR], R3
			MOV	R1, M[R4]
			CALL	EscCar
			ADD	R3, 0004h    		;desloca o cursor
			INC	R4    				;avanca nas pecas
			DEC	R2   				;decrementa o numero de pecas a mostrar
			BR.NZ	apareceX   			;enquanto esse numero nao for zero continua a mostrar as pecas
			POP	R4
			POP	R3
			POP	R2
			POP	R1
			RET

;===============================================================================
;  Jogada: leitura e escrita no ecra das peças em cada jogada
;===============================================================================
Jogada:	PUSH	R1
		PUSH	R2
		PUSH	R3
		PUSH	R4
		PUSH	R5
		PUSH	R6
		PUSH	R7
						;Guardar as peças em memoria auxiliar temporariamente
		INC 	M[ContaJogadas]
		MOV	R4, PecaA
		MOV	R5, SPecaA
		MOV R7, R0 
SavePecas:	MOV	R6, M[R4]
		MOV	M[R5], R6
		INC	R4
		INC	R5
		INC	R7
		CMP	R7, M[NumPecas]
		BR.NZ	SavePecas
		MOV	R7, R0
		MOV	R3, TentA  			;Guardar o endereco da primeira tentativa
		MOV	R2, M[SP+9] 		;Guardar a posicao do cursor        	
waitforit:	MOV 	R1, M[EndofTimeFlag]	;Guardar a flag de fim do cronometro (assinala fim do jogo)
		CMP 	R1, 0001h  			;Se for 1 e porque o jogo terminou
		BR.NZ 	continue			;Se for 0, o jogo ainda nao acabou e salta para a etiqueta continue
		JMP	fimjogada			;Se for 1 salta para a etiqueta ending1
help:		BR	waitforit   		;Etiqueta auxiliar para saltos para a etiqueta waitforit
continue:	MOV	R1, M[IO_STAT] 		;Detetar se foi premida uma tecla
		CMP	R1, R0          	;Se for, a comparacao com R0 vai ser diferente de zero
		BR.Z	waitforit       	;Se nao for, continua a esperar
		MOV	M[IO_CURSOR], R2 	;Mover a posicao do cursor 
		MOV	R1, M[IO_READ]   	;Guardar o que foi lido
							;Testar se o carater lido corresponde uma cor
							;Se for saltar para a etiqueta "valida"
		CMP	R1, 'a'
		BR.Z	valida
		CMP	R1, 'b'
		BR.Z	valida
		CMP	R1, 'e'
		BR.Z	valida
		CMP	R1, 'p'
		BR.Z	valida
		CMP	R1, 'v'
		BR.Z	valida
		CMP	R1, 'z'
		BR.Z	valida
backup:		BR 	help			 	;Se todos os testes de validacao falharem, voltar a esperar por outra tecla
valida:		SUB	R1, 0020h  			;Subtrair 'a'-'A'=0020h para converter para uma letra maiuscula
			CALL	EscCar
		MOV	M[R3], R1  			;Guardar a tentativa
		ADD	R2, 0004h   		;Modificar o cursor para escrever
		INC	R3  				;Avanca o endereco para a proxima tentativa
		INC	R7
		CMP	R7, M[NumPecas]  			;Compara a tentativa atual com a invalida
		BR.NZ	backup  			;Enquanto nao for igual, volta a efetuar uma tentativa 
		BR  	validacao  			;Foi igual, salta para a etiqueta validacao
validacao:	MOV	R1, M[RIGHT_POS] 		;Guarda o numero de cores certas na posicao certa
		PUSH	R2  				
		PUSH	R1
			CALL	ValidaJogadaP
		MOV	R3, M[RIGHT_POS]   	;Compara o numero de cores certas na posicao certa com 4
		CMP 	R3, 0004h 
		BR.Z 	fimjogada  		    ; Se for 4 entao o utilizador acertou na sequencia, e saltamos para o fim da rotina
		ADD	R2, 0004h  			;Modificar o cursor para escrever
		PUSH	R2
		PUSH	R1
			CALL	ValidaJogadaB
		MOV	R7, R0
		MOV	R4, PecaA
		MOV	R5, SPecaA
LoadPecas:	MOV	R6, M[R5]
		MOV	M[R4], R6
		INC	R4
		INC	R5
		INC	R7
		CMP	R7, M[NumPecas]
		BR.NZ	LoadPecas
fimjogada:  POP	R7
		POP	R6
		POP	R5
		POP	R4
		POP	R3
		POP	R2
		POP	R1
		RETN	1
;===============================================================================
;  ValidaJogadaP: Validacao da sequencia inserida: numero de cores certas e na
; 				  posicao certa
;===============================================================================
ValidaJogadaP:	PUSH	R1
		PUSH	R2
		PUSH	R3
		PUSH	R4
		PUSH	R5
		PUSH	R6
		PUSH	R7
		MOV	R4, TentA		;Guardar o endereco da primeira tentativa
		MOV	R3, PecaA  		;Guardar o endereco da primeira peca
		MOV	R2, M[NumPecas]   ;Guardar o numero de pecas
		MOV	R1, M[SP+9]   	;Guardar o o numero de cores certas na posicao certa
Teste:		MOV	R5, M[R3]  		;Guardar a peca
		MOV	R6, M[R4]  		;Guardar a tentativa
		CMP	R6, R5     		;Comparar a tentativa e a peca
		BR.NZ 	FailedPosition      	;Se o teste falhar salta para a etiqueta "FailedPosition"
		INC 	R1    			;Incrementar o numero de cores certas na posicao certa
		MOV	M[R3], R0   		;Colocar a zero a peca
		MOV	M[R4], R0      		;Colocar a zero a tentativa
FailedPosition:	INC 	R3  			;Avancar nas pecas  
		INC 	R4  			;Avancar nas tentativas 
		DEC 	R2  			;Decrementar o numero de pecas
		BR.NZ	Teste   		;Enquanto o numero de pecas nao for zero continuar a testar
		MOV 	R7, M[SP+10]   		;Guardar o cursor para escrever na janela
		MOV	M[IO_CURSOR], R7  	;Aplicar esse cursor 
		MOV 	M[RIGHT_POS], R1
		ADD	R1, '0'  		;Converter o numero de cores certas na posicao certa para o respetivo caracter ASCII 
			CALL	EscCar
		POP	R7
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
ValidaJogadaB:	PUSH	R1
		PUSH	R2
		PUSH	R3
		PUSH	R4
		PUSH	R5
		PUSH	R6
		PUSH	R7
		MOV 	R1, 0000h  		;Colocar o registo 1 a zero, que vai contar o numero de cores certas na posicao errada 
		MOV 	R3, M[NumPecas]      	;Guardar o numero de tentativas (=numero de pecas)
		MOV 	R5, TentA   		;Guardar o endereco da primeira tentativa
TestarTent:	MOV	R7, M[R5]    		;Guardar a atual tentativa
		CMP	R7, R0  			;Comparar a tentativa com zero(ja que se for zero significa que passou o teste ValidaJogadaP)
		BR.Z	NextTent  			;Se for zero, saltar logo para a etiqueta NextTent
		MOV     R2, M[NumPecas]   	;Se nao for zero, guardar noutro registo o numero de pecas
		MOV	R4, PecaA  			;Guardar o endereco da primeira peca
TestarPeca:	MOV 	R6, M[R4]   		;Guardar a peca atual
		CMP	R6, R0   			;Comparar a peca com zero(ja que se for zero significa que passou o teste ValidaJogadaP)
		BR.Z	NextPeca  			;Se for zero, saltar logo para a etiqueta NextPeca
		CMP 	R7, R6   			;Comparar a peca e a tentativa
		BR.NZ 	NextPeca 			;Se o teste nao for zero, saltar logo para a etiqueta NextPeca
		MOV	M[R5], R0   		;Se for zero, colocar a tentativa a zero 
		MOV	M[R4], R0   		;E colocar a peca a zero 
		INC 	R1  				;Incrementar o numero de cores certas na posicao errada
		BR 	NextTent  			;Saltar para a etiqueta NextTent
NextPeca: 	INC 	R4  				;Avancar nos enderecos das pecas 
		DEC	R2   				;Decrementar o numero de pecas 
		BR.NZ 	TestarPeca 			;Enquanto nao chegar a zero, saltar para a etiqueta TestarPeca
NextTent: 	INC 	R5   				;Avancar nos enderecos das tentativas 
		DEC 	R3 					;Decrementar o numero de tentativas 
		BR.NZ 	TestarTent    		;Enquanto nao chegar a zero, saltar para a etiqueta TestarTent
		MOV 	R7, M[SP+10]   		;Guardar o cursor para escrever na janela
		MOV	M[IO_CURSOR], R7 	;Aplicar esse cursor
		ADD	R1, 0030h  			;Converter o numero de cores certas na posicao errada para o respetivo caracter ASCII 
			CALL	EscCar      		
		POP	R7
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
InitInt:        MOV     R1, RotinaInt0
                MOV     M[TAB_INT0], R1
		MOV     R1, RotinaIntTemp
                MOV     M[TAB_INTTemp], R1
		MOV	R1,8003h 
		MOV	M[MASCARA_INT], R1
		MOV	R1,000ah 
		MOV	M[TempValor], R1
		MOV	R1,0001h 
		MOV	M[TempControlo], R1
                ENI
                RET
;===============================================================================
; RotinaIntTemp: Rotina de interrupcao do temporizador
;               Entradas: R4 
;               Saidas:   R4 
;               Efeitos: (1) Activa Leds com valor de R4
;                        (2) Reprograma temporizador
;===============================================================================
RotinaIntTemp:  PUSH 	R1
		PUSH 	R2
		PUSH 	R3
		PUSH 	R4
		PUSH 	R5
		PUSH 	R6
		PUSH 	R7
		MOV 	R2, M[EndofTimeFlag]		;Guardar a variável de fim do cronometro(acabou o jogo)
		MOV 	R3, M[RIGHT_POS]  		;Guardar a variavel de cores certas na posicao certa
		MOV 	R7, M[Aux7]		       	;Guardar a variável dezenas de minuto (sempre 0)
		MOV	R6, M[Aux6]			;Guardar a variável unidades de minuto (0 a 2)
		MOV	R5, M[Aux5]	  		;Guardar a variável dezenas de segundo (0 a 5)
		MOV     R4, M[Aux4]  			;Guardar a variável unidades de segundo (0 a 9)
		CMP 	R2, 0001H    			;Verificar se a flag de fim do cronometro esta ativa 
		BR.Z    GoToEnd 			;Se estiver saltar logo para o fim(o cronometro ja terminou)
		CMP 	R3, 0004H  			;Verificar se o utilizador ja acertou na sequencia completa 
		BR.Z 	alreadywon 		        ;Se sim, saltar logo para a etiqueta alreadywon
		CMP 	R6, M[CronTmp]			;Comparar com 2(Inicio da Contagem) 
		BR.Z 	Write 				;Se for o inicio, saltar logo para a etiqueta "Write"
		CMP 	R6, FFFFh 			;Comparar com -1(Fim da contagem de minutos)
		BR.Z 	GoToEnd 			;Se for o final, saltar logo para o final, sem escrita
Next:           DEC 	R4  				;Decrementar o número de segundos
		CMP 	R4, FFFFh 			;Comparar com -1(Fim da contagem de unidades de segundo)
		BR.Z 	Restore1  			;Se for o final, saltar para a etiqueta Restore1 
		BR 	Write 				;Se nao for o final, saltar para a escrita 
Restore1:	MOV 	R4, 0009h 			;Voltar a colocar as unidades de segundo a 9 
		DEC 	R5 				;Decrementar as dezenas de segundo 
		CMP 	R5, FFFFh 			;Comparar com -1(Fim da contagem de dezenas de segundo)
		BR.Z 	Restore2   			;Se for o final, saltar para a etiqueta Restore2
		BR 	Write 				;Se nao for o final, saltar para a escrita
Restore2: 	MOV 	R5, 0005h  			;Voltar a colocar as dezenas de segundo a 5
		DEC	R6 				;Decrementar os minutos 
		CMP 	R6, FFFFh 			;Comparar com -1(Fim da contagem de minutos)
		BR.Z 	GoToEnd   			;Se for o final, saltar para a etiqueta End
		BR      Write   			;Se nao for o final, saltar para a etiqueta Write
alreadywon:	BR 	End
GoToEnd:	BR	Finish				
Write:          MOV     M[DISP7S1], R4 			;Escrever as unidades de segundo no primeiro display 
		MOV 	M[DISP7S2], R5      		;Escrever as dezenas de segundo no segundo display 
		MOV     M[DISP7S3], R6 			;Escrever as unidades de minuto no terceiro display
		MOV	M[DISP7S4], R7  		;Escrever as dezenas de minuto no quarto display
		CMP 	R6, M[CronTmp] 			;Comparar o valor dos minutos om 2 (primeira iteracao)
		BR.NZ 	Ignore 					;Se nao for igual, saltar logo para a etiqueta Ignore
		DEC 	R6 						;Se for entao deve-se 1-decrementar os minutos 
		MOV 	R5, 0005h  				;2-Por as dezenas de segundo a 5 
		MOV 	R4, 000ah			;	3-Por as unidades de segundo a 10(pois serao decrementadas quando a rotina voltar a ser iterada)
Ignore:		MOV	R1, 000ah
		MOV	M[TempValor], R1	 	;Colocar na posicao de memoria apontada por TempValor o valor 10 para o cronometro avancar segundo a segundo
		MOV	R1,0001h 	;Guardar na memoria o valor das dezenas de segundo 
			MOV		M[TempControlo], R1		;Colocar na posicao de memoria apontada por TempControlo o valor 1 para o cronometro avancar efetivamente
			BR 		End 					;Saltar para o fim(o cronometro ainda nao acabou)
Finish:   MOV     R2, 0001h   			;Ativar a flag do fim do cronometro
		MOV 	M[EndofTimeFlag], R2		;Guardar a flag na memoria				
End:	MOV 	M[Aux6], R6 		;Guardar na memoria o valor das unidades de minuto 
		MOV 	M[Aux5], R5 		;Guardar na memoria o valor das dezenas de segundo 
		MOV		M[Aux4], R4 		;Guardar na memoria o valor das unidades de segundo 
		POP 	R7
		POP 	R6
		POP 	R5
		POP 	R4
		POP 	R3
		POP 	R2
		POP	R1
                RTI
;===============================================================================
; GameOverLose: Mensagem de final do jogo em que o utilizador perdeu
;===============================================================================
GameOverLose: 	PUSH 	R1
				MOV  	R1, 0932h
				PUSH 	Message1
				PUSH 	R1
				CALL 	EscString
				ADD     R1, 0100h 
				PUSH 	Message3
				PUSH 	R1
				CALL 	EscString
				MOV		R1, 0001h
				MOV		M[EndofTimeFlag],R1
				POP  	R1
				RET
;==============================================================================
; GameOverWin: Mensagem de final do jogo em que o utilizador ganhou
;===============================================================================
GameOverWin: 	PUSH 	R1
		MOV  	R1, 0932h
		PUSH 	Message2
		PUSH 	R1
			CALL 	EscString
			ADD     R1, 0100h 
			PUSH 	Message3
			PUSH 	R1
			CALL 	EscString
		MOV	R1, 0001h
		MOV	M[EndofTimeFlag],R1
		CALL Estatisticas 
		CALL EscLCD
		POP  	R1
		RET
;===============================================================================
; MenuEscolhe: Escolhe o item do menu que pretende aceder
;===============================================================================
MenuEscolhe:	PUSH	R1
		PUSH 	R2
		PUSH	R3
EI:			CALL 	EscEcraInicial
waitpress:	INC 	R3   				;Incrementar esse "tempo" enquanto nao for premida uma tecla
		MOV	R2, M[IO_STAT]			;Detetar se foi premida uma tecla
		INC 	R3
		CMP	R2, R0   			;Se for, a comparacao com R0 vai ser diferente de zero
		BR.Z	waitpress  			;Se nao for, continua a esperar
		INC 	R3 
		MOV 	R1, M[IO_READ]
		INC 	R3
		CMP 	R1, 'r'
		BR.NZ 	saltaregras
			CALL 	ExplicaRegras
		JMP 	EI
saltaregras:	CMP 	R1, 'm' 
		BR.NZ 	singleplayer
			CALL 	NumeroJogador
		JMP 	fimmenu
singleplayer: 	CMP  	R1, 'd' 
		BR.NZ 	difchosen
			CALL 	EscolheTempo
			CALL 	EscolheCores
		JMP 	EI
difchosen: 	CMP 	R1, '1'
		BR.NZ   notavalidpress
		SUB	R1, 0030h
		MOV	M[NumJgds],R1
		JMP  	fimmenu
notavalidpress: JMP 	EI
fimmenu:	INC	R3
		MOV 	M[SeedIni], R3      ;Guardar a seed na memoria
		POP	R3 
		POP   	R2
		POP	R1
		RET	
;=================================================================================
; ResetTime: Retoma ao tempo inicial
;=================================================================================
ResetTime:	PUSH	R1
		MOV 	M[Aux7], R0			;coloca-se as dezenas de minuto a 0
		MOV	R1, M[CronTmp]			
		MOV	M[Aux6],R1			;coloca-se os minutos novamente no valor definido no inicio do jogo
		MOV	M[Aux5],R0			
		MOV	M[Aux4],R0
		MOV	M[EndofTimeFlag],R0		;coloca-se as dezenas de segundo, os segundos e a flag do fim de tempo todos a 0
		POP	R1
		RET
;=================================================================================
; ExplicaRegras: 
;=================================================================================
ExplicaRegras:	PUSH	R1
		PUSH 	R2
			CALL 	EscEcraRegras
StartR:		MOV 	R2, M[IO_STAT]
		CMP 	R2, R0 
		BR.Z 	StartR				;espera-se até que uma tecla seja premida
		MOV 	R1, M[IO_READ]
		CMP 	R1, 's' 
		BR.NZ	StartR				;se essa tecla for o 's' sai-se da função, senão espera-se por nova tecla
		POP 	R2
		POP 	R1
		RET
;=================================================================================
; NumeroJogador: rotina responsavel por analizar o numero de jogadores escolhidos 
;=================================================================================
NumeroJogador:	PUSH	R1
		PUSH 	R2
			CALL 	EscEcraMulti
		MOV	R2,0001h
		ADD	M[MultiFlag],R2			;Ativa a flag multiplayer
StartNJ:	MOV 	R2, M[IO_STAT]
		CMP 	R2, R0 
		BR.Z 	StartNJ				;espera até que uma tecla seja premida
		MOV 	R1, M[IO_READ]
		CMP 	R1, '2' 
		BR.N 	StartNJ
		CMP 	R1, '6'
		BR.P 	StartNJ				;se a tecla premida não corresponder a um numero entre 2 e 6 espera-se por nova tecla
		SUB 	R1, 0030h 			;converte-se o valor ASCII da tecla em hexa
		MOV 	M[NumJgds], R1			;coloca-se o numero de jogadores na memoria para vir a ser usado
		POP 	R2
		POP 	R1
		RET
;=================================================================================
; EscolheTempo: rotina responsavel por analizar o tempo escolhido
;=================================================================================
EscolheTempo:	PUSH	R1
		PUSH 	R2 
			CALL 	EscEcraDific1
StartTmp:	MOV 	R2, M[IO_STAT]
		CMP 	R2, R0 
		BR.Z 	StartTmp
		MOV 	R1, M[IO_READ]
		CMP 	R1, '1'
		BR.N 	StartTmp
		CMP 	R1, '4'
		BR.P 	StartTmp
		CMP 	R1, '3'
		BR.Z 	StartTmp
		SUB 	R1, 0030h 
		MOV 	M[CronTmp], R1
		POP 	R2 
		POP 	R1 
		RET
;=================================================================================
; EscolheCores: rotina responsavel por analizar o numero de cores escolhidas 
;=================================================================================
EscolheCores:	PUSH	R1
		PUSH 	R2 
			CALL 	EscEcraDific2
StartClr:	MOV 	R2, M[IO_STAT]
		CMP 	R2, R0 
		BR.Z 	StartClr
		MOV 	R1, M[IO_READ]
		CMP 	R1, '4'
		BR.N 	StartClr
		CMP 	R1, '6' 
		BR.P 	StartClr
		SUB 	R1, 0030h 
		MOV 	M[NumPecas], R1
		POP 	R2
		POP 	R1
		RET
		
		
;===============================================================================
; SaveGame: Rotina que guarda os dados do jogo de forma a apresentar o vencedor
;===============================================================================
SaveGame:	PUSH	R1
		MOV	R1,M[WinTent]		
		CMP	M[RealTent],R1			;Compara o numero de tentativas do jogador com o melhor guardado
		BR.NN	proxcmp				
		JMP	fimsalvo			;Se o numero de tentativas for maior, salta para o fim
proxcmp:	CMP	M[RealTent],R1			;Compara novamente o numero de tentativas entre o jogador e o melhor
		BR.NP	proxitem			
		JMP	guardarjg			;Se for menor, salta para gravar os dados do jogador atual
proxitem:	MOV	R1,M[Aux6]			
		CMP	M[RealTime6],R1			;Sendo iguais o numero de tentativas, compara-se os minutos
		BR.NP	proxcmp1			
		JMP	fimsalvo			;Se os minutos restantes do jogador forem os menores, salta para o fim
proxcmp1:	CMP	M[RealTime6],R1			;Compara novamente os minutos
		BR.N	guardarjg			;Se os minutos restantes do jogador forem maiores, salta para gravar os dados do jogador atual
		MOV	R1,M[Aux5]			
		CMP	M[RealTime5],R1			
		BR.NP	proxcmp2			;Sendo iguais o numero de tentativas e os minutos restantes é repetido o processo dos minutos para
		JMP	fimsalvo			;as dezenas de segundo e se também não se puder apurar um vencedor é ainda repetido para os segundos
proxcmp2:	CMP	M[RealTime5],R1
		BR.N	guardarjg
		MOV	R1,M[Aux4]
		CMP	M[RealTime4],R1
		BR.P	fimsalvo
		CMP	M[RealTime4],R1
		BR.N	guardarjg
		MOV	R1, 0001h
		MOV	M[DrawFlag],R1			;Em ultima instância (no caso de todos os dados serem iguais) é ativada uma flag de empate
		BR	fimsalvo			;Contudo os dados não são alterados para o caso de um 3º jogador vier a fazer melhor
guardarjg:	MOV	R1, M[WinTent]
		MOV	M[RealTent],R1
		MOV	R1,M[WinNmbr]
		MOV	M[RealNmbr],R1
		MOV	R1,M[Aux6]
		MOV	M[RealTime6],R1
		MOV	R1,M[Aux5]
		MOV	M[RealTime5],R1
		MOV	R1,M[Aux4]
		MOV	M[RealTime4],R1
		MOV	M[DrawFlag],R0			;Caso o jogador ganhe comparativamente ao melhor todos os dados são guardados e a flag de empate é colocada a 0
fimsalvo:	POP	R1				;A flag de empate é colocada a 0 para o caso de o jogo estar previamente empatado mas um 3º jogador tiver vindo ganhar
		RET
;===============================================================================
; Delay: rotina que espera pelo jogador seguinte
;===============================================================================
 Delay:		PUSH	R1
		PUSH	R2
		MOV     R1, 0a32h	    		; Coloca R1 a apontar para a pos do texto
		PUSH    EcraInicialNJ1      		; Passagem de parametros pelo STACK
           	PUSH    R1                  		; Passagem de parametros pelo STACK
			CALL	EscString
		ADD	R1, 0100h
		PUSH    EcraInicialNJ2       		; Passagem de parametros pelo STACK
            	PUSH    R1                  		; Passagem de parametros pelo STACK
			CALL	EscString
redelay:	MOV	R2, M[IO_STAT]			;Detetar se foi premida uma tecla
		CMP	R2, R0   			;Se for, a comparacao com R0 vai ser diferente de zero
		BR.Z	redelay  			;Se nao for, continua a esperar
		MOV	R1, M[IO_READ]   		;Guardar o que foi lido
		CMP	R1, 'n'
		BR.NZ	redelay				;Se a tecla premida não for N espera por nova tecla premida
			CALL	ResetTime		;Se premiu N, dá reset as variaveis associadas ao temporizador
		POP	R2
		POP	R1
		RET
;===============================================================================
; EscEcraFinalW: rotina que imprime o ecra final com os resultados do jogo no caso de vitoria
;===============================================================================
 EscEcraFinalW:	PUSH	R1
		PUSH	R2
			CALL	LimpaJanela
		MOV     R2, 0600h	    		; Coloca R1 a apontar para a pos do texto
		PUSH    EcraFinalW1       		; Passagem de parametros pelo STACK
            	PUSH    R2                  		; Passagem de parametros pelo STACK
			CALL	EscString
		ADD	R2, 0100h
		PUSH    EcraFinalW2       		; Passagem de parametros pelo STACK
            	PUSH    R2                  		; Passagem de parametros pelo STACK
			CALL	EscString
		ADD	R2, 000ah
		MOV	M[IO_CURSOR],R2
		MOV	R1,M[RealNmbr]			
		ADD	R1,0030h			;Coloca o valor ASCII do numero do jogador em R1 e imprime-o
			CALL	EscCar
		SUB	R2, 000ah			;Retoma á coluna 0 do ecrã
		ADD	R2, 0100h
		PUSH    EcraFinalW3       		; Passagem de parametros pelo STACK
            	PUSH    R2                  		; Passagem de parametros pelo STACK
			CALL	EscString
		ADD	R2, 000bh
		MOV	M[IO_CURSOR],R2
		MOV	R1,M[RealTent]
		ADD	R1,0030h			;Coloca o valor ASCII do numero de tentativas em R1 e imprime-o
			CALL	EscCar
		SUB	R2, 000bh			;Retoma á coluna 0 do ecrã
		ADD	R2, 0100h
		PUSH    EcraFinalW4     		; Passagem de parametros pelo STACK
            	PUSH    R2                  		; Passagem de parametros pelo STACK
			CALL	EscString
		ADD	R2, 0010h
		MOV	M[IO_CURSOR],R2
		MOV	R1,M[RealTime6]			
		ADD	R1,0030h			;Coloca o valor ASCII dos minutos em R1 e imprime-o
			CALL	EscCar
		INC	R2				;Passa á coluna seguinte
		MOV	M[IO_CURSOR],R2
		MOV	R1,':'				;Depois imprime o caractere ":"
			CALL	EscCar
		INC	R2				;Passa á coluna seguinte
		MOV	M[IO_CURSOR],R2
		MOV	R1,M[RealTime5]
		ADD	R1,0030h			;Coloca o valor ASCII das dezenas de segundo em R1 e imprime-o
			CALL	EscCar
		INC	R2				;Passa á coluna seguinte
		MOV	M[IO_CURSOR],R2
		MOV	R1,M[RealTime4]
		ADD	R1,0030h			;Coloca o valor ASCII dos segundos em R1 e imprime-o
			CALL	EscCar
		ADD	R2, 0500h
		PUSH    Message3       		; Passagem de parametros pelo STACK
          PUSH    R2                  		; Passagem de parametros pelo STACK
		CALL	EscString
		POP	R2
		POP	R1
		RET
;===============================================================================
; EscEcraFinalD: rotina que imprime o ecrã final no caso de empate
;===============================================================================
EscEcraFinalD:	PUSH	R1
				CALL	LimpaJanela
				MOV     R2, 0600h	    		; Coloca R1 a apontar para a pos do texto
				PUSH    EcraFinalD1       		; Passagem de parametros pelo STACK
            	PUSH    R2                  		; Passagem de parametros pelo STACK
				CALL	EscString
				ADD	R2, 0100h		
				PUSH    EcraFinalD2       		; Passagem de parametros pelo STACK
            	PUSH    R2                  		; Passagem de parametros pelo STACK
				CALL	EscString
				ADD	R2, 0500h
				PUSH    EcraFinalD3       		; Passagem de parametros pelo STACK
            	PUSH    R2                  		; Passagem de parametros pelo STACK
				CALL	EscString
				ADD	R2, 0500h
				PUSH    Message3       		; Passagem de parametros pelo STACK
            	PUSH    R2                  		; Passagem de parametros pelo STACK
				CALL	EscString
				POP	R1
				RET

;===============================================================================
; EscEcraFinalL: rotina que imprime o ecrã final no caso de empate
;===============================================================================
EscEcraFinalL:	PUSH	R1
				CALL	LimpaJanela
				MOV     R2, 0a00h	   		; Coloca R1 a apontar para a pos do texto
				PUSH    EcraFinalL1       		; Passagem de parametros pelo STACK
            	PUSH    R2                  		; Passagem de parametros pelo STACK
				CALL	EscString
				ADD	R2, 0500h
				PUSH    Message3       		; Passagem de parametros pelo STACK
            	PUSH    R2                  		; Passagem de parametros pelo STACK
				CALL	EscString		
				POP		R1
				RET


;===============================================================================
; Estatisticas: rotina que estuda as estatisticas do jogo 
;===============================================================================
Estatisticas:	PUSH R1
				PUSH R2
				PUSH R3
				PUSH R4
				PUSH R5
				MOV  R3, M[ContagemJogos]	;R3 guarda o número de jogos 
				MOV  R2, M[WinNmbr]     	;R2 guarda o número do jogador (para aceder ao vetor)
				MOV  R1, M[Aux6]   			;R1 guarda o valor do tempo (em minutos)
				MOV  R5, SumTempoMin   		;R5 guarda o endereço da primeira posição do vetor das somas de minutos
				ADD  R5, R2                 ;Soma ao número do jogador (para colocar o vetor na posição certa)
				ADD  M[R5], R1              ;Soma o valor obtido para os minutos
				MOV  R4, M[R5]              
				DIV  R4, R3                 ;Calcula o tempo médio (minutos)
				MOV  R5, MediaTempoMin      ;
				ADD  R5, R2
				MOV  M[R5], R4
				MOV  R5, MelhorTempoMin
				ADD  R5, R2
				CMP  M[R5], R1 
				BR.NN  NotBetterMin
				MOV  M[R5], R1
NotBetterMin: 	MOV  R1, M[Aux5]
				MOV  R5, SumTempoDec
				ADD  R5, R2
				ADD  M[R5], R1
				MOV  R4, M[R5]
				DIV  R4, R3 
				MOV  R5, MediaTempoDec
				ADD  R5, R2
				MOV  M[R5], R4
				MOV  R5, MelhorTempoDec
				ADD  R5, R2 
				CMP  M[R5], R1 
				BR.NN  NotBetterDec
				MOV  M[R5], R1
NotBetterDec: 	MOV  R1, M[Aux4]
				MOV  R5, SumTempoSeg
				ADD  R5, R2
				ADD  M[R5], R1
				MOV  R4, M[R5]
				DIV  R4, R3 
				MOV  R5, MediaTempoSeg
				ADD  R5, R2
				MOV  M[R5], R4
				MOV  R5, MelhorTempoSeg
				ADD  R5, R2
				CMP  M[R5], R1 
				BR.NN  NotBetterSeg
				MOV  M[R5], R1
NotBetterSeg: 	MOV  R1, M[ContaJogadas]
				MOV  R5, SumNumJogadas
				ADD  R5, R2
				ADD  M[R5], R1
				MOV  R1, M[R5]
				DIV  R1, R3
				MOV  R5, MediaNumJogadas
				ADD  R5, R2
				MOV  M[R5], R1
				POP  R5
				POP  R4
				POP  R3
				POP	 R2
				POP  R1
				RET

;===============================================================================
; Estatisticas: rotina que estuda as estatisticas do jogo 
;===============================================================================
Estatisticas:	PUSH R1
				PUSH R2
				PUSH R3
				PUSH R4
				PUSH R5
				MOV  R3, M[ContagemJogos]	;R3 guarda o número de jogos 
				MOV  R2, M[WinNmbr]     	;R2 guarda o número do jogador (para aceder ao vetor)
				MOV  R1, M[Aux6]   			;R1 guarda o valor do tempo (em minutos)
				MOV  R5, SumTempoMin   		;R5 guarda o endereço da primeira posição do vetor das somas de minutos
				ADD  R5, R2                 ;Soma ao número do jogador (para colocar o vetor na posição certa)
				ADD  M[R5], R1              ;Soma o valor obtido para os minutos
				MOV  R4, M[R5]              
				DIV  R4, R3                 ;Calcula o tempo médio (minutos)
				MOV  R5, MediaTempoMin      ;
				ADD  R5, R2
				MOV  M[R5], R4
				MOV  R5, MelhorTempoMin
				ADD  R5, R2
				CMP  M[R5], R1 
				BR.NN  NotBetterMin
				MOV  M[R5], R1
NotBetterMin: 	MOV  R1, M[Aux5]
				MOV  R5, SumTempoDec
				ADD  R5, R2
				ADD  M[R5], R1
				MOV  R4, M[R5]
				DIV  R4, R3 
				MOV  R5, MediaTempoDec
				ADD  R5, R2
				MOV  M[R5], R4
				MOV  R5, MelhorTempoDec
				ADD  R5, R2 
				CMP  M[R5], R1 
				BR.NN  NotBetterDec
				MOV  M[R5], R1
NotBetterDec: 	MOV  R1, M[Aux4]
				MOV  R5, SumTempoSeg
				ADD  R5, R2
				ADD  M[R5], R1
				MOV  R4, M[R5]
				DIV  R4, R3 
				MOV  R5, MediaTempoSeg
				ADD  R5, R2
				MOV  M[R5], R4
				MOV  R5, MelhorTempoSeg
				ADD  R5, R2
				CMP  M[R5], R1 
				BR.NN  NotBetterSeg
				MOV  M[R5], R1
NotBetterSeg: 	MOV  R1, M[ContaJogadas]
				MOV  R5, SumNumJogadas
				ADD  R5, R2
				ADD  M[R5], R1
				MOV  R1, M[R5]
				DIV  R1, R3
				MOV  R5, MediaNumJogadas
				ADD  R5, R2
				MOV  M[R5], R1
				POP  R5
				POP  R4
				POP  R3
				POP	 R2
				POP  R1
				RET


;===============================================================================
; Refresh: inicializar as variáveis a cada novo jogo ´´E PRECISO REMOVER?????
;===============================================================================
Refresh:		PUSH 	R1
				PUSH	R2
				MOV  	R1, PecaA
				MOV 	R2, 0000h
ZeroPecas:		MOV 	M[R1], R2
				INC 	R1
				CMP 	R1, AuxPecaF
				BR.NP 	ZeroPecas 
				MOV  	R1, TentA
ZeroTentativas:	MOV  	M[R1], R2
				INC 	R1
				CMP 	R1, TentF 
				BR.NP 	ZeroTentativas
				MOV 	R1, Aux6
				MOV 	R2, 0004h 
				MOV 	M[R1], R2
				MOV 	R1, Aux5
				MOV 	R2, 0000h
Zero1:			MOV 	M[R1], R2 
				INC 	R1 
				CMP   	R1, RealTime4
				BR.NZ 	Zero1
				POP 	R2 
				POP 	R1
				RET 



;===============================================================================
;                                Programa principal
;===============================================================================
inicio:         MOV     R1, SP_INICIAL   	
                MOV     SP, R1				;Coloca o stack pointer logo antes da zona de interrupções
				CALL 	CLRLCD
				MOV 	M[WinNmbr], R0 		
				CALL	MenuEscolhe			;Menu para escolher o modo
				CALL 	ResetTime			;Reset Inicial do tempo
				INC 	M[ContagemJogos]	;Incrementa o número de jogos 
				MOV 	R3, XY_INICIAL      ;Guardar a posicao inicial do cursor de texto
				MOV		M[IO_CURSOR], R3    ;Carregar essa posicao no cursor 
				CALL 	MeteX 			        ;Coloca os X a "tapar" o resultado
ProxJog:		MOV		R1,0001h    			;R1 é utilizado como meio para incremento e decremento de memorias
				MOV		M[WinTent],R0			;RESET	do numero de tentativas
				SUB		M[NumJgds],R1			;Diminui o numero de jogadores restantes
				ADD		M[WinNmbr],R1			;Aumenta o numero do jogador em questão
				CALL 	LimpaJanela         	;Limpa o ecrã
				MOV 	R4, M[NumPecas]			;Consoante o numero de peças escolhido R4 assume esse valor
				CMP 	R4,0004h
				BR.NZ 	Not4              		
				CALL 	Tabuleiro4		;se for 4 imprime o tabuleiro4
				BR  	inigame				;começa o jogo
Not4:			CMP 	R4,0005h
				BR.NZ 	Not5    			          
				CALL 	Tabuleiro5		;não sendo 4, se for 5 imprime o tabuleiro5
				BR 		inigame				;começa o jogo
Not5: 			CALL 	Tabuleiro6 		;não sendo 4 nem 5 imprime o tabuleiro 6
inigame:		CALL 	InitInt			;começa o jogo
				MOV		R1, NUM_JOGADAS     		;Guardar o numero de jogadas 
				MOV		R2, 1608h	   		;Guardar a nova posicao de escrita no ecra
				MOV     R7, M[WinNmbr]
				CMP     R7, 0001h
				BR.NZ   tentar 
				CALL 	GeraTudo		;Gera a sequencia a adivinhar
tentar:			MOV		R4, 0001h			;Coloca o numero de tentativas a 1
				ADD		M[WinTent],R4	
				MOV		M[RIGHT_POS],R0			;RESET do valor das peças pretas
				PUSH	R2				;Passagem de R2 pelo STACK
				MOV 	R3, M[EndofTimeFlag]
				CMP 	R3, 0001h  			;Verificar se a flag esta ativa 
				BR.Z 	FimLose  			;Se estiver, saltar para a etiqueta FimLose (o jogador perdeu)
				CALL 	Jogada			;Senão começa a jogada
				MOV 	R4, M[RIGHT_POS]  		
				CMP 	R4, M[NumPecas] 		;Verificar se o utilizador ja acertou na sequencia (Numero de P's = Numero de Pecas)
				BR.Z 	FimWin  			;Se ja tiver acertado, saltar para a etiqueta FimWin(o jogador ganhou)
				SUB		R2, 0200h           		;Senão passa à linha superior (proxima jogada)
				DEC		R1                  		;Decrementa o numero de jogadas restantes
				BR.NZ	tentar              		;Enquanto nao for zero, continua a jogar
FimLose:       	CALL 	GameOverLose   		;Se o jogador perdeu, escrever essa mensagem
				BR 		Fim       			
FimWin:			CALL 	GameOverWin  		;Se o jogador ganhou, escrever essa mensagem
				CALL	SaveGame		;Guarda os dados do jogo no caso de vitória
Fim:			CALL 	MostraPecas   		;No final, mostrar qual a sequencia
				CMP		M[NumJgds],R0			
				BR.Z	SuperFim			;Se já não restam jogadores o jogo acaba
				CALL 	Delay			;Se restam espera-se que passe a vez ao seguinte
				JMP		ProxJog				;Reinicia o jogo em si
SuperFim:		CMP		M[MultiFlag], R0		
				BR.Z	HiperFim			;Se o jogo não for multi jogador não se imprime qual dos jogadores ganhou/perdeu/empataram
				CMP		M[DrawFlag],R0
				BR.NZ	DrawOn				;Sendo multijogador, se empatou imprime-se o ecrã de empate
				CMP		M[RealNmbr],R0
				BR.Z	LoseOn				;Sendo multijogador, se não empatou,  no caso de todos terem perdido imprime-se a mensagem de derrota
				CALL 	EscEcraFinalW			;Sendo multijogador, não havendo empate, nem perdendo todos, imprime-se o vencedor e os seus dados
				BR		HiperFim			
DrawOn:			CALL 	EscEcraFinalD	
				BR		HiperFim
LoseOn:			CALL	EscEcraFinalL
HiperFim:		MOV 	R2, M[IO_STAT]
				CMP 	R2, R0 
				BR.Z 	HiperFim				;espera-se até que uma tecla seja premida
				MOV 	R1, M[IO_READ]
				CMP 	R1, 'q'
				BR.NZ 	HiperFim
				JMP 	inicio 
;==================================================================================