#!/bin/bash

# Colores
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m'

# Validar argumentos
if [ "$#" -lt 3 ] || [ "$#" -gt 4 ]; then
    echo -e "${YELLOW}Uso: $0 <IP> <PUERTO_INICIAL> <PUERTO_FINAL> [TIMEOUT]${NC}"
    echo -e "Ejemplo: ${GREEN}$0 192.168.1.1 20 1000${NC}"
    echo -e "Ejemplo: ${GREEN}$0 192.168.1.1 20 1000 2${NC}"
    exit 1
fi

# Variables
ip=$1
port_start=$2
port_end=$3
timeout_val=${4:-1}
timestamp=$(date "+%Y-%m-%d %H:%M:%S")
filename_time=$(date "+%Y-%m-%d_%H-%M")
output_file="resultados_${filename_time}.txt"
total_ports=$((port_end - port_start + 1))

# Encabezado del archivo
{
echo "==============================="
echo "Escaneo de puertos en $ip"
echo "Fecha y hora: $timestamp"
echo "Rango: puertos $port_start a $port_end (timeout: ${timeout_val}s)"
echo "==============================="
} > "$output_file"

# Función para identificar servicios
get_service_name() {
    case $1 in
        21) echo "FTP" ;;
        22) echo "SSH" ;;
        23) echo "Telnet" ;;
        25) echo "SMTP" ;;
        53) echo "DNS" ;;
        80) echo "HTTP" ;;
        110) echo "POP3" ;;
        143) echo "IMAP" ;;
        443) echo "HTTPS" ;;
        3306) echo "MySQL" ;;
        5432) echo "PostgreSQL" ;;
        6379) echo "Redis" ;;
        8080) echo "HTTP-alt" ;;
        *) echo "Desconocido" ;;
    esac
}

# Mostrar mensaje de inicio
echo -e "${BLUE}Escaneando puertos abiertos en $ip de $port_start a $port_end...${NC}"

# Pipe para contar progresos
progress_pipe=$(mktemp -u)
mkfifo "$progress_pipe"
exec 3<> "$progress_pipe"
rm "$progress_pipe"

# Mostrar progreso en hilo separado
(
    scanned=0
    while read -r <&3; do
        ((scanned++))
        percent=$((scanned * 100 / total_ports))
        printf "\rProgreso: %3d%% (%d/%d puertos)" "$percent" "$scanned" "$total_ports"
    done
) &

progress_pid=$!

# Escaneo paralelo
for port in $(seq $port_start $port_end); do
    (
        nc -z -w $timeout_val $ip $port &>/dev/null
        if [ $? -eq 0 ]; then
            service=$(get_service_name $port)
            echo -e "${GREEN}[+] Puerto $port abierto - Servicio: $service${NC}"
            echo "[+] Puerto $port abierto - Servicio: $service" >> "$output_file"
        fi
        echo "" >&3  # Incrementa progreso
    ) &
done

wait
exec 3>&-  # Cierra pipe
wait $progress_pid

echo -e "\n${BLUE}Escaneo completado. Resultados guardados en ${YELLOW}${output_file}${NC}"
