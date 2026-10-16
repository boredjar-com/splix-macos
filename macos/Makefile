# SPDX-License-Identifier: GPL-2.0-only
# Builds the SpliX `rastertoqpdl` CUPS filter as a universal (arm64 + x86_64)
# macOS binary, with JBIG support linked statically from JBIG-KIT.
#
# Usage:  make -C macos            -> build/rastertoqpdl
#         make -C macos clean

TOP        := $(abspath $(CURDIR)/..)
SPLIX      := $(TOP)/third_party/splix-2.0.1
JBIG       := $(TOP)/third_party/jbigkit-2.1/libjbig
BUILD      := $(TOP)/build
ARCHS      ?= -arch arm64 -arch x86_64
MINOS      ?= -mmacosx-version-min=12.0
THREADS    ?= 2
CACHESIZE  ?= 30

CXX        := clang++
CC         := clang
COMMON     := $(ARCHS) $(MINOS) -O2 -fvisibility=hidden -Wno-deprecated-declarations
CXXFLAGS   := $(COMMON) -std=gnu++14 -I$(SPLIX)/include -I$(JBIG) \
              -DTHREADS=$(THREADS) -DCACHESIZE=$(CACHESIZE)
CFLAGS     := $(COMMON) -I$(JBIG)
LDFLAGS    := $(ARCHS) $(MINOS) -lcups -lcupsimage -lpthread

SPLIX_SRCS := $(filter-out $(SPLIX)/src/pstoqpdl.cpp,$(wildcard $(SPLIX)/src/*.cpp))
JBIG_SRCS  := $(JBIG)/jbig85.c $(JBIG)/jbig_ar.c
OBJS       := $(patsubst $(SPLIX)/src/%.cpp,$(BUILD)/obj/%.o,$(SPLIX_SRCS)) \
              $(patsubst $(JBIG)/%.c,$(BUILD)/obj/%.o,$(JBIG_SRCS))

all: $(BUILD)/rastertoqpdl

$(BUILD)/obj/%.o: $(SPLIX)/src/%.cpp
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(BUILD)/obj/%.o: $(JBIG)/%.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD)/rastertoqpdl: $(OBJS)
	$(CXX) $(LDFLAGS) $^ -o $@
	codesign --force --sign - --identifier org.splix.rastertoqpdl $@

clean:
	rm -rf $(BUILD)

.PHONY: all clean
