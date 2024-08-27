org     0x7c00
bits    16

start:
    xor ax, ax                  ; setup segments (by setting them all to zero)
    mov ds, ax
    mov es, ax

                                ; setup stack
    cli                         ; disable interrupts (to be safe while seting stack segment and pointer)
    mov ss, ax
    mov sp, 0x7c00              ; stack starts at 0x7c00 and points downwards - see memory map (x86), we still have space there
    sti                         ; enable interrupts

    jmp 0:.dummy                  ; use a far jump to set cs to zero
.dummy:
    call clearScreen

    mov si, welcomeString
    call printString

    cli                         ; hang computer
hang:
    hlt
    jmp hang

printString:
    push ax
.loop:
    lodsb

    cmp al, 0x0                 ; detect NULL byte, and exit
    je .end
    call printChar
    jmp .loop
.end:
    pop ax
    ret

printChar:
    push cx

    mov ah, 0x0a
    mov cx, 0x01
    int 0x10

    call moveCursor

    pop cx
    ret

moveCursor:
    push dx

    mov dx, [curP]              ; load current cursor position

    inc dl                      ; move cursor to the right
    cmp dl, 80                  ; check if within the the line HACK: hardcoded width
    jbe .end                    ; if yes, just move the cursor, if no, move to the next line
    mov dl, 0                   ; reset x position
    inc dh                      ; increase y position
    cmp dh, 25                  ; check if we still have lines on screen HACK: hardcoded height
    jbe .end                    ; if yes, just move the cursor, if no, move to the first line
    mov dh, 0                   ; move to the first line

.end:
    mov ah, 0x02
    int 0x10

    push bx
    mov bx, curP
    mov [bx], dx
    pop bx

    pop dx
    ret


clearScreen:
    push ax

    ; clear screen (by setting the video mode): http://www.ctyme.com/intr/rb-0069.htm
    xor ax, ax                  ; ah=0
    mov al, 0x03                ; al=0x03, 80x25
    int 0x10

    pop ax
    ret

welcomeString:
    db "Welcome from ziny bootloader!", 0

curP:
curX:
    db 0
curY:
    db 0

times 510 - ($-$$) db 0         ; zero out the rest of boot sector

dw 0xaa55                       ; boot signature
