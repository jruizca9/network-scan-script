## 🤝 Contribuyendo
¡Agradecemos sus contribuciones! Siéntase libre de:

Compartir los problemas debido a errores o solicitudes de nuevas funcionalidades.
Envía solicitudes de extracción para mejorar el código.
Comparte tus comentarios e ideas.



# 🔎 Bash Port Scanner

Pequeño script en Bash para escanear puertos abiertos en una dirección IP o nombre de host.  
Creado como parte de mi proceso de aprendizaje en **ciberseguridad**, **Kali Linux**, y **scripting con Bash**.

---

## 🚀 ¿Qué hace?

Este script realiza un escaneo de puertos TCP dentro de un rango especificado, detectando puertos abiertos en un host destino.  
Utiliza herramientas estándar como `nc` (netcat) y `timeout`.

---

## 🛠️ Uso

```bash
bash port-scan.sh <IP> <PUERTO_INICIAL> <PUERTO_FINAL> [TIMEOUT]

