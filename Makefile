PROJECT_NAME=$(PROJECT_NAME)
COMMAND=$(COMMAND)

create:
        vivado -mode batch -source compile_SPI.tcl -tclargs -command create -project_name $(PROJECT_NAME)
        rm *.log
        rm *.jou
compile:
        SRC_DIR=$(SRC_DIR)
        TOP_MODULE=$(TOP_MODULE)
        echo "Sourcing from $(SRC_DIR)"
        echo "Top Module is $(TOP_MODULE)"
        vivado -mode batch -source compile_SPI.tcl -tclargs -command compile -top_module $(TOP_MODULE) -project_name $(PROJECT_NAME) -src_dir $(SRC_DIR)
        rm *.log
        rm *.jou
simulate:
        SRC_DIR=$(SRC_DIR)
        TOP_MODULE=$(TOP_MODULE)
        echo "Sourcing from $(SRC_DIR)"
        echo "Top Module is $(TOP_MODULE)"
        vivado -mode batch -source compile_SPI.tcl -tclargs -command simulate -top_module $(TOP_MODULE) -project_name $(PROJECT_NAME) -src_dir $(SRC_DIR)
        rm *.log
        rm *.jou
program:
        TOP_MODULE=$(TOP_MODULE)
        echo "Top Module is $(TOP_MODULE)"
        vivado -mode batch -source compile_SPI.tcl -tclargs -command program -top_module $(TOP_MODULE) -project_name $(PROJECT_NAME)
        rm *.log
        rm *.jou

