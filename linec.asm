; Hiuri Liberato
; Mateus Ticianeli Sartorio
; Sistemas Embarcados I - 2023/2 - Engenharia de Computacao

; versao de 10/05/2007
; corrigido erro de arredondamento na rotina line.
; circle e full_circle disponibilizados por Jefferson Moro em 10/2009

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
	mov  	[modo_anterior], al   

; altera modo de video para grafico 640x480 16 cores
	mov     al, 12h
	mov     ah, 0
	int     10h

; A partir daqui codigo desenvolvido pela gente
desenha_ui:
	; primeiro retangulo
	mov 	byte[cor], branco_intenso
	mov 	ax, 10
	push 	ax
	mov 	ax, 10
	push 	ax
	mov 	ax, 630
	push 	ax
	mov 	ax, 10
	push 	ax
	call 	line

	mov 	byte[cor], branco_intenso
	mov 	ax, 630
	push 	ax
	mov 	ax, 10
	push 	ax
	mov 	ax, 630
	push 	ax
	mov 	ax, 65
	push 	ax
	call 	line

	mov byte[cor], branco_intenso
	mov 	ax, 10
	push 	ax
	mov 	ax, 65
	push 	ax
	mov 	ax, 630
	push 	ax
	mov 	ax, 65
	push 	ax
	call 	line

	mov 	byte[cor], branco_intenso
	mov 	ax, 10
	push 	ax
	mov 	ax, 10
	push 	ax
	mov 	ax, 10
	push 	ax
	mov 	ax, 65
	push 	ax
	call 	line


	; segundo retangulo
	mov 	byte[cor], branco_intenso
	mov 	ax, 10
	push 	ax
	mov 	ax, 75
	push 	ax
	mov 	ax, 630
	push 	ax
	mov 	ax, 75
	push 	ax
	call 	line

	mov 	byte[cor], branco_intenso
	mov 	ax, 630
	push 	ax
	mov 	ax, 75
	push 	ax
	mov 	ax, 630
	push 	ax
	mov 	ax, 130
	push 	ax
	call 	line

	mov 	byte[cor], branco_intenso
	mov 	ax, 630
	push 	ax
	mov 	ax, 130
	push 	ax
	mov 	ax, 10
	push 	ax
	mov 	ax, 130
	push 	ax
	call 	line

	mov 	byte[cor], branco_intenso
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
	; horizontal
	mov 	byte[cor], branco_intenso
	mov 	ax, 155
	push 	ax
	mov 	ax, 250
	push 	ax
	mov 	ax, 485
	push 	ax
	mov 	ax, 250
	push 	ax
	call 	line

	mov 	byte[cor], branco_intenso
	mov 	ax, 155
	push 	ax
	mov 	ax, 360
	push 	ax
	mov 	ax, 485
	push 	ax
	mov 	ax, 360
	push 	ax
	call 	line

	; vertical
	mov 	byte[cor], branco_intenso
	mov 	ax, 265
	push 	ax
	mov 	ax, 140
	push 	ax
	mov 	ax, 265
	push 	ax
	mov 	ax, 470
	push 	ax
	call 	line

	mov 	byte[cor], branco_intenso
	mov 	ax, 375
	push 	ax
	mov 	ax, 140
	push 	ax
	mov 	ax, 375
	push 	ax
	mov 	ax, 470
	push 	ax
	call 	line

le_novo_comando:
	mov	byte [novo_comando], 0
	mov	byte [novo_comando + 1], 0
	mov	byte [novo_comando + 2], 0
	
	mov	bx, 0
loop_le_novo_comando:
	mov 	ah, 1
	int 	21h

	cmp	al, 0Dh
	je	leu_line_feed
	
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
	je	loop_le_novo_comando

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
	; cmp 	al, 'c'
	; je 	novo_jogo
	cmp 	byte [novo_comando], 's'
	je 	sair
	cmp 	byte [novo_comando], 'X'
	je 	le_X
	cmp 	byte [novo_comando], 'C'
	je 	le_C_intermediario
	call 	imprime_comando_invalido
	jmp 	le_novo_comando

imprime_comando_invalido:
    	mov     cx, 16			;n�mero de caracteres
    	mov     bx, 0
    	mov     dh, 27			;linha 0-29
    	mov     dl, 30			;coluna 0-79
	mov	byte[cor], vermelho

loop_imprime_comando_invalido:
	call	cursor
    	mov     al,[bx + mensagem_comando_invalido]
	call	caracter
    	inc     bx			;proximo caracter
	inc	dl			;avanca a coluna
    	loop    loop_imprime_comando_invalido

	ret

; novo_jogo:

sair:
	mov    	ah, 08h
	int     21h
	mov  	ah, 0   					; set video mode
	mov  	al, [modo_anterior]   				; modo anterior
	int  	10h

	mov 	ah, 4ch
	int 	21h

le_C_intermediario:
	jmp	le_C

le_X:
	call	calcula_posicao_i_j
	call	calcula_indice_array_jogadas
	cmp	byte [array_posicoes_jogadas + si], 0
	jne	jogada_x_invalida
	cmp	byte [ultima_jogada], 1
	je	jogada_x_invalida
	jmp	jogada_x_valida

jogada_x_invalida:
	call 	imprime_jogada_invalida
	jmp 	le_novo_comando

jogada_x_valida:
	mov	byte [ultima_jogada], 1
	mov	byte [array_posicoes_jogadas + si], 1

	mov	ax, 0
	mov	al, [i]
	mov	bx, 0
	mov	bl, [j]
	call 	desenha_x
	call	imprime_jogada
	jmp 	le_novo_comando

le_C:
	call	calcula_posicao_i_j
	call	calcula_indice_array_jogadas
	cmp	byte [array_posicoes_jogadas + si], 0
	jne	jogada_x_invalida
	cmp	byte [ultima_jogada], 2
	je	jogada_circulo_invalida
	jmp	jogada_circulo_valida

jogada_circulo_invalida:
	call 	imprime_jogada_invalida
	jmp 	le_novo_comando

jogada_circulo_valida:
	mov	byte [ultima_jogada], 2
	mov	byte [array_posicoes_jogadas + si], 1

	mov	ax, 0
	mov	al, [i]
	mov	bx, 0
	mov	bl, [j]
	call 	desenha_circulo
	call	imprime_jogada
	jmp 	le_novo_comando

imprime_jogada_invalida:
    	mov     cx, 16			;n�mero de caracteres
    	mov     bx, 0
    	mov     dh, 27			;linha 0-29
    	mov     dl, 30			;coluna 0-79
	mov	byte[cor], vermelho

loop_imprime_jogada_invalida:
	call	cursor
    	mov     al,[bx + mensagem_jogada_invalida]
	call	caracter
    	inc     bx			;proximo caracter
	inc	dl			;avanca a coluna
    	loop    loop_imprime_jogada_invalida
	ret

imprime_jogada:
    	mov     cx, 3			;n�mero de caracteres
    	mov     bx, 0
    	mov     dh, 23			;linha 0-29
    	mov     dl, 39			;coluna 0-79
	mov	byte[cor], verde

loop_imprime_jogada:
	call	cursor
    	mov     al,[bx + novo_comando]
	call	caracter
    	inc     bx			;proximo caracter
	inc	dl			;avanca a coluna
    	loop    loop_imprime_jogada
	ret

; p = (i - 1)*3 + j - 1
calcula_indice_array_jogadas:
	mov	ax, 0
	mov	al, [i]
	dec	al
	mov	bl, 3
	mul	bl
	mov	bl, [j]
	add	al, bl
	dec	al
	mov	si, ax
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
	push 	cx

	mov	cx, 110

	dec 	ax
	mul 	cx
	add 	ax, 210
	push	ax

	mov 	ax, bx
	dec 	ax
	mul 	cx
	mov 	cx, ax
	mov	ax, 415
	sub	ax, cx
	push	ax

	mov	ax, 45
	push	ax
	
	mov	byte[cor], azul
	call	circle

	pop 	cx

	ret

desenha_x:
	push 	cx
	push 	dx

	mov	cx, 110

	dec 	ax
	mul 	cx
	add 	ax, 210
	sub	ax, 31
	mov	word [x1], ax
	add	ax, 62
	mov	word [x2], ax

	mov 	ax, bx
	dec 	ax
	mul 	cx
	mov 	cx, ax
	mov	ax, 415
	sub	ax, cx
	sub	ax, 31
	mov	word [y1], ax
	add	ax, 62
	mov	word [y2], ax
	
	mov	byte[cor], verde
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

	mov	byte[cor], verde
	mov	ax, [x1]
	push	ax
	mov	ax, [y1]
	push	ax
	mov	ax, [x2]
	push	ax
	mov	ax, [y2]
	push	ax
	call 	line

	pop	dx
	pop 	cx
	ret

;***************************************************************************
;
;   funcao cursor
;
; dh = linha (0-29) e  dl=coluna  (0-79)
cursor:
	pushf
	push 	ax
	push 	bx
	push	cx
	push	dx
	push	si
	push	di
	push	bp
	mov     ah, 2
	mov     bh, 0
	int     10h
	pop	bp
	pop	di
	pop	si
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	popf
	ret
;_____________________________________________________________________________
;
;   funcao caracter escrito na posicao do cursor
;
; al= caracter a ser escrito
; cor definida na variavel cor
caracter:
	pushf
	push 	ax
	push 	bx
	push	cx
	push	dx
	push	si
	push	di
	push	bp
	mov     ah, 9
	mov     bh, 0
	mov     cx, 1
	mov     bl, [cor]
	int     10h
	pop	bp
	pop	di
	pop	si
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	popf
	ret
;_____________________________________________________________________________
;
;   funcao plot_xy
;
; push x; push y; call plot_xy;  (x<639, y<479)
; cor definida na variavel cor
plot_xy:
	push	bp
	mov	bp, sp
	pushf
	push 	ax
	push 	bx
	push	cx
	push	dx
	push	si
	push	di
	mov     ah, 0ch
	mov     al, [cor]
	mov     bh, 0
	mov     dx, 479
	sub	dx, [bp+4]
	mov     cx, [bp+6]
	int     10h
	pop	di
	pop	si
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	popf
	pop	bp
	ret	4

;_____________________________________________________________________________
;    funcao circle
;	 push xc; push yc; push r; call circle;  (xc+r<639,yc+r<479)e(xc-r>0,yc-r>0)
; cor definida na variavel cor
circle:
	push 	bp
	mov	bp, sp
	pushf                        ;coloca os flags na pilha
	push 	ax
	push 	bx
	push	cx
	push	dx
	push	si
	push	di
	
	mov	ax, [bp+8]    ; resgata xc
	mov	bx, [bp+6]    ; resgata yc
	mov	cx, [bp+4]    ; resgata r
	
	mov 	dx, bx	
	add	dx, cx       ;ponto extremo superior
	push    ax			
	push	dx
	call 	plot_xy
	
	mov	dx, bx
	sub	dx, cx       ;ponto extremo inferior
	push    ax			
	push	dx
	call 	plot_xy
	
	mov 	dx, ax	
	add	dx, cx       ;ponto extremo direita
	push    dx			
	push	bx
	call 	plot_xy
	
	mov	dx, ax
	sub	dx, cx       ;ponto extremo esquerda
	push    dx			
	push	bx
	call 	plot_xy
		
	mov	di, cx
	sub	di, 1	 ;di=r-1
	mov	dx, 0  	;dx ser� a vari�vel x. cx � a variavel y
	
;aqui em cima a l�gica foi invertida, 1-r => r-1
;e as compara��es passaram a ser jl => jg, assim garante 
;valores positivos para d

stay:				;loop
	mov	si, di
	cmp	si, 0
	jg	inf       ;caso d for menor que 0, seleciona pixel superior (n�o  salta)
	mov	si, dx		;o jl � importante porque trata-se de conta com sinal
	sal	si, 1		;multiplica por doi (shift arithmetic left)
	add	si, 3
	add	di, si     ;nesse ponto d=d+2*dx+3
	inc	dx		;incrementa dx
	jmp	plotar
inf:	
	mov	si, dx
	sub	si, cx  		;faz x - y (dx-cx), e salva em di 
	sal	si, 1
	add	si, 5
	add	di, si		;nesse ponto d=d+2*(dx-cx)+5
	inc	dx		;incrementa x (dx)
	dec	cx		;decrementa y (cx)
	
plotar:	
	mov	si, dx
	add	si, ax
	push    si			;coloca a abcisa x+xc na pilha
	mov	si, cx
	add	si, bx
	push    si			;coloca a ordenada y+yc na pilha
	call 	plot_xy		;toma conta do segundo octante
	mov	si, ax
	add	si, dx
	push    si			;coloca a abcisa xc+x na pilha
	mov	si, bx
	sub	si, cx
	push    si			;coloca a ordenada yc-y na pilha
	call 	plot_xy		;toma conta do s�timo octante
	mov	si, ax
	add	si, cx
	push    si			;coloca a abcisa xc+y na pilha
	mov	si, bx
	add	si, dx
	push    si			;coloca a ordenada yc+x na pilha
	call 	plot_xy		;toma conta do segundo octante
	mov	si, ax
	add	si, cx
	push    si			;coloca a abcisa xc+y na pilha
	mov	si, bx
	sub	si, dx
	push    si			;coloca a ordenada yc-x na pilha
	call 	plot_xy		;toma conta do oitavo octante
	mov	si, ax
	sub	si, dx
	push    si			;coloca a abcisa xc-x na pilha
	mov	si, bx
	add	si, cx
	push    si			;coloca a ordenada yc+y na pilha
	call 	plot_xy		;toma conta do terceiro octante
	mov	si, ax
	sub	si, dx
	push    si			;coloca a abcisa xc-x na pilha
	mov	si, bx
	sub	si, cx
	push    si			;coloca a ordenada yc-y na pilha
	call 	plot_xy		;toma conta do sexto octante
	mov	si, ax
	sub	si, cx
	push    si			;coloca a abcisa xc-y na pilha
	mov	si, bx
	sub	si, dx
	push    si			;coloca a ordenada yc-x na pilha
	call 	plot_xy		;toma conta do quinto octante
	mov	si, ax
	sub	si, cx
	push    si			;coloca a abcisa xc-y na pilha
	mov	si, bx
	add	si, dx
	push    si			;coloca a ordenada yc-x na pilha
	call 	plot_xy		;toma conta do quarto octante
	
	cmp	cx, dx
	jb	fim_circle  ;se cx (y) est� abaixo de dx (x), termina     
	jmp	stay		;se cx (y) est� acima de dx (x), continua no loop
	
fim_circle:
	pop	di
	pop	si
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	popf
	pop	bp
	ret	6
;-----------------------------------------------------------------------------
;    fun��o full_circle
;	 push xc; push yc; push r; call full_circle;  (xc+r<639,yc+r<479)e(xc-r>0,yc-r>0)
; cor definida na variavel cor					  
full_circle:
	push 	bp
	mov	bp, sp
	pushf                        ;coloca os flags na pilha
	push 	ax
	push 	bx
	push	cx
	push	dx
	push	si
	push	di

	mov		ax,[bp+8]    ; resgata xc
	mov		bx,[bp+6]    ; resgata yc
	mov		cx,[bp+4]    ; resgata r
	
	mov		si,bx
	sub		si,cx
	push    ax			;coloca xc na pilha			
	push	si			;coloca yc-r na pilha
	mov		si,bx
	add		si,cx
	push	ax		;coloca xc na pilha
	push	si		;coloca yc+r na pilha
	call line
	
		
	mov		di,cx
	sub		di,1	 ;di=r-1
	mov		dx,0  	;dx ser� a vari�vel x. cx � a variavel y
	
;aqui em cima a l�gica foi invertida, 1-r => r-1
;e as compara��es passaram a ser jl => jg, assim garante 
;valores positivos para d

stay_full:				;loop
	mov		si,di
	cmp		si,0
	jg		inf_full       ;caso d for menor que 0, seleciona pixel superior (n�o  salta)
	mov		si,dx		;o jl � importante porque trata-se de conta com sinal
	sal		si,1		;multiplica por doi (shift arithmetic left)
	add		si,3
	add		di,si     ;nesse ponto d=d+2*dx+3
	inc		dx		;incrementa dx
	jmp		plotar_full
inf_full:	
	mov		si,dx
	sub		si,cx  		;faz x - y (dx-cx), e salva em di 
	sal		si,1
	add		si,5
	add		di,si		;nesse ponto d=d+2*(dx-cx)+5
	inc		dx		;incrementa x (dx)
	dec		cx		;decrementa y (cx)
	
plotar_full:	
	mov		si,ax
	add		si,cx
	push	si		;coloca a abcisa y+xc na pilha			
	mov		si,bx
	sub		si,dx
	push    si		;coloca a ordenada yc-x na pilha
	mov		si,ax
	add		si,cx
	push	si		;coloca a abcisa y+xc na pilha	
	mov		si,bx
	add		si,dx
	push    si		;coloca a ordenada yc+x na pilha	
	call 	line
	
	mov		si,ax
	add		si,dx
	push	si		;coloca a abcisa xc+x na pilha			
	mov		si,bx
	sub		si,cx
	push    si		;coloca a ordenada yc-y na pilha
	mov		si,ax
	add		si,dx
	push	si		;coloca a abcisa xc+x na pilha	
	mov		si,bx
	add		si,cx
	push    si		;coloca a ordenada yc+y na pilha	
	call	line
	
	mov		si,ax
	sub		si,dx
	push	si		;coloca a abcisa xc-x na pilha			
	mov		si,bx
	sub		si,cx
	push    si		;coloca a ordenada yc-y na pilha
	mov		si,ax
	sub		si,dx
	push	si		;coloca a abcisa xc-x na pilha	
	mov		si,bx
	add		si,cx
	push    si		;coloca a ordenada yc+y na pilha	
	call	line
	
	mov		si,ax
	sub		si,cx
	push	si		;coloca a abcisa xc-y na pilha			
	mov		si,bx
	sub		si,dx
	push    si		;coloca a ordenada yc-x na pilha
	mov		si,ax
	sub		si,cx
	push	si		;coloca a abcisa xc-y na pilha	
	mov		si,bx
	add		si,dx
	push    si		;coloca a ordenada yc+x na pilha	
	call	line
	
	cmp		cx,dx
	jb		fim_full_circle  ;se cx (y) est� abaixo de dx (x), termina     
	jmp		stay_full		;se cx (y) est� acima de dx (x), continua no loop
	
	
fim_full_circle:
	pop		di
	pop		si
	pop		dx
	pop		cx
	pop		bx
	pop		ax
	popf
	pop		bp
	ret		6
;-----------------------------------------------------------------------------
;
;   funcao line
;
; push x1; push y1; push x2; push y2; call line;  (x<639, y<479)
line:
		push		bp
		mov		bp,sp
		pushf                        ;coloca os flags na pilha
		push 		ax
		push 		bx
		push		cx
		push		dx
		push		si
		push		di
		mov		ax,[bp+10]   ; resgata os valores das coordenadas
		mov		bx,[bp+8]    ; resgata os valores das coordenadas
		mov		cx,[bp+6]    ; resgata os valores das coordenadas
		mov		dx,[bp+4]    ; resgata os valores das coordenadas
		cmp		ax,cx
		je		line2
		jb		line1
		xchg		ax,cx
		xchg		bx,dx
		jmp		line1
line2:		; deltax=0
		cmp		bx,dx  ;subtrai dx de bx
		jb		line3
		xchg		bx,dx        ;troca os valores de bx e dx entre eles
line3:	; dx > bx
		push		ax
		push		bx
		call 		plot_xy
		cmp		bx,dx
		jne		line31
		jmp		fim_line
line31:		inc		bx
		jmp		line3
;deltax <>0
line1:
; comparar m�dulos de deltax e deltay sabendo que cx>ax
	; cx > ax
		push		cx
		sub		cx,ax
		mov		[deltax],cx
		pop		cx
		push		dx
		sub		dx,bx
		ja		line32
		neg		dx
line32:		
		mov		[deltay],dx
		pop		dx

		push		ax
		mov		ax,[deltax]
		cmp		ax,[deltay]
		pop		ax
		jb		line5

	; cx > ax e deltax>deltay
		push		cx
		sub		cx,ax
		mov		[deltax],cx
		pop		cx
		push		dx
		sub		dx,bx
		mov		[deltay],dx
		pop		dx

		mov		si,ax
line4:
		push		ax
		push		dx
		push		si
		sub		si,ax	;(x-x1)
		mov		ax,[deltay]
		imul		si
		mov		si,[deltax]		;arredondar
		shr		si,1
; se numerador (DX)>0 soma se <0 subtrai
		cmp		dx,0
		jl		ar1
		add		ax,si
		adc		dx,0
		jmp		arc1
ar1:		sub		ax,si
		sbb		dx,0
arc1:
		idiv		word [deltax]
		add		ax,bx
		pop		si
		push		si
		push		ax
		call		plot_xy
		pop		dx
		pop		ax
		cmp		si,cx
		je		fim_line
		inc		si
		jmp		line4

line5:		cmp		bx,dx
		jb 		line7
		xchg		ax,cx
		xchg		bx,dx
line7:
		push		cx
		sub		cx,ax
		mov		[deltax],cx
		pop		cx
		push		dx
		sub		dx,bx
		mov		[deltay],dx
		pop		dx



		mov		si,bx
line6:
		push		dx
		push		si
		push		ax
		sub		si,bx	;(y-y1)
		mov		ax,[deltax]
		imul		si
		mov		si,[deltay]		;arredondar
		shr		si,1
; se numerador (DX)>0 soma se <0 subtrai
		cmp		dx,0
		jl		ar2
		add		ax,si
		adc		dx,0
		jmp		arc2
ar2:		sub		ax,si
		sbb		dx,0
arc2:
		idiv		word [deltay]
		mov		di,ax
		pop		ax
		add		di,ax
		pop		si
		push		di
		push		si
		call		plot_xy
		pop		dx
		cmp		si,dx
		je		fim_line
		inc		si
		jmp		line6

fim_line:
		pop		di
		pop		si
		pop		dx
		pop		cx
		pop		bx
		pop		ax
		popf
		pop		bp
		ret		8
;*******************************************************************
segment data

cor		db		branco_intenso

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
mensagem_jogada_invalida	db			'Jogada Invalida'

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
p				db			0

; ultima jogada
; 0 se ninguem jogou ainda
; 1 se X foi jogado por ultimo
; 2 se Circulo foi jogado por ultimo
ultima_jogada			db			0		

;*************************************************************************
segment stack stack
	resb 	512
stacktop: