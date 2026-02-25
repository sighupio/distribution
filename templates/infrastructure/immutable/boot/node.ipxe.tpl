#!ipxe
kernel {{ .ipxeServerURL }}/assets/flatcar/{{ .arch }}/flatcar_production_pxe.vmlinuz flatcar.first_boot=1 ignition.config.url={{ .ipxeServerURL }}/ignition/{{ .macNormalized }}/install-flatcar.json console=ttyS0,115200n8 console=tty0
initrd {{ .ipxeServerURL }}/assets/flatcar/{{ .arch }}/flatcar_production_pxe_image.cpio.gz
boot
