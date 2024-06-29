.data
pantalla: .asciz "___________________________________________________\n                                                   |\n      *** AHORCADO DE ANIMALES - ORGA 1 ***        |\n___________________________________________________|\n                                                   |\n                                                   |\n          +------------+                           |\n          |            |                           |\n          |                                        |\n          |                                        |\n          |                                        |\n          |                                        |\n          |                                        |\n          |                                        |\n          |                                        |\n          |                                        |\n +-------------------------------------------+     |\n |                                           |     |\n |                 _____                     |     |\n |                                           |     |\n +-------------------------------------------+     |\n"
lenpantalla=.-pantalla

cls:.asciz "\x1b[H\x1b[2J"
lencls=.-cls
letraingresada: .asciz "     "
letrasIngresadasBuffer: .asciz "             "
numLetrasIngresadas: .word 0
mensajeLetrasIngresadas: .asciz "Letras ingresadas: "
lenMensajeLetrasIngresadas = . - mensajeLetrasIngresadas
startMSG: .asciz "Ingrese su Nombre: \n"
lenstartMSG=.-startMSG
nombre: .asciz " "
nombres: .asciz "chuli\nclara\nian"
ganadorPodio1: .asciz " "
ganadorPodio2: .asciz " "
ganadorPodio3: .asciz " "
errorArchivo: .asciz "Error al abrir archivo"
lenErrorArchivo = . -errorArchivo
palabras: .asciz "/home/orga2021/occ1g7/TP/TP-final/palabras.txt"
ranking: .asciz "/home/orga2021/occ1g7/TP/TP-final/ranking.txt"
descriptorArchivo: .word 0
leerPalabras: .space 1024
espaciosPalabra: .space 30
palabraOculta: .asciz "      "
largoPalabra: .byte 5
mensajeSolicitarNumero: .asciz "Por favor, ingrese un numero del 1 al 50:\n"
lenMensajeSolicitarNumero = . - mensajeSolicitarNumero
mensajeErrorNumero: .asciz "Entrada invalida. Por favor, ingrese un numero del 1 al 50:\n"
lenMensajeErrorNumero = . - mensajeErrorNumero
bufferNumero: .asciz "    "  // Buffer para almacenar el número ingresado (4 bytes)
bufferNumeroDecimal: .word 0
cantidadaciertos: .byte 0
cantidadfallos: .byte 0 //vidas
cabeza: .asciz "O"
brazoDerecha: .byte 92 // no puedo usar "\" me da muchos errores raros
cuerpo: .asciz "|"
brazoIzquierda: .asciz "/"
pedirLetra: .asciz "\n\nPrueba una letra: "
lenPedirLetra=.-pedirLetra
ganador: .asciz "\n \n \n_________________________________________________  \n|                                                 | \n|                                                 | \n|                                                 | \n|                                                 | \n|                                                 | \n|                                                 | \n|                     Ganaste!	                  | \n|                        :)                       | \n|                                                 | \n|                                                 | \n|                     Podio                       | \n|            1.                                   | \n|            2.                                   | \n|            3.                                   | \n|                                                 | \n _________________________________________________  \n \n \n \n"
lenGanador=.-ganador
perdedor: .asciz "\n \n \n_________________________________________________  \n|                                                 | \n|                                                 | \n|                                                 | \n|                                                 | \n|                                                 | \n|                                                 | \n|                     Perdiste!                   | \n|                        :(                       | \n|                                                 | \n|                                                 | \n|                     Podio                       | \n|            1.                                   | \n|            2.                                   | \n|            3.                                   | \n|                                                 | \n _________________________________________________  \n \n \n \n"
lenPerdedor=.-perdedor
disparoMSG: .asciz "Ingresa coordenada X e Y para salvarte\n"
lendisparoMSG=.-disparoMSG
xCoordenada: .asciz "     "
yCoordenada: .asciz "     "
xMSG: .asciz "ingrese coordenada para X (dos digitos)\n"
lenxMSG=.-xMSG
yMSG: .asciz "ingrese una coordenada para Y (un digito)\n"
lenyMSG=.-yMSG

.text
//----------------------------------------------------------
menuInicial:
    	.fnstart
    	push {lr}
    	ldr r1, =startMSG
    	bl preguntarNombre
    	bl leerNombre
    	pop {lr}
    	bx lr
    	.fnend

preguntarNombre:
    	.fnstart
    	push {lr}
    	mov r7, #4
    	mov r0, #1
    	ldr r2, =lenstartMSG
    	swi 0
    	pop {lr}
    	bx lr
    	.fnend

leerNombre:
    	.fnstart
    	push {lr}
    	mov r7, #3
    	mov r0, #0
    	ldr r1, =nombre
    	mov r2, #100
    	swi 0
    	pop {lr}
    	bx lr
    	.fnend
//----------------------------------------------------------
jugar:
    	bl limpiarLaPantalla
    	bl imprimirMapa
	bl LetrasIngresadas
	bl imprimirLetrasIngresadas
    	bl solicitarLetra
    	bl ingresarUnaLetra
    	bl verificarletra
    	bl dibujarCuerpo
    	ldr r2,=cantidadfallos
    	ldrb r2,[r2]
    	mov r6,#6
    	cmp r6,r2
	beq Disparo
    	ldr r1,=cantidadaciertos
    	ldrb r2,[r1]
    	ldr r3,=largoPalabra
    	ldrb r3,[r3]
    	cmp r3,r2
    	beq ganaste
    	bal jugar
//----------------------------------------------------------
seleccionarPalabra:
    	.fnstart
    	push {r1, r2, r3, r4, r5, lr}
    	bl abrirArchivo
    	bl solicitarNumero
    	ldr r1, =leerPalabras
    	ldr r5, =bufferNumeroDecimal
    	ldr r5, [r5]       
    	sub r5, r5, #1     // restar 1 para convertir el número ingresado a índice basado en 0 para recorrer
    	mov r3, #0

loopSeleccionarPalabra:
    	cmp r3, r5
    	beq encontrarPalabra
    	ldrb r4, [r1], #1
    	cmp r4, #10        // comparar con '\n'
    	bne loopSeleccionarPalabra
    	add r3, r3, #1
    	b loopSeleccionarPalabra

encontrarPalabra:
    	mov r3, #0
    	ldr r2, =palabraOculta

loopCopiaPalabra:
    	ldrb r4, [r1], #1
    	cmp r4, #10        // comparar con '\n'
    	beq finCopiaPalabra
    	strb r4, [r2, r3]
    	add r3, r3, #1
    	b loopCopiaPalabra

finCopiaPalabra:
   	mov r4, #0 // Añadir terminador nulo al final de la palabra porque es un asciz
    	strb r4, [r2, r3]
    	pop {r1, r2, r3, r4, r5, lr}
    	bx lr
    	.fnend
//----------------------------------------------------------
abrirArchivo:
	.fnstart
	push {r0, r1, r2, lr}
        mov r7, #5           
        ldr r0, =palabras     
        mov r1, #0x42        
        mov r2, #384        
        swi 0                

        cmp r0, #0       
        blt error 

        mov r4, r0        	
 leerArchivo:
        mov r7, #3        
        mov r0, r4        
        ldr r1, =leerPalabras   
        mov r2, #300
        swi 0
        cmp r0, #0 
        blt error
	bal cerrarArchivo
    	.fnend
//----------------------------------------------------------
cerrarArchivo:
	.fnstart
	mov r7, #6
	swi 0
	pop {r0, r1, r2, lr}
	bx lr
    	.fnend
//----------------------------------------------------------
error:
	.fnstart
    	mov r7,#4
    	mov r0,#1
    	ldr r1,=errorArchivo
    	ldr r2,=lenErrorArchivo
    	swi 0
    	pop {r0, r1, r2, lr}
    	bal fin
    	.fnend
//----------------------------------------------------------
generarNumeroRandom:
    	// Generar número aleatorio
    	push {lr}
    	mov r5, #6
    	pop {lr}
    	bx lr
//----------------------------------------------------------
imprimirMapa: //imprime el mapa del juego
    	.fnstart
    	push {lr}
    	mov r7,#4
   	mov r0,#1
    	ldr r2,=lenpantalla
    	ldr r1,=pantalla
    	swi 0
    	pop {lr}
    	bx lr
    	.fnend
//----------------------------------------------------------
ingresarUnaLetra: 
    	.fnstart
    	push {lr}
    	mov r7,#3
    	mov r0,#0
    	ldr r1,=letraingresada
    	swi 0
	bl almacenarLetraIngresada
    	pop {lr}
    	bx lr
    	.fnend
//----------------------------------------------------------
solicitarLetra:
	.fnstart
    	push {lr}
    	mov r7,#4
    	mov r0,#1
    	ldr r1,=pedirLetra
    	ldr r2,=lenPedirLetra
    	swi 0
    	pop {lr}
    	bx lr
    	.fnend
//----------------------------------------------------------
almacenarLetraIngresada:
    	.fnstart
    	push {r0, r1, r2, r5, lr}
    	ldr r1, =letraingresada
    	ldrb r2, [r1]
	mov r5, #95

    	// Almacenar la letra ingresada en el buffer
    	ldr r1, =letrasIngresadasBuffer
    	ldr r3, =numLetrasIngresadas
    	ldr r4, [r3]
    	add r1, r1, r4
    	strb r2, [r1]
	add r1, r1, #1
    	strb r5, [r1]

    	// Incrementar el contador de letras ingresadas
    	add r4, r4, #1
    	str r4, [r3]

    	pop {r0, r1, r2, r5, lr}
    	bx lr
    	.fnend
//----------------------------------------------------------
LetrasIngresadas:	
	.fnstart
    	push {lr}
    	mov r7,#4
    	mov r0,#1
    	ldr r1,=mensajeLetrasIngresadas
    	ldr r2,=lenMensajeLetrasIngresadas
    	swi 0
    	pop {lr}
    	bx lr
    	.fnend
//----------------------------------------------------------
imprimirLetrasIngresadas:	
	.fnstart
    	push {lr}
    	mov r7,#4
    	mov r0,#1
    	ldr r1,=letrasIngresadasBuffer
    	ldr r2,=numLetrasIngresadas
	ldr r2, [r2]
    	swi 0
    	pop {lr}
    	bx lr
    	.fnend
//----------------------------------------------------------
limpiarLaPantalla:
    	.fnstart
    	push {lr}
    	mov r0,#1
    	ldr r1,=cls
    	ldr r2,=lencls
    	mov r7,#4
    	swi 0
    	pop {lr}
   	bx lr
    	.fnend
//----------------------------------------------------------
solicitarNumero:
     	.fnstart
    	push {r4, r5, lr}
    	mov r0, #1
    	ldr r1, =mensajeSolicitarNumero
    	ldr r2, =lenMensajeSolicitarNumero
    	mov r7, #4
    	swi 0

solicitarNumeroLoop:
    	mov r0, #0
    	ldr r1, =bufferNumero       
    	mov r2, #4                  
    	mov r7, #3                  
    	swi 0                      

     	bl convertirNumero          
    	ldr r5, =bufferNumeroDecimal 
    	ldr r5, [r5]
    
    	// Verificar si el número está en el rango deseado (1-50)
    	cmp r5, #1
    	blt solicitarNumeroError
    	cmp r5, #50
    	bgt solicitarNumeroError

    	b solicitarNumeroParaSalir

solicitarNumeroError:
    	mov r0, #1                 
    	ldr r1, =mensajeErrorNumero
    	ldr r2, =lenMensajeErrorNumero
    	mov r7, #4                  
    	swi 0                       
    	b solicitarNumeroLoop

solicitarNumeroParaSalir:
    	pop {r4, r5, lr}
    	bx lr
    	.fnend
//----------------------------------------------------------
convertirNumero:
    	.fnstart
    	push {r1, r2, r3, r4, r5, lr}
    	ldr r1, =bufferNumero
    	mov r2, #0
    	mov r3, #10
    	mov r4, #0  // Registro temporal para el resultado de la multiplicación

convertirLoop:
    	ldrb r5, [r1], #1
    	cmp r5, #'0'
    	blt finConvertir
    	cmp r5, #'9'
    	bgt finConvertir
    	sub r5, r5, #'0'
    	mov r4, r2
    	mul r2, r4, r3
    	add r2, r2, r5
    	b convertirLoop

finConvertir:
    	ldr r1, =bufferNumeroDecimal
    	str r2, [r1]
    	pop {r1, r2, r3, r4, r5, lr}
    	bx lr
	.fnend
//----------------------------------------------------------
letrasQueYaEstan: //revisa si la letra ya esta en la pantalla
	.fnstart
	push {lr}
	mov r3,#910
	mov r12,#0
	cicloIN:
		ldr r2,=pantalla
		ldrb r6,[r2,r3]
		cmp r9,r6
		beq sumaIN
		cmp r3,#920
		beq finIN
		add r3,#1
		bal cicloIN
	sumaIN:
		add r12,#1
		add r3,#1
		bal cicloIN
	finIN:
		pop {lr}
		bx lr
	.fnend
//----------------------------------------------------------
verificarletra: 
	.fnstart
	push {lr}
	ldr r10,=cantidadfallos
	ldrb r5,[r10]
	mov r4,#0
	ldr r1,=letraingresada
	ldrb r9,[r1]
	bl letrasQueYaEstan
	cmp r12,#0
	beq continuar
	bal finciclo
	continuar:
		mov r3,#1
	ciclopalabra:
		ldr r2,=largoPalabra
		ldrb r2,[r2]
		ldr r8,=palabraOculta
		ldrb r6,[r8,r4]
		cmp r4,r2
		beq finciclo

		cmp r9,r6
		beq mostrarletra

		cmp r3,r2
		beq letraincorrecta
		bal fail
	fail:
		add r3,#1
		add r4,#1
		bal ciclopalabra
	letraincorrecta:
		add r5,#1 //aumento el contador de fallos
		strb r5,[r10] //lo subo a la memoria
		add r4,#1 //aumento el contador para cambiar la letra
		bal ciclopalabra
	mostrarletra:
		ldr r11,=pantalla
		mov r12,#972
		add r12,r4
		strb r9,[r11,r12]
		add r4,#1
		ldr r1,=cantidadaciertos
		ldrb r7,[r1]
		add r7,#1
		strb r7,[r1]
		bl limpiarLaPantalla
		bl imprimirMapa
		bal ciclopalabra
	finciclo:
		pop {lr}
		bx lr
	.fnend
//----------------------------------------------------------
guardarGanadoresViejos:
    	.fnstart
	abrirArchivoRanking:
		push {r0, r1, r2, lr}
        		mov r7, #5           
        		ldr r0, =ranking     
        		mov r1, #0x42        
        		mov r2, #384        
        		swi 0                

        		cmp r0, #0       
        		blt error 

        		mov r4, r0        	
 	leerArchivoRanking:
        		mov r7, #3        
        		mov r0, r4        
        		ldr r1, =nombres
        		mov r2, #50
        		swi 0
        		cmp r0, #0 
        		blt error
		bal cerrarArchivo
    	.fnend

//----------------------------------------------------------
insertarNombres:
    	.fnstart
    	push {r1, r3, r4, r12, lr}
    
    	ldr r1, =ganador
    	ldr r4, =nombre      
    	mov r12, #655 // posición del primer nombre
loopUNO:
    	ldrb r3, [r4]
    	cmp r3, #10 // compara con '\n'
    	beq siguienteNombre
    	cmp r3, #0
    	beq finInsertar
    	strb r3, [r1, r12]
    	add r4, r4, #1
    	add r12, r12, #1
    	b loopUNO

siguienteNombre:
    	add r4, r4, #1 // salta el '\n'

    	mov r12, #698
loopDOS:
    	ldrb r3, [r4]
    	cmp r3, #10 // compara con '\n'
    	beq siguienteNombreDos
    	cmp r3, #0
    	beq finInsertar
    	strb r3, [r1, r12]
    	add r4, r4, #1
    	add r12, r12, #1
    	b loopDOS

siguienteNombreDos:
    	add r4, r4, #1 // salta el '\n'

   	mov r12, #750 loopTRES:
    	ldrb r3, [r4]
    	cmp r3, #10 // compara con '\n'
    	beq finInsertar
    	cmp r3, #0
    	beq finInsertar
    	strb r3, [r1, r12]
    	add r4, r4, #1
    	add r12, r12, #1
    	b loopTRES

finInsertar:
    	pop {r1, r3, r4, r12, lr}
    	bx lr
    	.fnend
//----------------------------------------------------------
guardarGanador:
    	.fnstart
    	.fnend
//----------------------------------------------------------
ganaste:
    	bl limpiarLaPantalla
    	//bl guardarGanadoresViejos
    	//bl insertarNombres
    	//bl guardarGanador
    	mov r7, #4
    	mov r0, #1
    	ldr r2, =lenGanador
    	ldr r1, =ganador
    	swi 0
    	bal fin
//----------------------------------------------------------
perdiste:
    	bl limpiarLaPantalla
    	mov r7,#4
    	mov r0,#1
    	ldr r2,=lenPerdedor
    	ldr r1,=perdedor
    	swi 0
    	bal fin
//----------------------------------------------------------
dibujarCuerpo:
    	.fnstart
    	push {r0, r1, r2, r3, r4, lr}
    	ldr r1,=pantalla
    	ldr r2,=cantidadfallos
    	ldrb r3,[r2]
    	cmp r3,#1
    	beq UNfallo
	cmp r3,#2
    	beq DOSfallos
	cmp r3,#3
    	beq TRESfallos
	cmp r3,#4
    	beq CUATROfallos
	cmp r3,#5
    	beq CINCOfallos
	cmp r3,#6
    	beq SEISfallos
	b findibujo

UNfallo:
    	mov r12, #446
    	ldr r9, =cabeza
    	ldrb r10, [r9]
   	strb r10, [r1, r12]
    	b findibujo

DOSfallos:
    	mov r12, #499
    	ldr r9, =cuerpo
    	ldrb r10, [r9]
    	strb r10, [r1, r12]
    	b findibujo

TRESfallos:
    	mov r12, #498
    	ldr r9, =brazoIzquierda
    	ldrb r10, [r9]
    	strb r10, [r1, r12]
    	b findibujo

CUATROfallos:
	mov r12, #500
   	ldr r9, =brazoDerecha
    	ldrb r10, [r9]
    	strb r10, [r1, r12]
    	b findibujo

CINCOfallos:
    	mov r12, #551
   	ldr r9, =brazoIzquierda
    	ldrb r10, [r9]
    	strb r10, [r1, r12]
    	b findibujo

SEISfallos:
    	mov r12, #553
   	ldr r9, =brazoDerecha
    	ldrb r10, [r9]
    	strb r10, [r1, r12]
    	b findibujo

findibujo:
    	bl limpiarLaPantalla
    	bl imprimirMapa
    	pop {r0, r1, r2, r3, r4, lr}
    	bx lr
    	.fnend
//----------------------------------------------------------
Disparo:
	bl limpiarLaPantalla
	bl DisparoMSG
	bl MSGejeX
	bl ingresarXCoordenada
	bl MSGejeY
	bl ingresarYCoordenada
	ldr r0,=xCoordenada
	ldrb r1,[r0, #0]
	cmp r1,#0x32
	beq segundoDigitoX
	bal perdiste
segundoDigitoX:
	ldrb r1,[r0,#1]
	//sub r1, r1, #48
	cmp r1,#0x34
	beq digitoY
	bal perdiste
digitoY:
	ldr r0,=yCoordenada
	ldrb r1,[r0]
	//sub r1, r1, #48
	cmp r1,#0x38
	beq ganaste
	bal perdiste
//----------------------------------------------------------
DisparoMSG:
	.fnstart
	push {lr}
	mov r7,#4
        mov r0,#1
        ldr r2,=lendisparoMSG
        ldr r1,=disparoMSG
        swi 0
	pop {lr}
	bx lr
	.fnend
//----------------------------------------------------------
MSGejeX:
        .fnstart
        push {lr}
	mov r7,#4
        mov r0,#1
        ldr r2,=lenxMSG
        ldr r1,=xMSG
        swi 0
        pop {lr}
        bx lr
        .fnend
//----------------------------------------------------------
ingresarXCoordenada:
        .fnstart
        push {lr}
	mov r7,#3
        mov r0,#0
        mov r2,#3
        ldr r1,=xCoordenada
        swi 0
        pop {lr}
        bx lr
        .fnend
//----------------------------------------------------------
MSGejeY:
        .fnstart
        push {lr}
	mov r7,#4
        mov r0,#1
        ldr r2,=lenyMSG
        ldr r1,=yMSG
        swi 0
        pop {lr}
        bx lr
        .fnend
//----------------------------------------------------------
ingresarYCoordenada: 
	.fnstart
        push {lr}
	mov r7,#3
        mov r0,#0
        mov r2,#2
        ldr r1,=yCoordenada
        swi 0
        pop {lr}
        bx lr
        .fnend
//----------------------------------------------------------
fin:
    	mov r7,#1
    	swi 0

//----------------------------------------------------------
.global main

main:
    	bl menuInicial
    	bl seleccionarPalabra
	b jugar
