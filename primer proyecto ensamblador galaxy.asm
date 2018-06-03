; Juego Galaxy
; Ronald Herrera, Jazmine Espinoza, Brayan Gutierrez

.MODEL SMALL
;_________________________________________________________ 

.STACK
    dw 128 dup(0)    
;_________________________________________________________
    
.data
   bienvenido db    'BIENVENIDO AL JUEGO GALAXY',10,13,'$'
   espacio    db    '__________________________',10,13,'$'
   ingrese    db    'Ingrese su nombre:','$';PONER NOMBRE EN PANTALLA

   nombreEtiqueta LABEL BYTE ; "nombre" es solo una etiqueta para identificar a tu cadena 
    longitudmax db 90  ; longitud maxima que podra tener la cadena 
    longitudreal db ? ;numero de bytes que mida tu cadena una vez leida 
    nombre db 90 DUP(0) ; vector de caracteres en el que se guardara la cadena
    
   separador  dw    '________________________________________________________________________________',10,13,'$'
   score      db    00h
   unidades   db    0
   decenas    db    0
   centenas   db    0
   vida       db    '', '$'
   enemigo    db    'è','$'
   aliado     db    'š','$'
   row        db    0    ; Fila
   column     db    0    ; Columna
   navex      db    40    ; Nave posicion x
   navey      db    20    ; Nave posicion y
   balax      db    40   ; Disparo posicion x
   balay      db    19    ; Disparo posicion y
   xene       db    ?
   yene       db    ?
   xali       db    ?
   yali       db    ?
   reset      db    'R: Reset','$'
   quit       db    'Q: Quit','$'
   cont       dw    ?
   conta      dw    ?
   x_vida     db    1
   y_vida     db    74
   msj_over   db    'GAME OVER!!, Presione ENTER para volver a jugar ','$'
   msj_win    db    'YOU WIN!!','Presione ENTER si desea volver a jugar','$'
   msj_try    db    'TRY AGAIN!!, Presione ENTER para volver a jugar ','$' 
   contador   db    0 
   
;__________________________________________________________

.code

;_________________________MACROS___________________________  

    buffer macro
        mov ax,0c00h
        mov cx,1
        int 21h
    endm 

    posicionar macro row,colum
        mov ah,02h
        mov bh,00
        mov dh,row
        mov dl,colum
        int 10h
    endm  
    
    imprimir_msj macro msj
        lea dx,msj
        mov ah,09h
        int 21h
    endm

     
    
    limpiar macro x,y,xfin,yfin,color ;limpiar pantalla
        mov ah,06h
        mov al,00h
        mov bh,color
        mov ch,y
        mov cl,x
        mov dh,xfin
        mov dl,yfin
        int 10h
    endm
    
    figura_ascii macro caracter,color ;macro para nave, disparo y vidas
        mov al,caracter
        mov bl,color
        mov cx,1
        mov ah,09h
        int 10h
    endm
    
    esconder_pulsor macro    
        mov ah,1
        mov ch,2bh     
        mov cl, 0bh
        int 10h
    endm 
    
    limpia_registros macro
     
        xor ax,ax
        xor bx,bx
        xor cx,cx
        xor dx,dx 
    endm  
    
    detectar_impresion_enemigo macro
        mov ah,08h
        mov bl,00
        int 10h 
        
        cmp al,enemigo
        je enemigos
    endm
    
    detectar_impresion_aliado macro 
        mov ah,08h
        mov bl,00
        int 10h 
        cmp al,enemigo
        je aliados
        cmp al,aliado
        je aliados 
        
    endm 
    
         
    inicio_mouse macro
        mov ax,00h ;Inicializar mouse
        int 33h
        
        mov ax, 01h
        int 33h  
    endm 
    
    mouse macro
      mov ax, 03h
      int 33h
    endm 

    
    posicionar_score macro  
 
        posicionar 1,39
        mov al,score
        aam
        
        mov unidades,al
        mov al,ah
        aam
        
        mov centenas,ah
        mov decenas,al
        mov ah,02h
        
        mov dl,centenas
        add dl, 30h
        int 21h
        
        mov dl, decenas
        add dl,30h
        int 21h
        
        mov dl,unidades
        add dl,30h
        int 21h
    endm
  
           
inicio:
   mov ax,@data
   mov ds,ax
   mov es,ax
   
;_________________________MODO VIDEO___________________________

  mov ah,00h
  mov al,02h   ;Modo de Texto de 80 x 25 (80 columnas y 25 filas)
  int 10h                                                        
  
;______________________PANTALLA PRINCIPAL______________________

limpiar 0,0,24,79,11111b ;da color a la pantalla
    
    posicionar 10,30         ;bienvenido al juego galaxy
    imprimir_msj bienvenido
    
    posicionar 11,30
    imprimir_msj espacio     ;espacio
    
    posicionar  19,01
    imprimir_msj ingrese
    
    guardarNombre:

        mov ah, 0Ah
        mov dx, offset nombreEtiqueta 
        int 21h 
        
        mov bh, 00 
        mov bl, longitudreal 
        mov nombre[bx], 07 
        mov nombre[bx+1], '$'
        
;______________________INICIA EL JUEGO______________________  
 
    limpiar 0,0,24,79,01111b
    
    posicionar 1,1
    imprimir_msj nombre
    
    posicionar 1,74
    figura_ascii vida,1100b
                 
    posicionar 1,75
    figura_ascii vida,1100b
    
    posicionar 1,76
    figura_ascii vida,1100b
    
    posicionar 1,77
    figura_ascii vida,1100b
    
    posicionar 1,78
    figura_ascii vida,1100b
      
    posicionar_score
  
    posicionar 2,0
    imprimir_msj separador
    
    posicionar 21,0
    imprimir_msj separador
    
    posicionar 23,72
    imprimir_msj reset
    
    posicionar 23,0
    imprimir_msj quit
    
    esconder_pulsor
   ;---------------------------------> ENEMIGOS <------------------------------
   
   mov cont,26  ; cantidad de veces que se van a imprimir los enemigos, (25) pero se pone 26
   enemigos:  ;impresion de los enemigos
        mov ah,2ch ;servicio 2ch(posiciones aleatorias con respecto al reloj 
        int 21h
            
        mov xene,dl ;posciones de los enemigos en la pantalla
        mov yene,dh ;posicion de los enemigos en la pantalla
        cmp xene,80  ;esta comparacion es para que la posicion no pase del rango de la pantalla
        jge enemigos
        cmp yene,7 ;rango en el eje y para que llegue hasta el punto 17 
        jge enemigos
        cmp yene,4  ;rango en eje y para que no sobre pase la linea separadora
        jl enemigos 
        posicionar yene,xene
        detectar_impresion_enemigo
        figura_ascii enemigo,1110b
        dec cont
        mov cx,cont
    loop enemigos;ciclo de impresion de los enemigos
    ;------------------------------> ALIADOS <------------------------------
    mov conta,6 ; cantidad de aliados que van a aparecer (5) pero se pone 6 el contador
    aliados: ;impresion de los aliados
        mov ah,2ch ;servicio 2ch(posiciones aleatorias con respecto al reloj 
        int 21h 
        mov xali,dl ;posciones de los aliados en la pantalla eje x
        mov yali,dh ;posicion de los aliados en la pantalla eje y
        cmp xali,80  ;esta comparacion es para que la posicion no pase del rango de la pantalla
        jge aliados
        cmp yali,7; rango del eje y para que no se toque la nave
        jge aliados ;si aliados en el eje y es mayor es porque se va a pasar y no va a servir por eso salta de nuevo para que de otras coordenadas
        cmp yali,4 ; rango para que no toquen la linea separadora en el eje y
        jl aliados
        posicionar yali,xali
        detectar_impresion_aliado
        figura_ascii aliado,1011b
        dec conta       ;se decrementa conta para que algun momento llegue a cero para que salga del ciclo
        mov cx,conta    ; cx tiene un 1 por eso se le asiga lo que tenga conta para que siga realizando el ciclo
    loop aliados
    ;---------------------------------> NAVE <--------------------------------
   
         
   juego:
   
    disparo_nave:

        posicionar navey,navex
        figura_ascii 127,0001b    ;nave
        
        posicionar balay,balax
        figura_ascii 42,12  ;bala   
        buffer    
    ;----------------------> ESPERANDO TECLA <-----------------------
    ;mouse,primero mouse y despues las teclas
    mov ax,0003h
    int 33h
    cmp bx,1    ; representa el mouse 
    je disparo
    
    mov ah,00h  ; deja ah preparado para la int 16
    int 16h
    ;----------------------> RESET Y QUIT <--------------------------
    
    cmp al,82           ;Se compara el caracter leido con la tecla 'R'
    je resetear         ;Se le hace reset programa 
    
    cmp al,114          ;Se compara el caracter leido con la tecla 'r'
    je resetear         ;Se le hace reset programa        
        
    cmp al,81           ;Se compara el caracter leido con la tecla 'Q'
    je salir            ;Sale del programa
                                      
    cmp al,113          ;Se compara el caracter leido con la tecla 'q'
    je salir            ;Sale del programa  
       

    ;----------------------> MOVIMIENTO <--------------------------
   
    cmp ah,39h  ; representa la barra de espacio
    je disparo 
    
   ; cmp bx,1    ; representa el mouse  ARREGLAR
;    je disparo
    
    cmp ah,75   ;representa la tecla izquierda
    je izquierda
    
    cmp ah,77   ;representa la tecla derecha 
    je derecha
    
    jne sonido
    
    jmp juego
    
    derecha:
        posicionar navey,navex  ;nave
        figura_ascii 127,0
        inc navex
        
        posicionar balay,balax ;bala
        figura_ascii 42,0
        inc balax
        buffer
        jmp disparo_nave 
    
    izquierda:
        posicionar navey,navex  ;nave
        figura_ascii 127,0
        dec navex
        
        posicionar balay,balax ;bala
        figura_ascii 42,0
        dec balax
        buffer
        jmp disparo_nave
        
    disparo:
        posicionar balay,balax 
        figura_ascii 42,0  ;bala
        dec balay
        jmp colicion  
         
        
    colicion:
       cmp balay,4 ;aqui desaparece la bala
       jbe regresaBala
       
       posicionar balay,balax 
       figura_ascii 42,12  ;bala         
       posicionar balay,balax 
       figura_ascii 42,0  ;Ultima bala se elimine
       
       dec balay              
       posicionar balay,balax 
       ;------- Leer caracter de pantalla -------
       mov ah,08h
       mov bh,00h
       int 10h
       ;------- Buscar enemigos o aliados -------
       mov bh,1110b
       cmp al, enemigo
       cmp ah,bh 
       je sumar
       mov bh,1011b
       cmp al, aliado
       cmp ah,bh
       je restar
       inc balay ;Eliminar la ultima posicion del disparo
       posicionar balay,balax 
       figura_ascii 42,0  ;bala 
       dec balay ;Vuelve a decrementar para tener la posicion actual 
       jmp colicion 
       
    Regresa_resta:  
       dec balay
       posicionar balay,balax
       figura_ascii 42,0         
       jmp colicion  
       
    Regresa_suma:  
       posicionar balay,balax
       figura_ascii 42,0  ;Elimina el caracter impactado
       dec balay        
       jmp regresaBala
                         
                     
    regresaBala:
        mov balay,19    ;linea del eje y donde esta arriba de la nave
        jmp disparo_nave    ; el disparo regresa a la nave 
        
    restar: 
      posicionar x_vida,y_vida
      figura_ascii ' ',0
      inc y_vida 
      cmp y_vida, 79
      je game_over
       
      cmp score,00h
      je game_over
      
      cmp score,10
      je resta_10
      
      sub score,20
      posicionar_score
      jmp Regresa_resta
    
    resta_10:
      sub score,10
      posicionar_score
      jmp regresa_resta
      
                  
    sumar:
       inc contador
       cmp contador,24
       je comparar 
       add score,10
       limpia_registros
       posicionar_score
                      
       jmp Regresa_suma  
       
   comparar:
      cmp score,150
      jbe  try_again
      ja you_win 
   
          
    game_over:
       limpia_registros
       limpiar 0,0,24,79,11111b
       posicionar 12,15
       imprimir_msj msj_over
       jmp enter
       
    enter:
       mov ah,00h  ; Espera ENTER
       int 16h
       cmp al,0Dh
       je resetear
       jne game_over
       
    try_again:
       limpia_registros
       limpiar 0,0,24,79,11111b
       posicionar 12,15
       imprimir_msj msj_try
       jmp enter2
    
    enter2:
      mov ah,00h  ; Espera ENTER
      int 16h
      cmp al,0Dh
      je resetear
      jne try_again 
    
       
    you_win:
       limpia_registros
       limpiar 0,0,24,79,11111b
       posicionar 12,15
       imprimir_msj msj_win
       jmp press            

    press:
       mov ah,00h  ; Espera ENTER
       int 16h
       cmp al,0Dh
       je resetear
       jne salir 
    
    sonido:
        mov ah,2
        mov dl,07h
        int 21h
        jmp juego
    
        
    ;-------------------------------------------------------------------------
    resetear:
        limpia_registros
        limpiar 0,0,24,79,11111b
        xor dx,dx
        mov score,00h
        mov x_vida,1
        mov y_vida,74
        buffer       
        mov contador,0
        jmp inicio                 
                              	
    salir:         
    	
        mov ah,4Ch      ;Se termina el programa
        int 21h   

end inicio                                                                 