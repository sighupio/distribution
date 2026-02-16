#!ipxe

# 1. Initialize Network (if not already done)
dhcp

# 2. Define the Base URL for your server
set base-url {{ .data.ipxeServerURL }}

show buildarch

# 3. Load the Flatcar Kernel
# We pass the ignition URL using the ${mac:hexhyp} variable
# which converts 52:54:00:12:34:56 to 52-54-00-12-34-56
kernel ${base-url}/assets/flatcar/${buildarch}/flatcar_production_pxe.vmlinuz \
    initrd=flatcar_production_pxe_image.cpio.gz \
    flatcar.first_boot=1 \
    ignition.config.url=${base-url}/ignition/${mac:hexhyp}/install-flatcar.json \
    console=ttyAMA0,115200

# 4. Load the Initrd (RAM disk)
initrd ${base-url}/assets/flatcar/${buildarch}/flatcar_production_pxe_image.cpio.gz

# 5. Boot the system
boot