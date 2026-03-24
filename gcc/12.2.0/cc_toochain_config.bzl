load("@rules_cc//cc/common:cc_common.bzl", "cc_common")
load("@bazel_tools//tools/build_defs/cc:action_names.bzl", "ACTION_NAMES")
load(
    "@bazel_tools//tools/cpp:cc_toolchain_config_lib.bzl",
    "action_config",
    "feature",
    "flag_group",
)

all_link_actions = [
    ACTION_NAMES.cpp_link_executable,
    ACTION_NAMES.cpp_link_dynamic_library,
    ACTION_NAMES.cpp_link_nodeps_dynamic_library,
    ACTION_NAMES.cpp_link_static_library,
]

all_compile_actions = [
    ACTION_NAMES.linkstamp_compile,
    ACTION_NAMES.cpp_compile,
    ACTION_NAMES.cpp_header_parsing,
    ACTION_NAMES.cpp_module_compile,
    ACTION_NAMES.cpp_module_codegen,
    ACTION_NAMES.lto_backend,
    ACTION_NAMES.clif_match,
    ACTION_NAMES.objcpp_compile,
]

all_assemble_actions = [
    ACTION_NAMES.preprocess_assemble,
    ACTION_NAMES.assemble,
]

def _impl(ctx): 
    features = feature(
        ctx = ctx,
        cc_toolchain = cc_toolchain,
        requested_features = ctx.features,
        unsupported_features = ctx.disabled_features,
    )

    dbg_feature = feature(name = "dbg")
    opt_feature = feature(name = "opt")

    compile_action_config = cc_common.create_action_config(
        action_name = "cpp-compile",
        tools = [ctx.executable._gcc_exe],
        # Define default flags
        flag_sets = [
            cc_common.create_flag_set(
                flag_groups = [{
                    "flags": ["-O2", 
                                "-c",
                                "-m64", # all compile actions
                                "-std=c++17", # all cpp compile actions
                                "-std=c11", # all c compile actions
                                "-Og", # all compile actions with feature dbg
                                "-g3", # all compile actions with feature dbg
                                "-O2", # all compile actions with feature opt
                                "-DNDEBUG", # all compile actions with feature opt
                                "-Wall", # all compile actions
                                "-Wno-error=deprecated-declarations", # all compile actions
                                "-Wextra", # all compile actions
                                "-Wpedantic", # all compile actions
                    ],
                }]
            )
        ],
    )

    actions = all_compile_actions + all_link_actions
    cc_toolchain_cfg_info = cc_common.create_cc_toolchain_config_info(
        ctx=ctx,
        toolchain_identifier = "cc-homemade-toolchain",
        features = [dbg_feature + opt_feature],
        action_configs = actions,
    )

    # cctoolchainconfig = CcToolchainConfigInfo(
      
    # ),
    
    return [cc_toolchain_cfg_info]

cc_toolchain_config = rule(
    implementation = _impl,
    attrs = {
        "_gcc_exe": attr.label(
            default = Label("//gcc/tools:gcc_exe"),
            executable = True,
            cfg = "exec",
        ),
    },
    provides = [CcToolchainConfigInfo],
)
