##==============================================================================
## [Filename]       project.mk
## [Project]        -
## [Author]         Ciro Bermudez - cirofabian.bermudez@gmail.com
## [Language]       GNU Makefile
## [Created]        -
## [Modified]       -
## [Description]    Directed project
## [Notes]          -
## [Status]         stable
## [Revisions]      -
##==============================================================================

# ================================ DIRECTORIES =================================
# Project paths and directory hierarchy

GIT_DIR       := $(shell git rev-parse --show-toplevel)
TB_DIR        ?= $(GIT_DIR)/verification/directed
COMMON_MK_DIR := $(GIT_DIR)/verification/common/mk

# =============================== CONFIGURATION ================================
# Project-specific defaults

# -------------------------------- COMPILE-TIME --------------------------------

# TIMESCALE               ?= 1ps/100fs
# ENABLE_UVM              ?= false
# UVM_VERSION             ?= 1.2
ENABLE_DEBUG_DB         ?= true
DEFINES                 ?=
# COMPILE_ARGS            ?=
SIMV_NAME               ?= simv2
ENABLE_CODE_COV_COMPILE ?= true
CODE_COV_TYPES_COMPILE  ?= line+cond+tgl+assert
ENABLE_SVA_COMPILE      ?= true
UVCS_FILELIST           ?=
# Auto-link the shared lib built by `make build-dpi` (verification/common/dpi/lib/libdpi.so).
# -sv_lib drops the lib/.so around DPI_LIB_NAME; -sv_root is the search dir.
# Compile-time only: VCS bakes this into simv2, so no flag is needed again at run time.
DPI_FILE                ?= -sv_lib dpi -sv_root $(GIT_DIR)/verification/common/dpi/lib

# ---------------------------------- RUN-TIME ----------------------------------

# TEST                      ?= top_test
# VERBOSITY                 ?= UVM_MEDIUM
# SEED_MODE                 ?= fixed
# SEED                      ?= 5081996
ENABLE_UVM_RECORDING      ?= false
ENABLE_CODE_COV_RUN       ?= true
CODE_COV_TYPES_RUN        ?= line+cond+tgl+assert
ENABLE_SVA_RUN            ?= true
DUMP_MODE                 ?= default
JOB_NAME                  ?= miguel_test
RUN_ARGS                  ?=

# ---------------------- PARAMETRIC WIDTH OVERRIDE (PAR-001) --------------------
# TC-PAR-01..03 require separate builds for W=8/16/32. Each width must land in
# its own SIMV_NAME/JOB_NAME, otherwise the next `make compile` overwrites the
# previous width's BUILD_COV_DB before it gets merged (see cov.mk header note).
#
# Usage:
#   make compile FIB_W=8  && make sim FIB_W=8
#   make compile FIB_W=16 && make sim FIB_W=16
#   make compile FIB_W=32 && make sim FIB_W=32
#
# NOTE: verify the -pvalue+<pkg>::<param>=<val> separator against your VCS
# version's docs (some releases expect '.' instead of '::'). If it errors,
# override config_pkg::FibW by hand for that build instead.
FIB_W ?=
ifneq ($(strip $(FIB_W)),)
  COMPILE_ARGS += -pvalue+config_pkg::FibW=$(FIB_W)
  SIMV_NAME     = simv2_w$(FIB_W)
  JOB_NAME      = miguel_test_w$(FIB_W)
endif

# ================================== INCLUDES ==================================

# Main framework
include $(COMMON_MK_DIR)/common.mk

# DPI
-include $(COMMON_MK_DIR)/dpi.mk

# Coverage
-include $(COMMON_MK_DIR)/cov.mk

# Regression Manager
# -include $(MK_DIR)/regression.mk

# ================================= HELP MENU ==================================

.PHONY: help
help: ## COMMON: Displays help message
	@printf "%s\n" "================================================================================"
	@printf "%s\n" "                                    PROJECT.MK                                  "
	@printf "%s\n" "================================================================================"
	@printf "%s\n" "Usage: make <target> [variables]"
	@printf "%s\n" "------------------------------------ TARGETS -----------------------------------"
	@grep -h -E '^help-[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "- make $(C_CYN)%-15s$(C_RST) %s\n", $$1, $$2}'
	@printf "%s\n" "================================================================================"
