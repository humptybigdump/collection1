import finn.builder.build_dataflow as build
import finn.builder.build_dataflow_config as build_cfg
from finn.util.basic import alveo_default_platform
import os
import shutil


# the BNN-PYNQ models -- these all come as exported .onnx models
# Uncomment the ones that you want to generate bitstreams for (we recommend only using one at a time) 
models = [
    # TODO: ADD YOUR MODEL,
]

# which platforms to build the networks for
zynq_platforms = ["Pynq-Z2"]
platforms_to_build = zynq_platforms


# determine which shell flow to use for a given platform
def platform_to_shell(platform):
    if platform in zynq_platforms:
        return build_cfg.ShellFlowType.VIVADO_ZYNQ
    else:
        raise Exception("Unknown platform, can't determine ShellFlowType")


# create a release dir, used for finn-examples release packaging
os.makedirs("release", exist_ok=True)

for platform_name in platforms_to_build:
    shell_flow_type = platform_to_shell(platform_name)
    if shell_flow_type == build_cfg.ShellFlowType.VITIS_ALVEO:
        vitis_platform = alveo_default_platform[platform_name]
        # for Alveo, use the Vitis platform name as the release name
        # e.g. xilinx_u250_xdma_201830_2
        release_platform_name = vitis_platform
    else:
        vitis_platform = None
        # for Zynq, use the board name as the release name
        # e.g. ZCU104
        release_platform_name = platform_name
    platform_dir = "release/%s" % release_platform_name
    os.makedirs(platform_dir, exist_ok=True)
    for model_name in models:
        # set up the build configuration for this model
        cfg = build_cfg.DataflowBuildConfig(
            output_dir="output_%s_%s" % (model_name, release_platform_name),            # Output directory
            #folding_config_file="folding_config/%s_folding_config.json" % model_name,   # Path to the folding configuration
            target_fps=0,                                                              # Instead of manual configuration you can specify target fps for the given clock period. Comment folding config when using this
            synth_clk_period_ns=10.0,                                                   # Clock period in nanoseconds --> Calculate the clock frequency from this
            board=platform_name,
            shell_flow_type=shell_flow_type,
            vitis_platform=vitis_platform,
            generate_outputs=[build_cfg.DataflowOutputType.BITFILE,                     # These lines determine which outputs we want to generate
                              build_cfg.DataflowOutputType.PYNQ_DRIVER,                 # Bitfile and pynq_driver are always required for us. Do not remove them
                              build_cfg.DataflowOutputType.ESTIMATE_REPORTS,            # Estimation and performance reports
                              #build_cfg.DataflowOutputType.RTLSIM_PERFORMANCE,          # RTLSIM_PERFORMANCE can take very long, so you can comment this when testing
                              ],         
            save_intermediate_models=True,
        )
        model_file = "models/%s.onnx" % model_name
        # launch FINN compiler to build
        build.build_dataflow_cfg(model_file, cfg)
        # copy bitfiles into release dir if found
        bitfile_gen_dir = cfg.output_dir + "/bitfile"
        files_to_check_and_copy = [
            "finn-accel.bit",
            "finn-accel.hwh",
            "finn-accel.xclbin",
        ]
        for f in files_to_check_and_copy:
            src_file = bitfile_gen_dir + "/" + f
            dst_file = platform_dir + "/" + f.replace("finn-accel", model_name)
            if os.path.isfile(src_file):
                shutil.copy(src_file, dst_file)
