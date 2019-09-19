# BroadcastableStructs

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://tkf.github.io/BroadcastableStructs.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://tkf.github.io/BroadcastableStructs.jl/dev)
[![Build Status](https://travis-ci.com/tkf/BroadcastableStructs.jl.svg?branch=master)](https://travis-ci.com/tkf/BroadcastableStructs.jl)
[![Codecov](https://codecov.io/gh/tkf/BroadcastableStructs.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/tkf/BroadcastableStructs.jl)
[![Coveralls](https://coveralls.io/repos/github/tkf/BroadcastableStructs.jl/badge.svg?branch=master)](https://coveralls.io/github/tkf/BroadcastableStructs.jl?branch=master)

BroadcastableStructs.jl provides an easy way to create a `struct`
which can be broadcasted as an argument (`BroadcastableStruct`) and
also as a callable (`BroadcastableCallable`).  `BroadcastableCallable`
supports efficient differentiation with
[Zygote.jl](https://github.com/FluxML/Zygote.jl) when combined with
[ChainCutters.jl](https://github.com/tkf/ChainCutters.jl).

`BroadcastableStruct` is an efficient way to treat struct-of-arrays as
array-of-structs within broadcasting expressions without actually
constructing the array.

```julia
julia> using BroadcastableStructs: BroadcastableStruct

julia> struct Point2D{TX, TY} <: BroadcastableStruct
           x::TX
           y::TY
       end

julia> dist(p::Point2D, q::Point2D) = sum(abs(p.x - q.x) + abs(p.y - q.y));

julia> p = Point2D(1:2, 3:4)
Point2D{UnitRange{Int64},UnitRange{Int64}}(1:2, 3:4)

julia> q = Point2D(5, 6)
Point2D{Int64,Int64}(5, 6)

julia> dist.(p, q)
2-element Array{Int64,1}:
 7
 5
```

`BroadcastableCallable` can be used to create a callable object that
is broadcasted over its _parameters_ as well as arguments.

```julia
julia> using BroadcastableStructs: BroadcastableCallable

julia> struct WeightedAdd{A, B} <: BroadcastableCallable
           a::A
           b::B
       end

julia> (f::WeightedAdd)(x, y) = f.a * x + f.b * y;

julia> WeightedAdd(1, 2)(3, 4)
11

julia> f = WeightedAdd(1:2, 3)
WeightedAdd{UnitRange{Int64},Int64}(1:2, 3)

julia> f.(4:5, 6)
2-element Array{Int64,1}:
 22
 28
```
