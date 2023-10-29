; Hiuri Liberato
; Mateus Ticianeli Sartorio
; Sistemas Embarcados I - 2023/2 - Engenharia de Computacao

extern line, cursor, caracter, circle

global cor, preto, azul, verde, cyan, vermelho, magenta, marrom, branco, cinza, azul_claro, verde_claro, cyan_claro, rosa, magenta_claro, amarelo, branco_intenso
global modo_anterior, linha, coluna, deltax, deltay, mens
global mensagem_comando_invalido, mensagem_jogada_invalida, mensgem_partida_acabou,mensagem_circulo_venceu, mensagem_empate, mensagem_x_venceu, string_vazia
global novo_comando, x1, x2,  y1, y2, array_posicoes_jogadas, i, j, p, ultima_jogada, estado_partida

segment code
..start:
	mov 	ax, data
	mov 	ds, ax
	mov 	ax, stack
	mov 	ss, ax
	mov 	sp, stacktop

; salva modo atual de video (vendo como esta o modo de video da maquina)
	mov  	ah, 0Fh
	int  	10h
	mov  	byte [modo_anterior], al   

; altera modo de video para grafico 640x480 16 cores
	mov   al, 12h
	mov   ah, 0
	int   10h

	call	desenha_ui
	jmp		le_novo_comando

; A partir daqui codigo desenvolvido pela gente
desenha_ui:
	push 	ax

	; campo de mensagens
	mov 	byte [cor], branco_intenso
	mov 	ax, 10
	push 	ax
	mov 	ax, 10
	push 	ax
	mov 	ax, 630
	push 	ax
	mov 	ax, 10
	push 	ax
	call 	line

	mov 	ax, 630
	push 	ax
	mov 	ax, 10
	push 	ax
	mov 	ax, 630
	push 	ax
	mov 	ax, 65
	push 	ax
	call 	line

	mov 	ax, 10
	push 	ax
	mov 	ax, 65
	push 	ax
	mov 	ax, 630
	push 	ax
	mov 	ax, 65
	push 	ax
	call 	line

	mov 	ax, 10
	push 	ax
	mov 	ax, 10
	push 	ax
	mov 	ax, 10
	push 	ax
	mov 	ax, 65
	push 	ax
	call 	line

	; campo de comando
	mov 	ax, 10
	push 	ax
	mov 	ax, 75
	push 	ax
	mov 	ax, 630
	push 	ax
	mov 	ax, 75
	push 	ax
	call 	line

	mov 	ax, 630
	push 	ax
	mov 	ax, 75
	push 	ax
	mov 	ax, 630
	push 	ax
	mov 	ax, 130
	push 	ax
	call 	line

	mov 	ax, 630
	push 	ax
	mov 	ax, 130
	push 	ax
	mov 	ax, 10
	push 	ax
	mov 	ax, 130
	push 	ax
	call 	line

	mov 	ax, 10
	push 	ax
	mov 	ax, 130
	push 	ax
	mov 	ax, 10
	push 	ax
	mov 	ax, 75
	push 	ax
	call 	line

	; jogo da velha
	; linhas horizontais
	mov 	ax, 155
	push 	ax
	mov 	ax, 250
	push 	ax
	mov 	ax, 485
	push 	ax
	mov 	ax, 250
	push 	ax
	call 	line

	mov 	ax, 155
	push 	ax
	mov 	ax, 360
	push 	ax
	mov 	ax, 485
	push 	ax
	mov 	ax, 360
	push 	ax
	call 	line

	; linhas verticais
	mov 	ax, 265
	push 	ax
	mov 	ax, 140
	push 	ax
	mov 	ax, 265
	push 	ax
	mov 	ax, 470
	push 	ax
	call 	line

	mov 	ax, 375
	push 	ax
	mov 	ax, 140
	push 	ax
	mov 	ax, 375
	push 	ax
	mov 	ax, 470
	push 	ax
	call 	line

	pop 	ax
	ret

le_novo_comando:

	mov		byte [novo_comando], 0
	mov		byte [novo_comando + 1], 0
	mov		byte [novo_comando + 2], 0
	
	mov		bx, 0
loop_le_novo_comando:
	mov 	ah, 1
	int 	21h

	cmp		al, 0Dh
	je		leu_line_feed
	
	cmp	al, 08h
	je	leu_backspace
	jmp	nao_leu_backspace

leu_backspace:
	cmp	bx, 0
	je	loop_le_novo_comando

	cmp	bx, 3
	jge	buffer_excedido

	mov	byte [novo_comando + bx], 0
	
buffer_excedido:
	dec	bx
	jmp	loop_le_novo_comando

nao_leu_backspace:
	cmp	bx, 3
	jge	excedeu_tamanho_comando
	
	mov	byte [novo_comando + bx], al
	inc	bx
	jmp 	loop_le_novo_comando

leu_line_feed:
	cmp	bx, 0
	je	line_feed_com_novo_comando_vazio
	jmp	line_feed_com_novo_comando_nao_vazio

line_feed_com_novo_comando_vazio:
	call	volta_cursor_para_0x0
	jmp	loop_le_novo_comando

line_feed_com_novo_comando_nao_vazio:
	cmp	bx, 3
	jg	apertou_enter_com_comando_muito_grande

	jmp	processa_novo_comando

apertou_enter_com_comando_muito_grande:
	call 	imprime_comando_invalido
	jmp 	le_novo_comando

excedeu_tamanho_comando:
	inc	bx
	jmp 	loop_le_novo_comando

processa_novo_comando:
	cmp 	byte [novo_comando], 'c'
	je 	novo_jogo
	cmp 	byte [novo_comando], 's'
	je 	sair_intermediario
	cmp 	byte [novo_comando], 'X'
	je 	processa_jogada_x_intermediario
	cmp 	byte [novo_comando], 'C'
	je 	processa_jogada_circulo_intermediario
	call 	imprime_comando_invalido
	jmp 	le_novo_comando

limpa_campo_mensagens:
    	mov     cx, 41			;n�mero de caracteres
    	mov     bx, 0
    	mov     dh, 27			;linha 0-29
    	mov     dl, 19			;coluna 0-79
	    mov	    byte [cor], preto

loop_limpa_campo_mensagens:
	call	cursor
    	mov     al, byte [bx + string_vazia]
	call	caracter
    	inc     bx			;proximo caracter
	inc	dl			;avanca a coluna
    	loop    loop_limpa_campo_mensagens

	ret

imprime_comando_invalido:
	call	limpa_campo_mensagens

    	mov     cx, 16			;n�mero de caracteres
    	mov     bx, 0
    	mov     dh, 27			;linha 0-29
    	mov     dl, 32			;coluna 0-79
	    mov	    byte [cor], vermelho

loop_imprime_comando_invalido:
	call	cursor
    	mov     al, byte [bx + mensagem_comando_invalido]
	call	caracter
    	inc     bx			;proximo caracter
	inc	dl			;avanca a coluna
    	loop    loop_imprime_comando_invalido

	call	volta_cursor_para_0x0
	ret

processa_jogada_x_intermediario:
	jmp	processa_jogada_x

sair_intermediario:
	jmp	sair

le_novo_comando_intermediario:
	jmp 	le_novo_comando

processa_jogada_circulo_intermediario:
	jmp	processa_jogada_circulo

novo_jogo:
	push	cx
	push	si

	; reseta array de posicoes jogadas
	mov	cx, 9
loop_reseta_array_posicoes_jogadas:
	mov	si, cx
	dec	si
	mov	byte [array_posicoes_jogadas + si], 0
	loop	loop_reseta_array_posicoes_jogadas

	; reseta a ultima jogada e o estado da partida
	mov	byte [ultima_jogada], 0
	mov	byte [estado_partida], 0

	call	limpa_tela
	call	desenha_ui

	pop	si
	pop	cx

	jmp	le_novo_comando


limpa_tela:
	push	ax
	push	bx
	push	cx
	push	dx

	mov	byte [cor], preto
	
	mov	cx, 30
loop_exterior:
	mov	ax, cx
	dec	ax
	push 	cx

	mov     cx, 80			;n�mero de caracteres
    	mov     bx, 0
    	mov     dh, al			;linha 0-29
    	mov     dl, 0			;coluna 0-79

loop_interior:
	call	cursor
    	mov     al, byte [bx + string_vazia]
	call	caracter
    	inc     bx			;proximo caracter
	inc	dl			;avanca a coluna
    	loop    loop_interior

	pop	cx
	loop 	loop_exterior

	call	volta_cursor_para_0x0

	pop	dx
	pop	cx
	pop	bx
	pop	ax
	ret

sair:
	mov    	ah, 08h
	int     21h
	mov  	ah, 0   					; set video mode
	mov  	al, [modo_anterior]   				; modo anterior
	int  	10h
	mov     ah, 4ch
	int     21h

processa_jogada_x:
	cmp	byte [estado_partida], 0
	jne	jogada_x_invalida

	call	calcula_posicao_i_j
	call	calcula_indice_array_jogadas
	mov	si, 0
	mov	si, word [p]
	cmp	byte [array_posicoes_jogadas + si], 0
	jne	jogada_x_invalida
	cmp	byte [ultima_jogada], 1
	je	jogada_x_invalida
	jmp	jogada_x_valida

jogada_x_invalida:
	call 	imprime_jogada_invalida
	jmp 	le_novo_comando_intermediario

jogada_x_valida:
	mov	byte [ultima_jogada], 1
	mov	si, 0
	mov	si, word [p]
	mov	byte [array_posicoes_jogadas + si], 1

	call 	desenha_x
	call	imprime_jogada
	call	atualiza_estado_da_partida
	jmp 	le_novo_comando_intermediario

processa_jogada_circulo:
	cmp	byte [estado_partida], 0
	jne	jogada_circulo_invalida

	call	calcula_posicao_i_j
	call	calcula_indice_array_jogadas
	mov	si, 0
	mov	si, word [p]
	cmp	byte [array_posicoes_jogadas + si], 0
	jne	jogada_circulo_invalida
	cmp	byte [ultima_jogada], 2
	je	jogada_circulo_invalida
	jmp	jogada_circulo_valida

jogada_circulo_invalida:
	call 	imprime_jogada_invalida
	jmp 	le_novo_comando_intermediario

jogada_circulo_valida:
	mov	byte [ultima_jogada], 2
	mov	si, 0
	mov	si, word [p]
	mov	byte [array_posicoes_jogadas + si], 2

	call 	desenha_circulo
	call	imprime_jogada
	call	atualiza_estado_da_partida
	jmp 	le_novo_comando_intermediario

imprime_jogada_invalida:
	call	limpa_campo_mensagens
    	
	mov     cx, 16			;n�mero de caracteres
    	mov     bx, 0
    	mov     dh, 27			;linha 0-29
    	mov     dl, 32			;coluna 0-79
	mov	byte [cor], vermelho

loop_imprime_jogada_invalida:
	call	cursor
    	mov     al, byte [bx + mensagem_jogada_invalida]
	call	caracter
    	inc     bx			;proximo caracter
	inc	dl			;avanca a coluna
    	loop    loop_imprime_jogada_invalida

	call	volta_cursor_para_0x0
	ret

imprime_jogada:
    	mov     cx, 3			;n�mero de caracteres
    	mov     bx, 0
    	mov     dh, 23			;linha 0-29
    	mov     dl, 38			;coluna 0-79
	cmp	byte [ultima_jogada], 1
	je	coloca_na_cor_do_x
	cmp	byte [ultima_jogada], 2
	je	coloca_na_cor_do_circulo

coloca_na_cor_do_x:
	mov	byte [cor], verde
	jmp	loop_imprime_jogada

coloca_na_cor_do_circulo:
	mov	byte [cor], magenta
	jmp	loop_imprime_jogada

loop_imprime_jogada:
	call	cursor
    	mov     al, byte [bx + novo_comando]
	call	caracter
    	inc     bx			;proximo caracter
	inc	dl			;avanca a coluna
    	loop    loop_imprime_jogada

	call	volta_cursor_para_0x0
	ret

volta_cursor_para_0x0:
	push	bx
	push	cx
	push	dx

    	mov     cx, 0			;n�mero de caracteres
    	mov     bx, 0
    	mov     dh, 0			;linha 0-29
    	mov     dl, 0			;coluna 0-79
	mov	byte [cor], preto
	call	cursor

	pop	dx
	pop	cx
	pop	bx

	ret

atualiza_estado_da_partida:
	push 	ax
	push	cx

	; verifica horizontalmente
	mov	al, byte [array_posicoes_jogadas + 1]
	cmp	al, 0
	je	partida_nao_acabou_1
	cmp 	al, byte [array_posicoes_jogadas + 0]
	jne	partida_nao_acabou_1
	cmp	al, byte [array_posicoes_jogadas + 2]
	jne	partida_nao_acabou_1
	mov	word [x1], 155
	mov	word [y1], 415
	mov	word [x2], 485
	mov	word [y2], 415
	call	desenha_linha_de_vitoria 
	jmp	partida_acabou_em_vitoria

partida_nao_acabou_1:
	mov	al, byte [array_posicoes_jogadas + 4]
	cmp	al, 0
	je	partida_nao_acabou_2
	cmp 	al, byte [array_posicoes_jogadas + 3]
	jne	partida_nao_acabou_2
	cmp	al, byte [array_posicoes_jogadas + 5]
	jne	partida_nao_acabou_2
	mov	word [x1], 155
	mov	word [y1], 305
	mov	word [x2], 485
	mov	word [y2], 305
	call	desenha_linha_de_vitoria 
	jmp	partida_acabou_em_vitoria

partida_nao_acabou_2:
	mov	al, byte [array_posicoes_jogadas + 7]
	cmp	al, 0
	je	partida_nao_acabou_3
	cmp 	al, byte [array_posicoes_jogadas + 6]
	jne	partida_nao_acabou_3
	cmp	al, byte [array_posicoes_jogadas + 8]
	jne	partida_nao_acabou_3
	mov	word [x1], 155
	mov	word [y1], 195
	mov	word [x2], 485
	mov	word [y2], 195
	call	desenha_linha_de_vitoria 
	jmp	partida_acabou_em_vitoria

; verifica verticalmente
partida_nao_acabou_3:
	mov	al, byte [array_posicoes_jogadas + 3]
	cmp	al, 0
	je	partida_nao_acabou_4
	cmp 	al, byte [array_posicoes_jogadas + 0]
	jne	partida_nao_acabou_4
	cmp	al, byte [array_posicoes_jogadas + 6]
	jne	partida_nao_acabou_4
	mov	word [x1], 210
	mov	word [y1], 140
	mov	word [x2], 210
	mov	word [y2], 470
	call	desenha_linha_de_vitoria
	jmp	partida_acabou_em_vitoria

partida_nao_acabou_4:
	mov	al, byte [array_posicoes_jogadas + 4]
	cmp	al, 0
	je	partida_nao_acabou_5
	cmp 	al, byte [array_posicoes_jogadas + 1]
	jne	partida_nao_acabou_5
	cmp	al, byte [array_posicoes_jogadas + 7]
	jne	partida_nao_acabou_5
	mov	word [x1], 320
	mov	word [y1], 140
	mov	word [x2], 320
	mov	word [y2], 470
	call	desenha_linha_de_vitoria
	jmp	partida_acabou_em_vitoria

partida_nao_acabou_5:
	mov	al, byte [array_posicoes_jogadas + 5]
	cmp	al, 0
	je	partida_nao_acabou_6
	cmp 	al, byte [array_posicoes_jogadas + 2]
	jne	partida_nao_acabou_6
	cmp	al, byte [array_posicoes_jogadas + 8]
	jne	partida_nao_acabou_6
	mov	word [x1], 430
	mov	word [y1], 140
	mov	word [x2], 430
	mov	word [y2], 470
	call	desenha_linha_de_vitoria
	jmp	partida_acabou_em_vitoria

; verifica diagonalmente
partida_nao_acabou_6:
	mov	al, byte [array_posicoes_jogadas + 4]
	cmp	al, 0
	je	partida_nao_acabou_7
	cmp 	al, byte [array_posicoes_jogadas + 0]
	jne	partida_nao_acabou_7
	cmp	al, byte [array_posicoes_jogadas + 8]
	jne	partida_nao_acabou_7
	mov	word [x1], 155
	mov	word [y1], 470
	mov	word [x2], 485
	mov	word [y2], 140
	call	desenha_linha_de_vitoria
	jmp	partida_acabou_em_vitoria

partida_nao_acabou_7:
	mov	al, byte [array_posicoes_jogadas + 4]
	cmp	al, 0
	je	partida_nao_acabou_8
	cmp 	al, byte [array_posicoes_jogadas + 2]
	jne	partida_nao_acabou_8
	cmp	al, byte [array_posicoes_jogadas + 6]
	jne	partida_nao_acabou_8
	mov	word [x1], 155
	mov	word [y1], 140
	mov	word [x2], 485
	mov	word [y2], 470
	call	desenha_linha_de_vitoria
	jmp	partida_acabou_em_vitoria

partida_nao_acabou_8:
	mov	cx, 9

partida_nao_acabou_8_loop:
	mov	si, cx
	cmp	byte [array_posicoes_jogadas + si], 0
	je	ainda_tem_posicoes_nao_jogadas
	loop	partida_nao_acabou_8_loop

	jmp partida_acabou_em_empate

ainda_tem_posicoes_nao_jogadas:
	jmp partida_nao_acabou_9

partida_nao_acabou_9:
	pop	cx
	pop 	ax
	ret

partida_acabou_em_vitoria:
	mov	al, byte [ultima_jogada]
	mov	byte [estado_partida], al
	call	imprime_partida_acabou
	pop	cx
	pop 	ax
	ret

partida_acabou_em_empate:
	mov	byte [estado_partida], 3
	call	imprime_partida_acabou
	pop	cx
	pop 	ax
	ret

imprime_partida_acabou:
	cmp	byte [estado_partida], 1
	je	configura_para_x
	cmp	byte [estado_partida], 2
	je	configura_para_circulo
	jmp	configura_para_empate

configura_para_x:
    	mov     cx, 16			;n�mero de caracteres
    	mov     bx, 0
    	mov     dh, 27			;linha 0-29
    	mov     dl, 26			;coluna 0-79
	mov	byte [cor], verde
	jmp 	loop_imprime_partida_acabou

configura_para_circulo:
    	mov     cx, 16			;n�mero de caracteres
    	mov     bx, 0
    	mov     dh, 27			;linha 0-29
    	mov     dl, 23			;coluna 0-79
	mov	byte [cor], magenta
	jmp 	loop_imprime_partida_acabou

configura_para_empate:
    	mov     cx, 16			;n�mero de caracteres
    	mov     bx, 0
    	mov     dh, 27			;linha 0-29
    	mov     dl, 27			;coluna 0-79
	mov	byte [cor], vermelho
	jmp 	loop_imprime_partida_acabou

loop_imprime_partida_acabou:
	call	cursor
    	mov     al, [bx + mensgem_partida_acabou]
	call	caracter
    	inc     bx			;proximo caracter
	inc	dl			;avanca a coluna
    	loop    loop_imprime_partida_acabou

	cmp	byte [estado_partida], 1
	je	chama_imprime_x_ganhou
	cmp	byte [estado_partida], 2
	je	chama_imprime_circulo_ganhou
	jmp	chama_imprime_empate

chama_imprime_x_ganhou:
	call 	imprime_x_ganhou
	ret

chama_imprime_circulo_ganhou:
	call	imprime_circulo_ganhou
	ret

chama_imprime_empate:
	call	imprime_partida_empatou
	ret

imprime_x_ganhou:
    	mov     cx, 11			;n�mero de caracteres
    	mov     bx, 0
    	mov     dh, 27			;linha 0-29
    	mov     dl, 42			;coluna 0-79

loop_imprime_x_ganhou:
	call	cursor
    	mov     al, [bx + mensagem_x_venceu]
	call	caracter
    	inc     bx			;proximo caracter
	inc	dl			;avanca a coluna
    	loop    loop_imprime_x_ganhou

	call	volta_cursor_para_0x0
	ret

imprime_circulo_ganhou:
    	mov     cx, 17			;n�mero de caracteres
    	mov     bx, 0
    	mov     dh, 27			;linha 0-29
    	mov     dl, 39			;coluna 0-79

loop_imprime_circulo_ganhou:
	call	cursor
    	mov     al, byte [bx + mensagem_circulo_venceu]
	call	caracter
    	inc     bx			;proximo caracter
	inc	dl			;avanca a coluna
    	loop    loop_imprime_circulo_ganhou

	call	volta_cursor_para_0x0
	ret

imprime_partida_empatou:
    	mov     cx, 9			;n�mero de caracteres
    	mov     bx, 0
    	mov     dh, 27			;linha 0-29
    	mov     dl, 43			;coluna 0-79

loop_imprime_empate:
	call	cursor
    	mov     al, byte [bx + mensagem_empate]
	call	caracter
    	inc     bx			;proximo caracter
	inc	dl			;avanca a coluna
    	loop    loop_imprime_empate

	call	volta_cursor_para_0x0
	ret

desenha_linha_de_vitoria:
	push	ax
	mov	byte [cor], vermelho
	mov	ax, word [x1]
	push	ax
	mov	ax, word [y1]
	push	ax
	mov	ax, word [x2]
	push	ax
	mov	ax, word [y2]
	push	ax
	call 	line
	pop	ax
	ret

; p = (i - 1)*3 + j - 1
calcula_indice_array_jogadas:
	push 	ax
	push	bx

	mov	ax, 0
	mov	al, [i]
	dec	al
	mov	bl, 3
	mul	bl
	mov	bl, [j]
	add	al, bl
	dec	al
	mov	word [p], ax
	
	pop 	bx
	pop	ax
	ret

calcula_posicao_i_j:
	cmp	byte [novo_comando + 1], '1'
	jb	jogada_invalida
	cmp	byte [novo_comando + 1], '3'
	jg	jogada_invalida
	cmp	byte [novo_comando + 2], '1'
	jb	jogada_invalida
	cmp	byte [novo_comando + 2], '3'
	jg	jogada_invalida
	mov	ax, 0
	mov	al, [novo_comando + 1]
	sub	al, 30h
	mov	byte [i], al
	mov	ax, 0
	mov	al, [novo_comando + 2]
	sub	al, 30h
	mov	byte [j], al
	ret

jogada_invalida:
	call	imprime_jogada_invalida
	jmp	le_novo_comando

desenha_circulo:
	push	ax
	push 	cx

	mov	cx, 110

	mov	ax, 0
	mov	al, byte [j]
	dec 	ax
	mul 	cx
	add 	ax, 210
	push	ax

	mov	ax, 0
	mov	al, byte [i]
	dec 	ax
	mul 	cx
	mov 	cx, ax
	mov	ax, 415
	sub	ax, cx
	push	ax

	mov	ax, 45
	push	ax
	
	mov	byte [cor], magenta
	call	circle

	pop 	cx
	pop	ax

	ret

desenha_x:
	push	ax
	push 	cx

	mov	cx, 110

	mov	ax, 0
	mov	al, byte [j]
	dec 	ax
	mul 	cx
	add 	ax, 210
	sub	ax, 31
	mov	word [x1], ax
	add	ax, 62
	mov	word [x2], ax

	mov	ax, 0
	mov	al, byte [i]
	dec 	ax
	mul 	cx
	mov 	cx, ax
	mov	ax, 415
	sub	ax, cx
	sub	ax, 31
	mov	word [y1], ax
	add	ax, 62
	mov	word [y2], ax
	
	mov	byte [cor], verde
	mov	ax, [x1]
	push	ax
	mov	ax, [y1]
	push	ax
	mov	ax, [x2]
	push	ax
	mov	ax, [y2]
	push	ax
	call 	line

	mov 	ax, [y1]
	add	ax, 62
	mov	word [y1], ax
	mov	ax, [y2]
	sub	ax, 62
	mov	word [y2], ax

	mov	byte [cor], verde
	mov	ax, [x1]
	push	ax
	mov	ax, [y1]
	push	ax
	mov	ax, [x2]
	push	ax
	mov	ax, [y2]
	push	ax
	call 	line

	pop 	cx
	pop	ax
	ret

;FIM DESENVOLVIMENTO

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

cor					db			branco_intenso
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
magenta_claro		equ			13
amarelo				equ			14
branco_intenso		equ			15

modo_anterior		db			0
linha   			dw  		0
coluna  			dw  		0
deltax				dw			0
deltay				dw			0	
mens    			db  		'Funcao Grafica'

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