#####################################
#
# Copyright 2017 NXP
#
#####################################

INSTALL_DIR ?= /
INSTALL ?= install

GOROOT ?= $(HOME)/go
GOPATH ?= $(HOME)/gopathdir
GOFILE ?= go1.8.5.linux-amd64.tar.gz
KUBE_VERSION ?= 1.7.0

kubelet:goenv fetch-kube
	export GOROOT=$(GOROOT) && \
	export GOPATH=$(GOPATH) && \
	export PATH=$(GOROOT)/bin:$(PATH) && \
	$(MAKE) -C kubernetes-$(KUBE_VERSION) WHAT="/cmd/libs/go2idl/deepcopy-gen" && \
   	$(MAKE) -C kubernetes-$(KUBE_VERSION) WHAT="cmd/kubelet" KUBE_BUILD_PLATFORMS="linux/arm64"

clean:
	$(MAKE) -C kubernetes-$(KUBE_VERSION) clean

install:
	sudo $(INSTALL) -d --mode 755 $(INSTALL_DIR)/usr/local/bin
	sudo $(INSTALL) -d --mode 755 $(INSTALL_DIR)/etc/

	sudo cp -r kubernetes-$(KUBE_VERSION)/_output/local/go/bin/linux_arm64/kubelet $(INSTALL_DIR)/usr/local/bin
	sudo cp -r etc/kubernetes $(INSTALL_DIR)/etc/
	sudo cp -r scripts/* $(INSTALL_DIR)/usr/local/bin/

goenv:
	if [ ! -f $(GOROOT)/bin/go ]; then  \
		wget -c https://redirector.gvt1.com/edgedl/go/$(GOFILE); \
		tar -C $(HOME) -xzf $(GOFILE); \
	fi

fetch-kube:
	if [ ! -f kubernetes-$(KUBE_VERSION)/pkg/version/version.go ]; then  \
		wget -c https://github.com/kubernetes/kubernetes/archive/v$(KUBE_VERSION).tar.gz; \
		tar -xf v$(KUBE_VERSION).tar.gz; \
	fi

.PHONY: kubelet clean install goenv fetch-kube
