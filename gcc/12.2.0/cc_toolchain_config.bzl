load("@rules_cc//cc/common:cc_common.bzl", "cc_common")
load("@bazel_tools//tools/build_defs/cc:action_names.bzl", "ACTION_NAMES")
load(
    "@bazel_tools//tools/cpp:cc_toolchain_config_lib.bzl",
    "action_config",
    "feature",
    "flag_set",
    "flag_group",
    "with_feature_set",
)
load("@bazel_tools//tools/cpp:cc_toolchain_config_lib.bzl", "tool_path")

LINK_FLAGS = [
    "-lstdc++",
    "-lm",
    "-lpthread",
    "-pthread",
    "-ldl",
    "-lrt",
    "-static-libgcc",
    "-static-libstdc++",
]

COMP_FLAGS = [                           
    "-c",
    "-m64", # all compile actions
    "-Wall", # all compile actions
    "-Wno-error=deprecated-declarations", # all compile actions
    "-Wextra", # all compile actions
    "-Wpedantic", # all compile actions
]

DBG_COMPILE_FLAGS = COMP_FLAGS + [
    "-Og", # all compile actions with feature dbg
    "-g3", # all compile actions with feature dbg
]

OPT_COMPILE_FLAGS = COMP_FLAGS + [
    "-O2", # all compile actions with feature opt
    "-DNDEBUG", # all compile actions with feature opt
]

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

all_c_compile_actions = [
    ACTION_NAMES.c_compile,
]

all_cpp_compile_actions = [
    ACTION_NAMES.cpp_compile,
]



def _impl(ctx):
    # features = [
    #   feature(
        #     ctx = ctx,
        #     cc_toolchain = cc_toolchain,
        #     requested_features = ctx.features,
        #     unsupported_features = ctx.disabled_features,
    # ),
    #]

    dbg_feature = feature(name = "dbg")
    opt_feature = feature(name = "opt")
    fastbuild_feature = feature(name = "fastbuild")


    link_features = [
        feature(
            name = "default_linker_flags",
            enabled = True,
            flag_sets = [
                flag_set(
                    actions = all_link_actions,
                    flag_groups = ([
                        flag_group(
                            flags = LINK_FLAGS,
                        ),
                    ]),
                ),
            ],
        ),
    ]

    supports_pic = [feature(
            name = "supports_pic",
            enabled = True,
        )
    ]

    comp_features = [
        feature(
            name = "default_compile_flags",
            enabled = True,
            flag_sets = [
                flag_set(
                    actions = all_compile_actions,
                    flag_groups = ([
                        flag_group(
                            flags = COMP_FLAGS,
                        ),
                    ]),
                ),
                flag_set(
                    actions = all_c_compile_actions,
                    flag_groups = [
                        flag_group(
                            flags = [
                                "-std=c11",
                            ],
                        ),
                    ],
                ),
                flag_set(
                    actions = all_cpp_compile_actions,
                    flag_groups = [
                        flag_group(
                            flags = [
                                "-std=c++17",
                            ],
                        ),
                    ],
                ),
                flag_set(
                    actions = all_compile_actions,
                    flag_groups = [
                        flag_group(
                            flags = DBG_COMPILE_FLAGS,
                        )
                    ],
                    with_features = [with_feature_set(features = ["dbg"])],
                ),
                flag_set(
                    actions = all_compile_actions,
                    flag_groups = [
                        flag_group(
                            flags = OPT_COMPILE_FLAGS,
                        )
                    ],
                    with_features = [with_feature_set(features = ["opt", "fastbuild"])],
                ),
            ],
        ),
    ]

    

    # compile_action_config = cc_common.create_action_config(
    #     action_name = "cpp-compile",
    #     tools = [ctx.executable._gcc_exe],
    #     # Define default flags
    #     flag_sets = [
    #         cc_common.create_flag_set(
    #             flag_groups = [{
    #                 "flags": ["-O2", 
    #                             "-c",
    #                             "-m64", # all compile actions
    #                             "-std=c++17", # all cpp compile actions
    #                             "-std=c11", # all c compile actions
    #                             "-Og", # all compile actions with feature dbg
    #                             "-g3", # all compile actions with feature dbg
    #                             "-O2", # all compile actions with feature opt
    #                             "-DNDEBUG", # all compile actions with feature opt
    #                             "-Wall", # all compile actions
    #                             "-Wno-error=deprecated-declarations", # all compile actions
    #                             "-Wextra", # all compile actions
    #                             "-Wpedantic", # all compile actions
    #                 ],
    #             }]
    #         )
    #     ],
    # )

    # actions = all_compile_actions + all_link_actions

    tool_paths = [
        tool_path(
            name = "gcc",
            path = "/usr/bin/gcc",
        ),
        tool_path(
            name = "ld",
            path = "/usr/bin/ld",
        ),
        tool_path(
            name = "ar",
            path = "/usr/bin/ar",
        ),
        tool_path(
            name = "cpp",
            path = "/bin/false",
        ),
        tool_path(
            name = "gcov",
            path = "/bin/false",
        ),
        tool_path(
            name = "nm",
            path = "/bin/false",
        ),
        tool_path(
            name = "objdump",
            path = "/bin/false",
        ),
        tool_path(
            name = "strip",
            path = "/bin/false",
        ),
    ]
    
    cc_toolchain_cfg_info = cc_common.create_cc_toolchain_config_info(
        ctx=ctx,
        toolchain_identifier = "local",
        features = link_features + supports_pic + comp_features,
        # action_configs = actions,
        cxx_builtin_include_directories = [
            "/usr/include",
            "usr/lib/gcc/x86_64-linux-gnu/11/include",
            "/usr/lib/gcc/x86_64-linux-gnu/11/include/stddef.h",
            "/usr/lib/gcc/x86_64-linux-gnu/11/include/stdarg.h",
            "/usr/lib/gcc/x86_64-linux-gnu/11/include/stdint.h",
            #include paths for gcc 12.2.0
            "/usr/lib/gcc/x86_64-linux-gnu/12/include",
            "/usr/lib/gcc/x86_64-linux-gnu/12/include-fixed",
        ],
        host_system_name = "local",
        target_system_name = "local",
        target_cpu = "k8",
        target_libc = "unknown",
        abi_version = "unknown",
        abi_libc_version = "unknown",     
        compiler = "gcc",
        tool_paths = tool_paths,

    )
    
    return cc_toolchain_cfg_info

cc_toolchain_config = rule(
    implementation = _impl,
    attrs = {
        # "_gcc_exe": attr.label(
        #     default = Label("//gcc/tools:gcc_exe"),
        #     executable = True,
        #     cfg = "exec",
        # ),
    },
    provides = [CcToolchainConfigInfo],
)
