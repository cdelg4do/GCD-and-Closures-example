# Ejercicio de clase del Módulo 07 iOS Avanzado (Agosto 2016)

**EjemploGCD** es un prototipo de aplicación para iOS realizada en Swift 3.0 con Xcode 8.

Se trata de una aplicación sencilla para ilustrar el uso de **Grand Central Dispatch** en Swift, que realiza la carga de imágenes pesadas desde internet de diferentes modos:

- En el hilo principal de ejecución
- En segundo plano
- En segundo plano con clausura de finalización (protocolo del actor)

Para comprobar si se está bloqueando la interfaz de usuario durante estas operaciones, se dispone en pantalla de un slider que permite ajustar el valor alpha (transparencia) de la imágen en pantalla en tiempo real.

