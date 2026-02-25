#!ipxe

# 1. Initialize Network (if not already done)
dhcp

# 2. Define the Base URL for your server
set base-url {{ .data.ipxeServerURL }}

# 3. Chain to node-specific boot configuration based on MAC address
# The ${mac:hexhyp} variable converts 52:54:00:12:34:56 to 52-54-00-12-34-56
chain ${base-url}/boot/${mac:hexhyp}