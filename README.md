# StrideArraysCore

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://chriselrod.github.io/StrideArraysCore.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://chriselrod.github.io/StrideArraysCore.jl/dev)
[![Build Status](https://github.com/chriselrod/StrideArraysCore.jl/workflows/CI/badge.svg)](https://github.com/chriselrod/StrideArraysCore.jl/actions)
[![Coverage](https://codecov.io/gh/chriselrod/StrideArraysCore.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/chriselrod/StrideArraysCore.jl)


Defines the core `PtrArray` type so that some libraries can make use of it internally wihout the need for cicular dependencies. [StrideArrays](https://github.com/chriselrod/StrideArrays.jl) extends this type with many methods and functionality. It is recommended you depend on and use `StrideArrays` instead.

