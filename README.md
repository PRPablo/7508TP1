# 75.08 - SISTEMAS OPERATIVOS TP1 - GRUPO 01
#
#-PRE Requisitos

1. Sistema operativo basado en distribución Linux.

2. Conocimiento básico de comandos shell script.

3. Permisos de ejecucion para el instalador que se encuentra en grupo01/inst/instalador.sh 


#-Documentación

Guía de instalación del programa:

1. Abra una terminal y navegue hasta el directorio grupo01 (donde se descargó el programa).

2. Moverse al directorio de instalación grupo01/inst y ejecute siguiente comando: "$ ./instalador.sh"

3. El instalador detecta si el programa no está instalado, si necesita reparación o si ya se encuentra instalado satisfactoriamente, y se lo notificará.

4. En el caso en que no se encuentre instalado, el programa solicitará que ingrese algunos parámetros de configuración previo a la instalación. Dichos parámetros tienen un valor predeterminado, indicado por pantalla. En caso de que no desee modificar alguno, sólo presione la tecla Enter cuando el sistema le solicite definirlo: estas consultas son directorios a crear al momento de la instalación.

5. El programa solicitará confirmación de la instalación. Ingrese la opción SI para continuar o la opción NO para volver al punto 4. Si cancela la instalación sin confirmarla, no se creará ningún directorio.

6. Al confirmarse la instalación, se crean todos los directorios seleccionados dentro del directorio grupo01 y un archivo de configuración en grupo01/inst/instalador.conf

7. En el caso de reparar el programa, debe ejecutar el script de instalación con el parámetro -r de la siguiente manera: "$ ./instalador.sh -r"

8. Si se desea editar la hora de cierre del proceso, se debe reparar el programa (explicado en el punto 7) para seleccionar todo nuevamente. Tenga en cuenta que se perderán todos los datos ya procesados.

9. Los pasos que va realizando el instalador, son logueados en el archivo grupo01/inst/instalador.log


Guía de inicialización del programa:

1. Abra una terminal y navegue hasta el directorio grupo01 (donde se descargó el programa).

2. Moverse al directorio de ejecutables que seleccionó dentro del directorio grupo01 (grupo01/bin por defecto) y ejecute el siguiente comando: "$ . ./inicializador.sh"

3. El inicializador lee el archivo instalador.conf para chequear la existencia de todos los directorios, que los archivos del directorio de ejecutables (grupo01/bin por defecto) tengan permisos de ejecución y que los archivos del directorio de tablas (grupo01/tab por defecto) tengan permisos de lectura.

4. Si no se cumplen estas condiciones, la inicialización mostrará un mensaje de error y se deberá recuperar el sistema. (Guía de instalación del programa, punto 7).

5. una vez terminiada la inicialización tendrá disponible en su ambiente las variables necesarias, y se ejecutará el proceso automáticamente en segundo plano. Es importante NO CERRAR LA TERMINAL, para no perder dichas variables, ya que sobre la misma se debe detener / arrancar el proceso manualmente explicado en sus propias guías.

6. El inicializador mostrará por pantalla el id del proceso, el cual quedará corriendo indefinidamente, procesando los archivos del directorio de novedades (grupo01/nov por defecto), hasta que se lo detenga manualmente (Guía de detención del programa manualmente). (Aclaración, siempre sobre la misma terminal, como se mencionó en el punto anterior).

7. Los pasos que va realizando el inicializador, son logueados en el directorio de procesados (grupo01/proc por defecto) en el archivo instalador.log


Guía de arranque del programa manualmente:

1. Abra una terminal y navegue hasta el directorio grupo01 (donde se descargó el programa).

2. Moverse al directorio de ejecutables que seleccionó dentro del directorio grupo01 (grupo01/bin por defecto) y ejecute el siguiente comando: "$ ./arranque.sh"

3. El arranque detecta si el programa ya se encuentra coriendo o no en segundo plano, o si falta la inicialización del programa, y se lo notificará.

4. Los pasos que va realizando el proceso de arranque, son logueados en el directorio de procesados (grupo01/proc por defecto) en el archivo arranque.log


Guía de detención del programa manualmente:

1. Abra una terminal y navegue hasta el directorio grupo01 (donde se descargó el programa).

2. Moverse al directorio de ejecutables que seleccionó dentro del directorio grupo01 (grupo01/bin por defecto) y ejecute el siguiente comando: "$ ./detencion.sh"

3. El proceso de detención detecta si el programa se encuentra coriendo en segundo plano, y lo detiene, o no, y se lo notificará.

4. Los pasos que va realizando el proceso de detención, son logueados en el directorio de procesados (grupo01/proc por defecto) en el archivo detencion.log
