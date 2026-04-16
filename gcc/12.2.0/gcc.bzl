# load("//gcc/common/private/actions:assemble.bzl", "emit_assemble")
# load("//gcc/common/private/actions:c_compile.bzl", "emit_c_compile")
# load("//gcc/common/private/actions:cpp_compile.bzl", "emit_cpp_compile")
# load("//gcc/common/private/actions:cpp_link_dynamic_library.bzl", "emit_cpp_link_dynamic_library")
# load("//gcc/common/private/actions:cpp_link_executable.bzl", "emit_cpp_link_executable")
# load("//gcc/common/private/actions:cpp_link_nodeps_dynamic_library.bzl", "emit_cpp_link_nodeps_dynamic_library")
# load("//gcc/common/private/actions:cpp_link_static_library.bzl", "emit_cpp_link_static_library")
# load("//gcc/common/private/actions:preprocess_assemble.bzl", "emit_preprocess_assemble")
# load("//gcc/common/private/actions:strip_action.bzl", "emit_strip_action")
# def _gcc1_toolchain_impl(ctx):
#     toolchain_info = platform_common.ToolchainInfo(
#         gcc1info = Gcc1Info(
#             # Public fields
#             name = ctx.label.name,
#             cross_compile = cross_compile,
#             default_gccos = ctx.attr.gccos,
#             default_gccarch = ctx.attr.gccarch,
#             actions = struct(
#                 assemble_action = emit_assemble,
#                 c_compile_action = emit_c_compile,
#                 cpp_compile_action = emit_cpp_compile,
#                 cpp_link_dynamic_library_action = emit_cpp_link_dynamic_library,
#                 cpp_link_executable_action = emit_cpp_link_executable,
#                 cpp_link_nodeps_dynamic_library_action = emit_cpp_link_nodeps_dynamic_library,
#                 cpp_link_static_library_action = emit_cpp_link_static_library,
#                 preprocess_assemble_action = emit_preprocess_assemble,
#                 strip_action = emit_strip_action,
#             ),
#             flags = struct(
#                 compile = (),
#                 link = ctx.attr.link_flags,
#                 link_cgo = ctx.attr.cgo_link_flags,
#             ),
#             # Internal fields -- may be read by emit functions.
#             _builder = ctx.executable._gcc_exe,
#             # _pack = ctx.executable.pack,
#             # compiler_path = ctx.attr.compiler_path,
#             # system_lib = ctx.attr.system_lib,
#             # arch_flags = ctx.attr.arch_flags,
#         ),
#     )
#     return [toolchain_info]

# gcc1_toolchain = rule(
#     implementation = _gcc1_toolchain_impl,
#     attrs = {
#         "compiler": attr.label(
#             executable = True,
#             mandatory = True,
#             cfg = "exec",
#         ),
#         # "system_lib": attr.label(
#         #     mandatory = True,
#         #     cfg = "target",
#         # ),
#         "arch_flags": attr.string_list(),
#     },
# )
