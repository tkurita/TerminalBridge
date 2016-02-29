product:="${DSTROOT}/Library/Application Support/mi3/TerminalBridge.app"

define remove-product
  #printenv
  if [ -n '"${PS1}"' ] && [ -e ${product} ]; then rm -rf ${product}; fi
endef

build:

clean:
	$(remove-product)
    
install:
    