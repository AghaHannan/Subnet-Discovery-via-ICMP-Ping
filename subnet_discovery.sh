#!/bin/bash
# subnet_discovery.sh - Discover /24 subnets by pinging gateway addresses

# Default parameters
GATEWAY=1                      # Default host in each /24 to ping (change to 2 to use .2)
DELAY=0                        # Delay in seconds between pings (0 = no delay)
OUTPUT_FILE="accessible_subnets.txt"

# Usage information
function usage() {
  echo "Usage: $0 [-g gateway_host] [-d delay_seconds] [-o output_file]"
  echo "  -g   Host number in each subnet to ping (default: $GATEWAY)."
  echo "  -d   Delay in seconds between pings (default: $DELAY)."
  echo "  -o   Output file (default: $OUTPUT_FILE)."
  exit 1
}

# Parse options if provided
while [[ $# -gt 0 ]]; do
  case "$1" in
    -g|--gateway)  GATEWAY="$2"; shift 2 ;;
    -d|--delay)    DELAY="$2";  shift 2 ;;
    -o|--output)   OUTPUT_FILE="$2"; shift 2 ;;
    -h|--help)     usage ;;
    *) echo "Unknown option: $1"; usage ;;
  esac
done

# Initialize output file
echo "# Accessible /24 Subnets (responded to ping)" > "$OUTPUT_FILE"
echo "# Scanned gateway host: .$GATEWAY, delay: $DELAY sec" >> "$OUTPUT_FILE"
echo "# -----------------------------" >> "$OUTPUT_FILE"

# Function to ping a given IP once
ping_host() {
  local ip="$1"
  # Send 1 ping with 1-second wait, suppress output
  ping -c 1 -W 1 "$ip" > /dev/null 2>&1
  return $?
}

# Scan 10.0.0.0/8 (10.*.*.0/24 networks)
for second in {0..255}; do
  for third in {0..255}; do
    ip="10.$second.$third.$GATEWAY"
    if ping_host "$ip"; then
      echo "$ip replied"
      echo "10.$second.$third.0/24" >> "$OUTPUT_FILE"
    fi
    # Optional delay between pings
    if [[ $DELAY -gt 0 ]]; then
      sleep $DELAY
    fi
  done
done

# Scan 172.16.0.0/12 (172.16-31.*.0/24 networks)
for second in {16..31}; do
  for third in {0..255}; do
    ip="172.$second.$third.$GATEWAY"
    if ping_host "$ip"; then
      echo "$ip replied"
      echo "172.$second.$third.0/24" >> "$OUTPUT_FILE"
    fi
    if [[ $DELAY -gt 0 ]]; then
      sleep $DELAY
    fi
  done
done

# Scan 192.168.0.0/16 (192.168.*.0/24 networks)
for third in {0..255}; do
  ip="192.168.$third.$GATEWAY"
  if ping_host "$ip"; then
    echo "$ip replied"
    echo "192.168.$third.0/24" >> "$OUTPUT_FILE"
  fi
  if [[ $DELAY -gt 0 ]]; then
    sleep $DELAY
  fi
done
