segment code
..start:
    mov ax, data
    mov ds, ax
    mov ax, stack
    mov ss, ax
    mov sp, stacktop

    mov dx, msg
    mov ah, 09h
    int 21h

    mov ah, 4ch
    int 21h

segment data
    CR equ 0dh
    LF equ 0ah

    msg db 'Ola mundo', CR, LF, '$'

segment stack stack
    resb 256
stacktop: