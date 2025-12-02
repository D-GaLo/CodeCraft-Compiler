
# ⛏️ CodeCraft Compiler

**CodeCraft** es un lenguaje de programación temático basado en *Minecraft* y *Redstone*, diseñado para compilar código de alto nivel hacia instrucciones de ensamblador para la Máquina Virtual **FIS-25**.

Este proyecto fue desarrollado como parte del curso de Compiladores, implementando un **Lexer**, **Parser** y **Generador de Código** desde cero.

##  Características

* **Temática Minecraft:** Palabras reservadas intuitivas (`piston`, `repeater`, `comparator`, `redstone`).
* **Gráficos Integrados:** Funciones nativas para manipular la matriz de 64x64 (`glowstone`).
* **Control de Flujo:** Soporte completo para bucles `for`, `while` y condicionales `if-else`.
* **Entrada de Usuario:** Lectura de puertos de teclado mapeados (`pressure_plate`, `lever`).
---

##  Requisitos Previos

Para compilar este proyecto necesitas un entorno basado en Unix (Linux, MacOS o WSL en Windows) con las siguientes herramientas instaladas:

* **GCC** (GNU Compiler Collection)
* **Flex** (Fast Lexical Analyzer Generator)
* **Bison** (GNU Parser Generator)
* **Make** (Build automation tool)

```bash
# Instalación en Ubuntu/Debian
sudo apt-get update
sudo apt-get install gcc flex bison make
````

-----

##  Instrucciones de Compilación

El proyecto incluye un `Makefile` para automatizar el proceso de construcción.

1.  Abre una terminal en la carpeta del proyecto.
2.  Ejecuta el comando `make` para generar el compilador:

<!-- end list -->

```bash
make
```

Esto generará el ejecutable binario llamado `codecraft_compiler`.

> **Nota:** Si deseas limpiar los archivos generados (código objeto, parsers en C), utiliza:
>
> ```bash
> make clean
> ```

-----

##  Ejecución del Compilador

Una vez compilado, puedes transformar tus archivos `.craft` (Código Fuente) a `.fis` (Código Ensamblador).

**Sintaxis:**

```bash
./codecraft_compiler <archivo_fuente.craft>
```

**Ejemplo con el Reloj Analógico:**

```bash
./codecraft_compiler reloj.craft
```

Si la compilación es exitosa, verás el mensaje:

> `Compilacion exitosa! Revisa output.fis`

Se generará un archivo llamado **`output.fis`** en el mismo directorio.

-----

##  Simulación en FIS-25

Para ver tu código en acción, utilizaremos el simulador web oficial.

**Enlace al Simulador:**  [FIS-25 Simulator en Itch.io](https://amm-gdev.itch.io/fis-25)

### Pasos para simular:

1.  Abre el archivo `output.fis` generado con cualquier editor de texto (VS Code, Notepad, etc.).
2.  **Copia** todo el contenido del archivo.
3.  Ve al enlace del simulador web.
4.  En el panel izquierdo **"CODE EDITOR"**, pega el código ensamblador.
5.  Presiona el botón azul **"Run"** en la parte superior derecha.

###  Interacción con el reloj

Para que el simulador detecte las teclas, debes hacer lo siguiente:

1.  Haz **CLIC IZQUIERDO** una vez sobre el área negra de la pantalla (**Screen 64x64**) para darle foco.

**Controles del Proyecto Reloj (Opción A):**
| Acción | Tecla Física | Puerto CodeCraft |
| :--- | :--- | :--- |
| **Avanzar Minutos (+5)** | `Flecha Abajo` | `pressure_plate(2)` |
| **Avanzar Horas (+1)** | `Flecha Izquierda` | `pressure_plate(1)` |


##  Autores

**Equipo 4 - Laboratorio de Compiladores**

  * Angel Moisés González Corrales
  * Francisco Daniel García López
  * Erik Eduardo Gómez López
