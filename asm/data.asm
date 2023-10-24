global cor, preto, azul, verde, cyan, vermelho, magenta, marrom, branco, cinza, azul_claro, verde_claro, cyan_claro, rosa, magenta_claro, amarelo, branco_intenso

global modo_anterior, linha, coluna, deltax, deltay, mens

global mensagem_comando_invalido, mensagem_jogada_invalida, mensgem_partida_acabou,mensagem_circulo_venceu, mensagem_empate, mensagem_x_venceu, string_vazia

global novo_comando, x1, x2, y2, array_posicoes_jogadas, i, j, p, ultima_jogada, estado_partida

segment data

;	I R G B COR
;	0 0 0 0 preto
;	0 0 0 1 azul
;	0 0 1 0 verde
;	0 0 1 1 cyan
;	0 1 0 0 vermelho
;	0 1 0 1 magenta
;	0 1 1 0 marrom
;	0 1 1 1 branco
;	1 0 0 0 cinza
;	1 0 0 1 azul claro
;	1 0 1 0 verde claro
;	1 0 1 1 cyan claro
;	1 1 0 0 rosa
;	1 1 0 1 magenta claro
;	1 1 1 0 amarelo
;	1 1 1 1 branco intenso

cor				db			branco_intenso
preto				equ			0
azul				equ			1
verde				equ			2
cyan				equ			3
vermelho			equ			4
magenta				equ			5
marrom				equ			6
branco				equ			7
cinza				equ			8
azul_claro			equ			9
verde_claro			equ			10
cyan_claro			equ			11
rosa				equ			12
magenta_claro			equ			13
amarelo				equ			14
branco_intenso			equ			15

modo_anterior			db			0
linha   			dw  			0
coluna  			dw  			0
deltax				dw			0
deltay				dw			0	
mens    			db  			'Funcao Grafica'

; mensagens de erro impressas na tela ao longo do jogo
mensagem_comando_invalido	db			'Comando Invalido'
; o espaço a mais em jogada invalida eh para que a mensagem tenha 16 caracteres igual comando invalido
mensagem_jogada_invalida	db			'Jogada Invalida '
mensgem_partida_acabou		db			'Partida Acabou: '
mensagem_circulo_venceu		db			'Circulo Venceu!!!'
mensagem_empate			db			'Empate :('
mensagem_x_venceu		db			'X Venceu!!!'

; string usada para limpar a tela na funcao de novo jogo e para limpar o campo de mensagens
string_vazia			db			'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'

; armazena o novo comando que esta sendo digitado
novo_comando			db			0, 0, 0

; variaveis auxiliares usadas na impressao dos X's
x1				dw			0
y1				dw			0
x2				dw			0
y2				dw			0

; array que armazena a situacao atual de cada celula do jogo da velha
; 0 indica que nada foi jogado na posicao
; 1 indica que X foi jogado na posicao
; 2 indica que circulo foi jogado na posicao
array_posicoes_jogadas		db			0, 0, 0, 0, 0, 0, 0, 0, 0
i				db			0
j				db			0
p				dw			0

; ultima jogada
; 0 se ninguem jogou ainda
; 1 se X foi jogado por ultimo
; 2 se Circulo foi jogado por ultimo
ultima_jogada			db			0

; estado da partida
; 0 se o jogo nao terminou
; 1 se X ganhou o jogo
; 2 se Circulo ganhou jogo
; 3 se o jogo empatou
estado_partida			db			0

;*************************************************************************
segment stack stack
	resb 	512
stacktop: