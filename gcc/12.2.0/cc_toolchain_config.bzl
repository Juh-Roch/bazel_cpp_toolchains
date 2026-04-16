load("@rules_cc//cc/common:cc_common.bzl", "cc_common")
load("@bazel_tools//tools/build_defs/cc:action_names.bzl", "ACTION_NAMES")
load(
    "@bazel_tools//tools/cpp:cc_toolchain_config_lib.bzl",
    "feature",
    "flag_set",
    "flag_group",
)
load("@bazel_tools//tools/cpp:cc_toolchain_config_lib.bzl", "tool_path")

all_link_actions = [
    ACTION_NAMES.cpp_link_executable,
    ACTION_NAMES.cpp_link_dynamic_library,
    ACTION_NAMES.cpp_link_nodeps_dynamic_library,
    ACTION_NAMES.cpp_link_static_library,
]


def _impl(ctx): 
    
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
    features = [
        feature(
            name = "default_linker_flags",
            enabled = True,
            flag_sets = [
                flag_set(
                    actions = all_link_actions,
                    flag_groups = ([
                        flag_group(
                            flags = [
                                "-lstdc++",
                            ],
                        ),
                    ]),
                ),
            ],
        ),
    ]
    cc_toolchain_cfg_info = cc_common.create_cc_toolchain_config_info(
        ctx=ctx,
        toolchain_identifier = "local",
        features = features,
        cxx_builtin_include_directories = [
            "/usr/include",
            "usr/lib/gcc/x86_64-linux-gnu/11/include",
            #if you simply run the:
                # bazelisk build //main:hello_world
            #it will give you the paths bellow:
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

    #no need for this, because the output of the create_cc_toolchain_config_info is already a CcToolchainConfigInfo, so we can return it directly
    # cctoolchainconfig = CcToolchainConfigInfo(
      
    # ),
    
    return cc_toolchain_cfg_info

cc_toolchain_config = rule(
    implementation = _impl,
    attrs = {},
    provides = [CcToolchainConfigInfo],
)
