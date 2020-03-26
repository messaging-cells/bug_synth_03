

PRJ_NM = bug_03

BUILD_DIR = build
PRJ_PREFIX = ${BUILD_DIR}/${PRJ_NM}

YOSYS_EXE = yosys
NEXTPNR_EXE = nextpnr-ice40
ICEPACK_EXE = icepack
ICEPROG_EXE = iceprog

RTL_DIR = rtl
CHECK_DIR = ck_formal

RTL_FILES = \
	${RTL_DIR}/bin_to_disp.v \
	${RTL_DIR}/debouncer.v \
	${RTL_DIR}/hglobal.v \
	${RTL_DIR}/nd_bug_03.v \
	${RTL_DIR}/io_bug_03.v \
	${RTL_DIR}/${PRJ_NM}.v \
	
export BUILD_DIR
	
.PHONY: all
all: ${PRJ_PREFIX}.bin
	@echo "Finished building "${PRJ_PREFIX}.bin

${PRJ_PREFIX}.bin : ${PRJ_PREFIX}.asc
	${ICEPACK_EXE} ${PRJ_PREFIX}.asc ${PRJ_PREFIX}.bin

${PRJ_PREFIX}.asc : ${PRJ_PREFIX}.json
	rm ${BUILD_DIR}/route.log; \
	${NEXTPNR_EXE} -q --hx1k --package vq100 --json ${PRJ_PREFIX}.json \
		--pcf GO_BOARD.pcf --asc ${PRJ_PREFIX}.asc -l ${BUILD_DIR}/route.log


${PRJ_PREFIX}.json : ${RTL_FILES}
	mkdir -p ${BUILD_DIR}; rm ${BUILD_DIR}/synth.log; rm ${PRJ_PREFIX}.json; rm ${PRJ_PREFIX}.blif; cd ${RTL_DIR}; \
	${YOSYS_EXE} -q synth.tcl -l ../${BUILD_DIR}/synth.log

.PHONY: prog
prog:
	sudo ${ICEPROG_EXE} -b ${PRJ_PREFIX}.bin
	

.PHONY: check
check:
	cd ${CHECK_DIR}; sby -f hproto_CK.sby

# sby -f proto_CK.sby
