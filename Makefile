#####################################
#
# Copyright 2017 NXP
#
#####################################

INSTALL_DIR ?= /
INSTALL ?= install

GOROOT ?= $(HOME)/go
GOPATH ?= $(HOME)/gopathdir

GO_VERSION ?= 1.8.5
GO_URL ?= https://redirector.gvt1.com/edgedl/go
HOST_ARCH ?= $(shell uname -m | sed -e s/i.86/386/ -e s/x86_64/amd64/ \
                                   -e s/i386/386/ -e s/aarch64.*/arm64/ )

KUBE_VERSION ?= 1.7.0
ARCH ?= arm64


kubelet:goenv fetch-kube
	export GOROOT=$(GOROOT) && \
	export GOPATH=$(GOPATH) && \
	export PATH=$(GOROOT)/bin:$(PATH) && \
	$(MAKE) -C kubernetes-$(KUBE_VERSION) WHAT="/cmd/libs/go2idl/deepcopy-gen" && \
   	$(MAKE) -C kubernetes-$(KUBE_VERSION) WHAT="cmd/kubelet" KUBE_BUILD_PLATFORMS="linux/$(ARCH)"

clean:
	$(MAKE) -C kubernetes-$(KUBE_VERSION) clean

install:
	sudo $(INSTALL) -d --mode 755 $(INSTALL_DIR)/usr/local/bin
	sudo $(INSTALL) -d --mode 755 $(INSTALL_DIR)/etc/

	sudo cp -r kubernetes-$(KUBE_VERSION)/_output/local/go/bin/linux_$(ARCH)/kubelet $(INSTALL_DIR)/usr/local/bin
	sudo cp -r etc/kubernetes $(INSTALL_DIR)/etc/
	sudo cp -r scripts/* $(INSTALL_DIR)/usr/local/bin/

goenv:
	if [ ! -f $(GOROOT)/bin/go ]; then  \
		wget -c $(GO_URL)/go$(GO_VERSION).linux-$(HOST_ARCH).tar.gz; \
		tar -C $(HOME) -xzf go$(GO_VERSION).linux-$(HOST_ARCH).tar.gz; \
	fi

fetch-kube:
	if [ ! -f kubernetes-$(KUBE_VERSION)/pkg/version/version.go ]; then  \
		wget -c https://github.com/kubernetes/kubernetes/archive/v$(KUBE_VERSION).tar.gz; \
		tar -xf v$(KUBE_VERSION).tar.gz; \
	fi

.PHONY: kubelet clean install goenv fetch-kube
