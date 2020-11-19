.data
file_in: .asciiz "source.txt"
buffer: .space 4000
strBuffer: .space 64
str: 	.space 2000
msg:  .asciiz "Ingrese una cadena: "

 

newLine:   .asciiz "\n"
.text

main:

#Abre el archivo que se va a leer

	li $v0, 13	 #Codigo que syscall reconoce para abrir archivos desde una ruta
	la $a0, file_in  #Se inserta la ruta del archivo a leer
	li $a1, 0	 # el codigo "0" llevado a $a1 indica que el archivo sera SOLAMENTE leido
	li $a2, 0	 #Este parametro mode se ignora para este syscall
	syscall		 #El archivo es abierto
	move $s0, $v0    #Se guarda el desriptor del archivo a $s0


	
#Leer el archivo que fue abierto para su lectura

	li $v0, 14	#14 es para leer un archivo que ya fue previamiente abierto desde una ruta
	move $a0, $s0	#Enviamos como parametro(con $a0) el descriptor del archivo que teniamos guardado en $s0
	la $a1, buffer	#Enviamos como parametro(con $a1) el buffer que creamos en el .data
	li $a2, 4000	#Tamaño de caracteres que seran leidos
	syscall		#El archivo es leido
	
#Imprimir el contenido del archivo

	li $v0, 4	#4 enviado a $v0 es para imprimnir un string
	la $a0, buffer  #En el buffer enviado antes como parametro quedo guardado en contenido del archivo
	syscall		#Imprime en consola
	
	#Aqui deberiamos saltar a calcular la longitud del archivo de texto para luego poder iterar
	
#Imprimir un salto de linea
	la $a0, newLine
	li $v0, 4
	syscall
	 
userInputData:
	#Aqui se imprime al usuario y se recibe el string ingresado
	la $a0, msg          #Mensaje que se le imprime en consola al usuario
	la $a1, 30
	la $a2, strBuffer    #En este buffer se guarda la cadena ingresada por el usuario
	li $v0, 4            #Codigo que reonoce syscall para imprimir un string
	syscall		     #Imprime el mensaje al usuario
	
	#Obtener entrada usuario
	move $a0, $a2        #Obtiene la direccion del buffer(que almacena la cadena ingresada por el usuario) que esta en $a2 y la mueve a $a0
	li $v0, 8	     #Lee la entrada del usuario string
	syscall
	
	#Imprime lo que ingreso el usuario(Par probar que si se guardo)
	move $a0, $a2
	li $v0, 4
	syscall
	
	
	
	la $t0, strBuffer 	#Posicion de memoria del primer caracter en la cadena ingresada
	la $t1, buffer 	  	#Posicion de memoria del primer caracter en el texto 
	add $t4, $t4, $zero  	#Inicializa el contador, 
	
recorrerTxt: 
	lbu $t2, 0($t1) 	#Caracter del texto en posicion $t1
	beq $t2, $zero, final	#Se sale del ciclo si llega al final del archivo, osea un caracter null que es assci es igual 00000000
	lbu $t3, 0($t0) 	#Caracter del string ingresado en posicion $t0
	
	bne $t2, $t3, noEqual   #Si un caracter en el string es distinto al caracter en el archivo txt
		addi $t0, $t0, 1 #Este es el if en alto nivel, si son iguales los caracteres, ambos apuntadores son aumentados para pasar al siguiente
		addi $t1, $t1, 1
		lbu $t3, 0($t0)  #Carga en $t3 el caracter del string despues de haber avanzado(Aumentado el apuntador $t0)
		bne $t3, 10, recorrerTxt   #Determina si reiniciamos el string
			addi $t4, $t4, 1      #Cada vez que se termine un string aumenta para contar una aparicion, asociado al registro $t4
			la $t0, strBuffer     #Reinicia el apuntador del string a la primera posicion
		j recorrerTxt
noEqual: 
	addi $t1, $t1, 1
	la $t0, strBuffer
	
	
	j recorrerTxt
final:
	
	
	
	
	
