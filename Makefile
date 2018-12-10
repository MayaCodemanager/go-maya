# This Makefile is meant to be used by people that do not usually work
# with Go source code. If you know what GOPATH is then you probably
# don't need to bother with make.

.PHONY: gmaya android ios gmaya-cross swarm evm all test clean
.PHONY: gmaya-linux gmaya-linux-386 gmaya-linux-amd64 gmaya-linux-mips64 gmaya-linux-mips64le
.PHONY: gmaya-linux-arm gmaya-linux-arm-5 gmaya-linux-arm-6 gmaya-linux-arm-7 gmaya-linux-arm64
.PHONY: gmaya-darwin gmaya-darwin-386 gmaya-darwin-amd64
.PHONY: gmaya-windows gmaya-windows-386 gmaya-windows-amd64

GOBIN = $(shell pwd)/build/bin
GO ?= latest

gmaya:
	build/env.sh go run build/ci.go install ./cmd/gmaya
	@echo "Done building."
	@echo "Run \"$(GOBIN)/gmaya\" to launch gmaya."

swarm:
	build/env.sh go run build/ci.go install ./cmd/swarm
	@echo "Done building."
	@echo "Run \"$(GOBIN)/swarm\" to launch swarm."

all:
	build/env.sh go run build/ci.go install

android:
	build/env.sh go run build/ci.go aar --local
	@echo "Done building."
	@echo "Import \"$(GOBIN)/gmaya.aar\" to use the library."

ios:
	build/env.sh go run build/ci.go xcode --local
	@echo "Done building."
	@echo "Import \"$(GOBIN)/Gmaya.framework\" to use the library."

test: all
	build/env.sh go run build/ci.go test

lint: ## Run linters.
	build/env.sh go run build/ci.go lint

clean:
	./build/clean_go_build_cache.sh
	rm -fr build/_workspace/pkg/ $(GOBIN)/*

# The devtools target installs tools required for 'go generate'.
# You need to put $GOBIN (or $GOPATH/bin) in your PATH to use 'go generate'.

devtools:
	env GOBIN= go get -u golang.org/x/tools/cmd/stringer
	env GOBIN= go get -u github.com/kevinburke/go-bindata/go-bindata
	env GOBIN= go get -u github.com/fjl/gencodec
	env GOBIN= go get -u github.com/golang/protobuf/protoc-gen-go
	env GOBIN= go install ./cmd/abigen
	@type "npm" 2> /dev/null || echo 'Please install node.js and npm'
	@type "solc" 2> /dev/null || echo 'Please install solc'
	@type "protoc" 2> /dev/null || echo 'Please install protoc'

swarm-devtools:
	env GOBIN= go install ./cmd/swarm/mimegen

# Cross Compilation Targets (xgo)

gmaya-cross: gmaya-linux gmaya-darwin gmaya-windows gmaya-android gmaya-ios
	@echo "Full cross compilation done:"
	@ls -ld $(GOBIN)/gmaya-*

gmaya-linux: gmaya-linux-386 gmaya-linux-amd64 gmaya-linux-arm gmaya-linux-mips64 gmaya-linux-mips64le
	@echo "Linux cross compilation done:"
	@ls -ld $(GOBIN)/gmaya-linux-*

gmaya-linux-386:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/386 -v ./cmd/gmaya
	@echo "Linux 386 cross compilation done:"
	@ls -ld $(GOBIN)/gmaya-linux-* | grep 386

gmaya-linux-amd64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/amd64 -v ./cmd/gmaya
	@echo "Linux amd64 cross compilation done:"
	@ls -ld $(GOBIN)/gmaya-linux-* | grep amd64

gmaya-linux-arm: gmaya-linux-arm-5 gmaya-linux-arm-6 gmaya-linux-arm-7 gmaya-linux-arm64
	@echo "Linux ARM cross compilation done:"
	@ls -ld $(GOBIN)/gmaya-linux-* | grep arm

gmaya-linux-arm-5:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/arm-5 -v ./cmd/gmaya
	@echo "Linux ARMv5 cross compilation done:"
	@ls -ld $(GOBIN)/gmaya-linux-* | grep arm-5

gmaya-linux-arm-6:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/arm-6 -v ./cmd/gmaya
	@echo "Linux ARMv6 cross compilation done:"
	@ls -ld $(GOBIN)/gmaya-linux-* | grep arm-6

gmaya-linux-arm-7:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/arm-7 -v ./cmd/gmaya
	@echo "Linux ARMv7 cross compilation done:"
	@ls -ld $(GOBIN)/gmaya-linux-* | grep arm-7

gmaya-linux-arm64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/arm64 -v ./cmd/gmaya
	@echo "Linux ARM64 cross compilation done:"
	@ls -ld $(GOBIN)/gmaya-linux-* | grep arm64

gmaya-linux-mips:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/mips --ldflags '-extldflags "-static"' -v ./cmd/gmaya
	@echo "Linux MIPS cross compilation done:"
	@ls -ld $(GOBIN)/gmaya-linux-* | grep mips

gmaya-linux-mipsle:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/mipsle --ldflags '-extldflags "-static"' -v ./cmd/gmaya
	@echo "Linux MIPSle cross compilation done:"
	@ls -ld $(GOBIN)/gmaya-linux-* | grep mipsle

gmaya-linux-mips64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/mips64 --ldflags '-extldflags "-static"' -v ./cmd/gmaya
	@echo "Linux MIPS64 cross compilation done:"
	@ls -ld $(GOBIN)/gmaya-linux-* | grep mips64

gmaya-linux-mips64le:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/mips64le --ldflags '-extldflags "-static"' -v ./cmd/gmaya
	@echo "Linux MIPS64le cross compilation done:"
	@ls -ld $(GOBIN)/gmaya-linux-* | grep mips64le

gmaya-darwin: gmaya-darwin-386 gmaya-darwin-amd64
	@echo "Darwin cross compilation done:"
	@ls -ld $(GOBIN)/gmaya-darwin-*

gmaya-darwin-386:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=darwin/386 -v ./cmd/gmaya
	@echo "Darwin 386 cross compilation done:"
	@ls -ld $(GOBIN)/gmaya-darwin-* | grep 386

gmaya-darwin-amd64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=darwin/amd64 -v ./cmd/gmaya
	@echo "Darwin amd64 cross compilation done:"
	@ls -ld $(GOBIN)/gmaya-darwin-* | grep amd64

gmaya-windows: gmaya-windows-386 gmaya-windows-amd64
	@echo "Windows cross compilation done:"
	@ls -ld $(GOBIN)/gmaya-windows-*

gmaya-windows-386:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=windows/386 -v ./cmd/gmaya
	@echo "Windows 386 cross compilation done:"
	@ls -ld $(GOBIN)/gmaya-windows-* | grep 386

gmaya-windows-amd64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=windows/amd64 -v ./cmd/gmaya
	@echo "Windows amd64 cross compilation done:"
	@ls -ld $(GOBIN)/gmaya-windows-* | grep amd64
