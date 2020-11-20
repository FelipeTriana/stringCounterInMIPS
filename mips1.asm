.data
file_in: .asciiz "source.txt"
file_out: .asciiz "output.txt"
buffer: .space 4000
strBuffer: .space 64
str: 	.space 2000
msg:  .asciiz "Ingrese un string para buscar coincidencias: "
str1: .asciiz "Nro de veces primer string es:  "
str2: .asciiz "\nNro de veces segundo string es:  \n"
str3: .asciiz "\nNro de veces tercer string es:  \n"
 

.text

main:

#Abre el archivo que se va a leer

	li $v0, 13	 #Codigo que syscall reconoce para abrir archivos desde una ruta
	la $a0, file_in  #Se inserta la ruta del archivo a leer
	li $a1, 0	 # el codigo "0" llevado a $a1 indica que el archivo sera SOLAMENTE leido
	li $a2, 0	 #Este parametro mode se ignora para este syscall
	syscall		 #El archivo es abierto
	move $s0, $v0    #Se guarda el desriptor del archivo a $s0

#Apertura del archivo sobre el que se escribira
	li $v0, 13
	la $a0, file_out 
	li $a1, 1
	li $a2, 0
	syscall
	move $s1, $v0
	
#Leer el archivo que fue abierto para su lectura

	li $v0, 14	#14 es para leer un archivo que ya fue previamiente abierto desde una ruta
	move $a0, $s0	#Enviamos como parametro(con $a0) el descriptor del archivo que teniamos guardado en $s0
	la $a1, buffer	#Enviamos como parametro(con $a1) el buffer que creamos en el .data
	li $a2, 4000	#Tama?o de caracteres que seran leidos
	syscall		#El archivo es leido
	
#Imprimir el contenido del archivo

	li $v0, 4	#4 enviado a $v0 es para imprimnir un string
	la $a0, buffer  #En el buffer enviado antes como parametro quedo guardado en contenido del archivo
	syscall		#Imprime en consola
	
	#Aqui deberiamos saltar a calcular la longitud del archivo de texto para luego poder iterar
	
	 
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
	la $t4 0 	        #Inicializa el contador, 
	
iterateTxt: 
	lbu $t2, 0($t1) 	#Caracter del texto en posicion $t1
	beq $t2, $zero, writeString	#Se sale del ciclo y va a escribir el nro de apariciones, si llega al final del archivo, osea un caracter null que en ascii es igual 00000000
	lbu $t3, 0($t0) 	#Caracter del string ingresado en posicion $t0
	
	bne $t2, $t3, noEqual   #Si un caracter en el string es distinto al caracter en el archivo txt
		addi $t0, $t0, 1 #Este es el if en alto nivel, si son iguales los caracteres, ambos apuntadores son aumentados para pasar al siguiente
		addi $t1, $t1, 1
		lbu $t3, 0($t0)  #Carga en $t3 el caracter del string despues de haber avanzado(Aumentado el apuntador $t0)
		bne $t3, 10, iterateTxt   #Determina si reiniciamos el string
			addi $t4, $t4, 1      #Cada vez que se termine un string aumenta para contar una aparicion, asociado al registro $t4
			la $t0, strBuffer     #Reinicia el apuntador del string a la primera posicion
		j iterateTxt		      
noEqual: 			 #Si los caracteres del string y el texto no son iguales	
	addi $t1, $t1, 1	 #va a mover el apuntador del texto para seguir leyendo
	la $t0, strBuffer	 #Reiniciara el apuntador del string para que apunte a la primera posicion
	j iterateTxt		 #Seguira buscando alguna repeticion del string en el texto


writeString:
	addiu $t5, $t5, 1	# $t5 ser el registro contador para saber cuantos string hemos analizado
		
	beq $t5, 1, fStr	# Los condicionales nos evaluan el valor de $t5 y nos redirigen a una de los string para realizar el proceso de escritura en el archivo
	beq $t5, 2, sStr
	beq $t5, 3, tStr
	
fStr:			   #----Se escribe en el archivo lo que corresponde al texto diferenciador para el primer string
	move $a0, $s1		#Enviamos como parametro el descriptor del archivo donde escribiremos
	li $v0, 15		#Syscall 15 par indicar que deseamos escribir
	la $a1, str1		#Le llevamos a $a1 la direccion del buffer como indica la documentacion
	li $a2, 32		#Definimos un numero de caracteres a escribir
	syscall			#Se realiza la llamada al sistema
	j printCounter		#Nos dirijimos al procedimiento que nos ayudara a escribir debajo de la constante string el nro de apariciones del string ingresado

sStr:			   #----Se escribe en el archivo lo que corresponde al texto diferenciador para el segundo string		
	move $a0, $s1	   #Lo de arriba se repite para la segunda constante string
	li $v0, 15
	la $a1, str2
	li $a2, 33
	syscall
	j printCounter

tStr:			   #----Se escribe en el archivo lo que corresponde al texto diferenciador para el segundo string
	move $a0, $s1	   #Lo de arriba se repite para la tercera constante string	
	li $v0, 15
	la $a1, str3
	li $a2, 33
	syscall
	j printCounter
		
printCounter:
	move $a0, $t4     #Se carga el string leido en $a0
	la $a1, str 	  #Se envia el buffer	
	jal int2str       #Se invoca el procedimiento que hace el parsing de integer a string para poder escribir en el archivo
    
    
	li $v0, 15	 #Con el dato convertido lo escribimos en archivo, debajo del texto del string
	move $a0, $s1	 #Indicamos el descriptor del archivo
	la $a1, str	 #cargamos en $a1 como parametro el buffer
	li $a2, 10	 #El numero de caracteres a escribir
	syscall		 #La llamada al sistema escribe en el archivo
    
    bne $t5, 3, userInputData	#Si $t5 NO  es igual a 3 quiere decir que nos falta evaluar string ingresadas, por lo tanto sigue con las faltantes.
    				#Si $t5 en cambio es igual a 3 termina la ejecucion el programa y cierra los archivos
    
    
        #Se cierran los archivos y se termina la ejecucion del programa
 
	li   $v0, 16       # syscall para cerrar el archivo 
	move $a0, $s0      # Enviamos como parametro el descriptor del archivo de lectura
	syscall            # Cerramos el archivo de lectura
	
	li   $v0, 16       # syscall para cerrar el archivo 
	move $a0, $s1      # Enviamos como parametro el descriptor del archivo de escritura 
	syscall            # Cerramos el archivo de escritura
			
Exit:	li   $v0, 10	   # Syscall para terminar la ejecucion del programa. Necesario en esta zona pues con el metodo de abajo se haria un loop infinito
	syscall
	
	
int2str:
addi $sp, $sp, -4
sw $t0, ($sp)
bltz $a0, neg_num
j next0

neg_num:
li $t0, '-'
sb $t0, ($a1)
addi $a1, $a1, 1
li $t0, -1
mul $a0, $a0, $t0

next0:
li $t0, -1
addi $sp, $sp, -4
sw $t0, ($sp)

	
push_digits:
blez $a0, next1
li $t0, 10
div $a0, $t0
mfhi $t0
mflo $a0
addi $sp, $sp, -4
sw $t0, ($sp)
j push_digits

next1:
lw $t0, ($sp)
addi $sp, $sp, 4

bltz $t0, neg_digit
j pop_digits

neg_digit:
li $t0, '0'
sb $t0,($a1)
addi $a1, $a1, 1
j next2

pop_digits:
bltz $t0, next2
addi $t0, $t0, '0'
sb $t0, ($a1)
addi $a1, $a1, 1
lw $t0, ($sp)
addi $sp, $sp, 4
j pop_digits

next2:
sb $zero, ($a1)	

lw $t0, ($sp)
addi $sp, $sp, 4
jr $ra	


	
	
	
	
