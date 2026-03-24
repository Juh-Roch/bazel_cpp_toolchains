###
# PLEASE READ https://bazel.build/versions/8.0.0/tutorials/ccp-toolchain-config
###
load("//gcc/12.2.0:cc_toochain_config.bzl", "cc_toolchain_config")
# load("//gcc/common/rules:gcc.bzl", "gcc1_toolchain")
# gcc1_toolchain(
#     name = "gcc1_linux",
#     arch_flags = [
#         "--arch=Linux",
#         "--debug_everything",
#     ],
#     compiler_path = "/path/to/gcc/on/linux", #-> here i guess goes the .tar he provided
#     # system_lib = "/usr/lib/libgcc.so",
# )

# gcc1_toolchain(
#     name = "gcc1_windows",
#     arch_flags = [
#         "--arch=Windows",
#         # Different flags, no debug support on windows.
#     ],
#     compiler_path = "C:\\path\\on\\windows\\gcc.exe",
#     # system_lib = "C:\\path\\on\\windows\\gcc.dll",
# )

cc_toolchain(
    name = "cc_toolchain",
    toolchain_identifier = "linux_x86_64-toolchain",
    toolchain_config = ":linux_x86_64_toolchain_config",
    all_files = ":empty",
    compiler_files = ":empty",
    dwp_files = ":empty",
    linker_files = ":empty",
    objcopy_files = ":empty",
    strip_files = ":empty",
    supports_param_files = 0,
)

cc_toolchain_config(
    name = "linux_x86_64_toolchain_config",
)

toolchain(
    name = "gcc1_linux_toolchain",
    exec_compatible_with = [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
    ],
    target_compatible_with = [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
    ],
    toolchain = ":cc_toolchain",
    toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
    visibility = [
        "//:__pkg__",
    ],  
)

# toolchain(
#     name = "gcc1_windows_toolchain",
#     exec_compatible_with = [
#         "@platforms//os:windows",
#         "@platforms//cpu:x86_64",
#     ],
#     target_compatible_with = [
#         "@platforms//os:windows",
#         "@platforms//cpu:x86_64",
#     ],
#     toolchain = ":cc_toolchain_windows",
#     toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
#     visibility = [
#         "//:__pkg__",
#     ],  
# )
