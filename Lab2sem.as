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
NUM_COR		EQU	0006h		;numero de cores versao standard
NUM_PECAS	EQU	0004h		;numero de peças versao standard
NUM_JOGADAS	EQU	000Ah		;numero de tentativas versao standard
RIGHT_POS	EQU 	0000h		; numero de cores certas na posicao certa
RIGHT_COL	EQU	0000h		; numero de cores certas na posicao errada
MASCARA		EQU	9C16h		;mascara para geração

; I/O a partir de FF00H
IO_CURSOR       EQU     FFFCh
IO_WRITE        EQU     FFFEh
IO_STAT			EQU		FFFDh
IO_READ			EQU		FFFFh

TAB_INT0		EQU	FE00h

LIMPAR_JANELA   EQU     FFFFh
XY_INICIAL      EQU     0004h
XY_INTROD		EQU		2207h
FIM_TEXTO       EQU     '@'

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
;===============================================================================
; ZONA III: Codigo
;===============================================================================
                ORIG    0000h
                JMP     inicio


;===============================================================================
; RotinaInt0: Rotina de interrupcao 0 (Aparece a sequência gerada)
;===============================================================================
RotinaInt0:     CALL	MostraPecas
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
			MOV     R1, XY_INICIAL	    ; coloca R1 a apontar para a pos inicial
			ADD     R1, 0100h
			PUSH    EcraInicialS1        ; Passagem de parametros pelo STACK
            		PUSH    R1                  ; Passagem de parametros pelo STACK
				CALL	EscString
	       		ADD     R1, 0100h
          		PUSH    EcraInicialS2        ; Passagem de parametros pelo STACK
            		PUSH    R1                  ; Passagem de parametros pelo STACK
            			CALL    EscString
			ADD	R1, 0100h
            		PUSH    EcraInicialS3             ; Passagem de parametros pelo STACK
           		PUSH    R1                  ; Passagem de parametros pelo STACK
            			CALL    EscString
            		ADD	R1, 0400h
            		PUSH    EcraInicialS4             ; Passagem de parametros pelo STACK
           		PUSH    R1                  ; Passagem de parametros pelo STACK
            			CALL    EscString
			ADD	R1, 0100h
            		PUSH    EcraInicialS5             ; Passagem de parametros pelo STACK
           		PUSH    R1                  ; Passagem de parametros pelo STACK
            			CALL    EscString
			ADD	R1, 0100h
            		PUSH    EcraInicialS6             ; Passagem de parametros pelo STACK
           		PUSH    R1                  ; Passagem de parametros pelo STACK
            			CALL    EscString
			POP 	R1
			RET

;===============================================================================
; EscEcraRegras: Rotina que escreve o ecrã inicial
;===============================================================================
EscEcraRegras: 	PUSH	R1
				CALL    LimpaJanela
			MOV     R1, XY_INICIAL	    ; coloca R1 a apontar para a pos inicial
			ADD     R1, 0100h
			PUSH    EcraInicialR1        ; Passagem de parametros pelo STACK
            		PUSH    R1                  ; Passagem de parametros pelo STACK
				CALL	EscString
	       		ADD     R1, 0100h
          		PUSH    EcraInicialR2        ; Passagem de parametros pelo STACK
            		PUSH    R1                  ; Passagem de parametros pelo STACK
            			CALL    EscString
			ADD	R1, 0100h
            		PUSH    EcraInicialR3             ; Passagem de parametros pelo STACK
           		PUSH    R1                  ; Passagem de parametros pelo STACK
            			CALL    EscString
            		ADD	R1, 0100h
            		PUSH    EcraInicialR4             ; Passagem de parametros pelo STACK
           		PUSH    R1                  ; Passagem de parametros pelo STACK
            			CALL    EscString
			ADD	R1, 0100h
            		PUSH    EcraInicialR5             ; Passagem de parametros pelo STACK
           		PUSH    R1                  ; Passagem de parametros pelo STACK
            			CALL    EscString
			ADD	R1, 0100h
            		PUSH    EcraInicialR6             ; Passagem de parametros pelo STACK
           		PUSH    R1                  ; Passagem de parametros pelo STACK
            			CALL    EscString
			PUSH    EcraInicialR7        ; Passagem de parametros pelo STACK
            		PUSH    R1                  ; Passagem de parametros pelo STACK
				CALL	EscString
	       		ADD     R1, 0100h
          		PUSH    EcraInicialR8        ; Passagem de parametros pelo STACK
            		PUSH    R1                  ; Passagem de parametros pelo STACK
            			CALL    EscString
			ADD	R1, 0100h
            		PUSH    EcraInicialR9             ; Passagem de parametros pelo STACK
           		PUSH    R1                  ; Passagem de parametros pelo STACK
            			CALL    EscString
            		ADD	R1, 0100h
            		PUSH    EcraInicialR10             ; Passagem de parametros pelo STACK
           		PUSH    R1                  ; Passagem de parametros pelo STACK
            			CALL    EscString
			ADD	R1, 0100h
            		PUSH    EcraInicialR11             ; Passagem de parametros pelo STACK
           		PUSH    R1                  ; Passagem de parametros pelo STACK
            			CALL    EscString
			ADD	R1, 0100h
            		PUSH    EcraInicialR12             ; Passagem de parametros pelo STACK
           		PUSH    R1                  ; Passagem de parametros pelo STACK
            			CALL    EscString
			POP 	R1
			RET

;===============================================================================
;  Tabuleiro: gera o tabuleiro onde o jogo será jogado
;===============================================================================
Tabuleiro:	PUSH	R3
			PUSH	R1
			MOV		R3, 000bh
			CALL    LimpaJanela
			MOV     R1, XY_INICIAL	    ; coloca R1 a apontar para a pos inicial
            BR  	cimabaixo 
meio:		ADD     R1, 0100h
			PUSH    PlanoJogo           ; Passagem de parametros pelo STACK
            PUSH    R1                  ; Passagem de parametros pelo STACK
			CALL	EscString
			CALL	MostraPecas
	        ADD     R1, 0100h
          	PUSH    Separador           ; Passagem de parametros pelo STACK
            PUSH    R1                  ; Passagem de parametros pelo STACK
            CALL    EscString
			DEC		R3
			CMP		R3, R0		    ;todos os espaços de jogo estão criados quando R3=0
			BR.NZ	meio
cimabaixo:	ADD		R1, 0100h
            PUSH    Limites             ; Passagem de parametros pelo STACK
            PUSH    R1                  ; Passagem de parametros pelo STACK
            CALL    EscString
			CMP		R3, 000bh
			BR.Z	meio
			POP 	R1
			POP		R3
			RET

;===============================================================================
;  GeraRand: Gera número da Cor aleatória
;===============================================================================
GeraRand:	PUSH 	R1
			PUSH 	R2
			MOV	R2, NUM_COR
			MOV	R1, M[SeedIni]
			DIV	R1, R2			;o resto da divisão é armazenado em R2 (0->5)
			MOV 	M[R3], R2		;a cada numero corresponde uma cor 
			POP 	R2
			POP 	R1
			RET	

;===============================================================================
;  CriaSemente:	Cria a semente utilizada para obter a cor
;===============================================================================
CriaSemente:	PUSH 	R1
				PUSH	R2
				PUSH	R3
				MOV	R1, M[SeedIni]
				MOV	R2, R1
				MOV	R3, MASCARA
				RORC	R1, 1
				BR.NC	bit0		;se o carry (bit de menor peso) nao ocorre Ni<-Ni xor MASCARA
				XOR	R2, R3
bit0:			ROR	R2, 1
				MOV	M[SeedIni], R2
				POP	R3
				POP	R2
				POP	R1
				RET
;===============================================================================
;  GeraTudo: Gera todos os números e converte-os para cor
;===============================================================================
GeraTudo:		PUSH	R1
				PUSH	R3
				MOV	R1, NUM_PECAS		;são geradas NUM_PECAS peças
				MOV	R3, PecaA		;o valor da cor irá ser armazenado na memoria apontada por R3
gerador:		CALL CriaSemente
				CALL GeraRand
				CALL ConverteCor
				INC	R3			;R3 é incrementado para passar ao endereço da peça seguinte
				DEC	R1
				BR.NZ	gerador
				POP	R3
				POP	R1
				RET
;===============================================================================
;  ConverteCor: converte do numero para a respetica cor
;===============================================================================
ConverteCor:	PUSH	R1
				MOV	R1, M[R3]
				ADD	R1, 0041h
				CMP	R1, 0041h
				BR.Z	end
				CMP	R1, 0042h
				BR.Z	end
				CMP	R1, 0045h
				BR.Z	end
				CMP	R1, 0043h
				BR.NZ	npreto
				ADD	R1, 000dh
				BR	end
npreto:			CMP	R1, 0044h
				BR.NZ	nverde
				ADD	R1, 0012h
				BR	end
nverde:			ADD	R1, 0014h
end:			MOV	M[R3], R1
				POP R1
				RET
		
;===============================================================================
;  MeteX: mete as peças aleatorias com o valor X para se iniciarem assim no ecra
;===============================================================================
MeteX:		PUSH	R2
			PUSH	R1
			PUSH	R3
			MOV	R3, NUM_PECAS
			MOV	R1, PecaA
			MOV	R2, 0058h
nextmete:	MOV	M[R1], R2
			INC	R1
			DEC	R3
			BR.NZ	nextmete
			POP	R3
			POP R1
			POP	R2
			RET
;===============================================================================
; MostraPecas: mostra as pecas geradas
;===============================================================================
MostraPecas: 	PUSH 	R1
				PUSH 	R2
				PUSH 	R3
				PUSH 	R4
				MOV	R3, 0208h
				MOV	R2, NUM_PECAS
				MOV	R4, PecaA
aparece:        MOV	M[IO_CURSOR], R3
				MOV	R1, M[R4]
				CALL	EscCar
				ADD	R3, 0004h
				INC	R4
				DEC	R2
				BR.NZ	aparece
				POP	R4
				POP	R3
				POP	R2
				POP	R1
				RET

;===============================================================================
;  Jogada: leitura e escrita no ecra das peças em cada jogada
;===============================================================================
Jogada:		PUSH	R1
		PUSH	R2
		PUSH	R3
		PUSH	R4
		PUSH	R5
		PUSH	R6
		PUSH	R7
		MOV	R3, PecaA
		MOV	R4, M[R3]
		INC	R3
		MOV	R5, M[R3]
		INC	R3
		MOV	R6, M[R3]
		INC	R3
		MOV	R7, M[R3]
		;Guardar valores das pecas
		MOV	R3, TentA
		MOV	R2, M[SP+6]
waitforit:	MOV	R1, M[IO_STAT]
		CMP	R1, R0
		BR.Z	waitforit
		MOV	M[IO_CURSOR], R2
		MOV	R1, M[IO_READ]
		CMP	R1, 0061h
		BR.Z	valida
		CMP	R1, 0062h
		BR.Z	valida
		CMP	R1, 0065h
		BR.Z	valida
		CMP	R1, 0070h
		BR.Z	valida
		CMP	R1, 0076h
		BR.Z	valida
		CMP	R1, 007Ah
		BR.Z	valida
backup:		BR	waitforit
valida:		SUB	R1, 0020h
			CALL	EscCar
		MOV	M[R3], R1
		ADD	R2, 0004h
		INC	R3
		MOV	R1, TentD
		INC	R1
		CMP	R3, R1
		BR.NZ	backup
		MOV	R1, RIGHT_POS
		PUSH	R2
		PUSH	R1
			CALL	ValidaJogadaP
		CMP	R1, 0004h 
		BR.Z 	fimjogada
		ADD	R2, 0004h
		PUSH	R2
		PUSH	R1
			CALL	ValidaJogadaB
		MOV	R3, PecaA
		MOV	M[R3], R4
		INC	R3
		MOV	M[R3], R5
		INC	R3
		MOV	M[R3], R6
		INC	R3
		MOV	M[R3], R7
fimjogada:	POP	R7
		POP	R6
		POP	R5
		POP	R4
		POP	R3
		POP	R2
		POP	R1
		RETN	1

;===============================================================================
;  ValidaJogadaP: Validacao da sequencia inserida
;===============================================================================
ValidaJogadaP:	PUSH	R1
		PUSH	R2
		PUSH	R3
		PUSH	R4
		PUSH	R5
		PUSH	R6
		PUSH	R7
		MOV	R4, TentA	
		MOV	R3, PecaA
		MOV	R2, NUM_PECAS
		MOV	R1, M[SP+9]
Teste:		MOV	R5, M[R3]
		MOV	R6, M[R4]
		CMP	R6, R5
		BR.NZ 	FailedPosition
		INC 	R1
		MOV	M[R3], R0
		MOV	M[R4], R0
FailedPosition:	INC 	R3
		INC 	R4
		DEC 	R2
		BR.NZ	Teste
		MOV 	R7, M[SP+10]
		MOV	M[IO_CURSOR], R7
		ADD	R1, 0030h
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
		MOV 	R1, 0000h
		MOV 	R3, NUM_PECAS
		MOV 	R5, TentA
AvancaTent:	MOV	R7, M[R5]
		CMP	R7, R0
		BR.Z	NextTent
		MOV     R2, NUM_PECAS
		MOV	R4, PecaA
AvancaPeca:	MOV 	R6, M[R4]
		CMP	R6, R0
		BR.Z	NextPeca
		CMP 	R7, R6 
		BR.NZ 	NextPeca
		MOV	M[R5], R0
		MOV	M[R4], R0
		INC 	R1
		BR 	NextTent
NextPeca: 	INC 	R4
		DEC	R2 
		BR.NZ 	AvancaPeca
NextTent: 	INC 	R5
		DEC 	R3
		BR.NZ 	AvancaTent
		MOV 	R7, M[SP+10]
		MOV	M[IO_CURSOR], R7
		ADD	R1, 0030h
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
;                                Programa principal
;===============================================================================
inicio:         MOV     R1, SP_INICIAL
                MOV     SP, R1
                CALL 	EscEcraInicial
notstart:       MOV	R2, M[IO_STAT]
		CMP	R2, R0
		BR.Z	notstart
		MOV	R1, M[IO_READ]
		CMP	R1, '2'
		BR.NZ	skipregras
		CALL	EscEcraRegras
		BR	notstart
skipregras:	CMP	R1, '1'
		BR.NZ	notstart
		MOV 	R3, XY_INICIAL
		MOV	M[IO_CURSOR], R3
		MOV	R2, M[IO_READ]
			CALL 	LimpaJanela
			CALL 	MeteX
			CALL 	Tabuleiro
			CALL 	GeraTudo
		ENI
		MOV     R1, RotinaInt0
                MOV     M[TAB_INT0], R1
		MOV	R1, NUM_JOGADAS
		MOV	R2, 1608h	
tentar:		PUSH	R2
			CALL Jogada
		SUB	R2, 0200h
		DEC	R1
		BR.NZ	tentar
Fim:            BR      Fim
;==================================================================================