#####################################
#
# Copyright 2017-2018 NXP
#
#####################################

INSTALL_DIR ?= /
INSTALL ?= install

GOROOT ?= $(HOME)/go
GOPATH := $(shell pwd)

GO_VERSION ?= 1.8.5
GO_URL ?= https://redirector.gvt1.com/edgedl/go
HOST_ARCH ?= $(shell uname -m | sed -e s/i.86/386/ -e s/x86_64/amd64/ \
                                   -e s/i386/386/ -e s/aarch64.*/arm64/ )

KUBE_VERSION ?= 1.7.0
ARCH ?= arm64

# Below ENVs should be overrided

CROSS_COMPILE ?= aarch64-linux-gnu-
CC := ${CROSS_COMPILE}gcc


kubelet:goenv fetch-kube
	export GOROOT=$(GOROOT) && \
	export GOPATH=$(GOPATH) && \
	export PATH=$(GOROOT)/bin:$(PATH) && \
	export CGO_ENABLED=1 GOOS=linux GOARCH=${ARCH} && \
	export CC=${CC}  && \
	cd $(GOPATH)/src/k8s.io/kubernetes && \
	go env && \
	go build -o $(GOPATH)/images/kubelet --ldflags="-w -s" cmd/kubelet/kubelet.go

clean:
	cd $(GOPATH)/src/k8s.io/kubernetes && \
	$(MAKE) clean

install:
	sudo $(INSTALL) -d --mode 755 $(INSTALL_DIR)/usr/local/bin
	sudo $(INSTALL) -d --mode 755 $(INSTALL_DIR)/etc/

	sudo cp -r $(GOPATH)/images/kubelet $(INSTALL_DIR)/usr/local/bin
	sudo cp -r scripts/* $(INSTALL_DIR)/usr/local/bin/

goenv:
	if [ ! -f $(GOROOT)/bin/go ]; then  \
		wget -c $(GO_URL)/go$(GO_VERSION).linux-$(HOST_ARCH).tar.gz; \
		tar -C $(HOME) -xzf go$(GO_VERSION).linux-$(HOST_ARCH).tar.gz; \
	fi
	if [ ! -d $(GOPATH)/src/k8s.io ]; then  \
		mkdir -p $(GOPATH)/src/k8s.io; \
	fi
	mkdir -p $(GOPATH)/images

fetch-kube:
	if [ ! -f $(GOPATH)/src/k8s.io/kubernetes/pkg/version/version.go ]; then  \
		wget -c https://github.com/kubernetes/kubernetes/archive/v$(KUBE_VERSION).tar.gz; \
		tar -xf v$(KUBE_VERSION).tar.gz; \
		mv kubernetes-$(KUBE_VERSION) $(GOPATH)/src/k8s.io/kubernetes; \
	fi

.PHONY: kubelet clean install goenv fetch-kube
