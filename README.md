# bazel_cpp_toolchains

# 7. Introduce Hermetic Host Toolchain (GCC 12.2) as Bazel Module 🔵 Advanced (~2-3 hours)

## 🏆 Goal

In this exercise, you will hermetically pin a host C++ toolchain (GCC 12.2), package it as a Bazel module, and consume it from your project through your custom Bazel registry.

This replaces the system compiler with a fully reproducible, isolated toolchain, ensuring that everyone (local dev, CI runners, remote executors) uses exactly the same compiler binary, flags, and sysroot.

This is a key foundation for:
* Deterministic builds
* Reproducible CI/CD
* Multi-platform support
* Later toolchains (QNX8, Android)

> NOTE: The toolchain package is already provided and it's localted on project called S-CORE. Link to package: [x86_64-unknown-linux-gnu_gcc12.tar.gz](https://github.com/eclipse-score/toolchains_gcc_packages/releases/download/0.0.1/x86_64-unknown-linux-gnu_gcc12.tar.gz)

## 📘 Context

You already built:
* A custom registry
* A module for platform definitions (`build_athina_bazel_platforms`)

Now you will create:
* A Bazel module named `build_athena_bazel_cpp_toolchains`
that ships:
    * GCC 12.2 binaries (hermetic)
    * Correct cc_toolchain_config

And you will import it into your main project via:
```python
bazel_dep(name = "build_athena_bazel_cpp_toolchains", version = "1.0.0")
```

## 🧪 Why this matters

Because Bazel never guarantees what system compiler is used.
If you rely on /usr/bin/gcc, you cannot reproduce:

* CI buildsw
* Developer builds
* Remote execution builds
* Cross-platform results

Hermetic toolchains solve all of this.

## 🧩 Step 1 - Create a new Bazel module `build_athena_bazel_cpp_toolchains`

Your folder structure inside your GCC module repo should look like:
```bash
<repo_root>/
├── gcc/
│   ├── common/
│   │   ├── extention/
│   │   │   ├── BUILD
│   │   │   └── gcc.bzl
│   │   ├── rules/
│   │   │   ├── BUILD
│   │   │   └── gcc.bzl
│   ├── 8.0.0/
│   │   ├── cc_toolchain_config.bzl
│   │   ├── BUILD
│   │   └── gcc.BUILD
│   └── 12.2.0/
│       ├── cc_toolchain_config.bzl
│       ├── BUILD
│       └── gcc.BUILD
├── llvm/
│   └── .keep
├── tests/
│   ├── .bazelrc
│   ├── .bazelversion
│   ├── BUILD
│   ├── MODULE.bazel
│   ├── main.cpp
│   └── main_pthread .cpp
├── BUILD.bazel
└── MODULE.bazel
```

## 🧩 Step 2 - Write the GCC toolchain BUILD file
In this step you need to provide definition of your toolchain. For that we use rule called `toolchain()`. This rule will implement your toolchain target. For example:

```python
toolchain(
    name = "host_gcc12",
     exec_compatible_with = [
        # !!! FILL IN  !!!
        # constraints where this toolchain can be run
     ],
    target_compatible_with = [
        # !!! FILL IN  !!!
        # constraints for which this toolchain produce the binaries
    ],
    toolchain = # !!! FILL IN  !!! , # target where configuration is made 
    toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
    visibility = [
        "//:__pkg__",
    ],    
)
```
Next to `toolchain()` rule, you need to instatiate toolchain configuration target. This target will define which actions, features and binaries your toolchain is using. For that we use `cc_toolchain()` rule.

```python
cc_toolchain(
    name = "cc_toolchain",
    . # !!! FILL IN  !!! 
    . # !!! FILL IN  !!! 
    . # !!! FILL IN  !!! 
)
```
And the last rule of them all is `cc_toolchain_config()`. This rule defines the target which tells Bazel how to orchestrate cross-compiling actions.

```python
cc_toolchain_config(
    name = "cc_toolchain_config",
    . # !!! FILL IN  !!! 
    . # !!! FILL IN  !!! 
    . # !!! FILL IN  !!! 
)
```
> NOTE: This targets expose all GCC binaries in sandbox, meaning if they are not present in this target definitions, then Bazel will not put the tools (binaries) in sandbox.

## 🧩 Step 3 — Implement toolchain config
To implement toolchain config, we must setup a custom rule in `cc_toolchain_config.bzl` which will return provider `CcToolchainConfigInfo`. The fields that this provider holds must be set (look into Bazel documentation).

The following `action_configs` needs to be set:
* `assemble_action`,
* `c_compile_action`,
* `cpp_compile_action`,
* `cpp_link_dynamic_library_action`,
* `cpp_link_executable_action`,
* `cpp_link_nodeps_dynamic_library_action`,
* `cpp_link_static_library_action`,
* `preprocess_assemble_action`,
* `strip_action`,

The following features need to be set in the toolchain:

* `unfiltered_compile_flags`:
    * `"-D__DATE__=\"redacted\""`, # all compile actions
    * `"-D__TIMESTAMP__=\"redacted\""`, # all compile actions
    * `"-D__TIME__=\"redacted\""`, # all compile actions
    * `"-Wno-builtin-macro-redefined"`, # all compile actions
    * `"-no-canonical-prefixes"`, # all compile actions
    * `"-fno-canonical-system-headers"`, # all compile actions
* `default_compile_flags`:
    * `"-m64"`, # all compile actions
    * `"-std=c++17"`, # all cpp compile actions
    * `"-std=c11"`, # all c compile actions
    * `"-Og"`, # all compile actions with feature `dbg`
    * `"-g3"`, # all compile actions with feature `dbg`
    * `"-O2"`, # all compile actions with feature `opt`
    * `"-DNDEBUG"`, # all compile actions with feature `opt`
    * `"-Wall"`, # all compile actions
    * `"-Wno-error=deprecated-declarations"`, # all compile actions
    * `"-Wextra"`, # all compile actions
    * `"-Wpedantic"`, # all compile actions
* `default_link_flags`:
    * `"-lm"`, # all link actions
    * `"-ldl"`, # all link actions
    * `"-lrt"`, # all link actions
    * `"-static-libstdc++"`, # all link actions
    * `"-static-libgcc"`, # all link actions
* `supports_pic`, # all link actions
* `use_pthread`:
    * `"-pthread"`, # all link actions
      

## 🧩 Step 4 — Implement module extention for GCC toolchain
The module extention will allow to setup necessary information in the toolchain module over public interface. The following options should be supported:
* gcc_version, # in format `8.0.0` & `12.2.0`.
* gcc_package, # standalone package that holds all binaries and sysroot of toolchain.
    * url
    * strip_prefix
    * sha256
* extra_flags, # (optional) if you want to extend toolchain with open features, but please make sure your configuration supports this.

## 🧩 Step 5 — Implement repository rule
Repository rule server to setup toolchain in desired workspace, where `rctx.template` is used to provide information about the toolchain (use `rules/gcc.bzl`).

## 🧩 Step 6 — Test your toolchain
Now you need to test your toolchain before you made release in the registry. The source files are already provided, all you have to do is to set bazel files to execute test.
> NOTE: Since your toolchain module is still not published to the registry, use `local_path_override` rule to point where your module implementation is located.

## 🧩 Step 7 — Publish module to registry
By now you should be familiar with this step (look exercise 6). Follow the same rules and release this module to Build ATHENA Bazel Registry (your copy).

## 🧩 Step 8 — Use it in your main project
Try out your new toolchain by introducing it inside `MODULE.bazel` file (similar step what you already did in step 6).

## 🧠 Takeaway

By completing this exercise you learned:
* How to package a complete C++ toolchain as a Bazel module
* How to register and consume that toolchain through a custom registry
* How to configure Bazel to use hermetic toolchains
* How to ensure deterministic builds across all computers
* How Bazel’s cc_toolchain_config works internally
* How real companies organize internal toolchains
