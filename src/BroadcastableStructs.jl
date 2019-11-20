module BroadcastableStructs

# Use README as the docstring of the module:
@doc let path = joinpath(dirname(@__DIR__), "README.md")
    include_dependency(path)
    replace(read(path, String), r"^```julia"m => "```jldoctest README")
end BroadcastableStructs

export BroadcastableStruct, BroadcastableCallable

import Setfield
using ZygoteRules: @adjoint

const constructorof = try
    Setfield.constructorof
catch
    Setfield.constructor_of
end

@inline foldlargs(op, x) = x
@inline foldlargs(op, x1, x2, xs...) = foldlargs(op, op(x1, x2), xs...)
# Unroll by hand (optimization):
@inline foldlargs(op, x1, x2) = op(x1, x2)
@inline foldlargs(op, x1, x2, x3) = op(op(x1, x2), x3)
@inline foldlargs(op, x1, x2, x3, x4) = op(op(op(x1, x2), x3), x4)
@inline foldlargs(op, x1, x2, x3, x4, x5) = op(op(op(op(x1, x2), x3), x4), x5)
@inline foldlargs(op, x1, x2, x3, x4, x5, x6) = op(op(op(op(op(x1, x2), x3), x4), x5), x6)
@inline foldlargs(op, x1, x2, x3, x4, x5, x6, x7) =
    op(op(op(op(op(op(x1, x2), x3), x4), x5), x6), x7)
@inline foldlargs(op, x1, x2, x3, x4, x5, x6, x7, x8) =
    op(op(op(op(op(op(op(x1, x2), x3), x4), x5), x6), x7), x8)
@inline foldlargs(op, x1, x2, x3, x4, x5, x6, x7, x8, x9) =
    op(op(op(op(op(op(op(op(x1, x2), x3), x4), x5), x6), x7), x8), x9)
@inline foldlargs(op, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10) =
    op(op(op(op(op(op(op(op(op(x1, x2), x3), x4), x5), x6), x7), x8), x9), x10)

abstract type BroadcastableStruct end

fieldvalues(obj) = ntuple(i -> getfield(obj, i), nfields(obj))

Broadcast.broadcastable(obj::BroadcastableStruct) =
    Broadcast.broadcasted(constructorof(typeof(obj)), fieldvalues(obj)...)

Base.ndims(T::Type{<:BroadcastableStruct}) =
    mapreduce(ndims, max, fieldtypes(T); init=0)

#=
Base.axes(obj::BroadcastableStruct) = axes(Broadcast.broadcastable(obj))
Base.length(obj::BroadcastableStruct) = prod(length.(axes(obj)))

Base.getindex(obj::BroadcastableStruct, i::Int...) =
    Broadcast.broadcastable(obj)[i...]
=#

abstract type BroadcastableCallable <: BroadcastableStruct end

@inline Broadcast.broadcasted(c::BroadcastableCallable, args...) =
    Broadcast.broadcasted(calling(c), deconstruct(c)..., args...)

@inline deconstruct(obj::T) where T =
    foldlargs((), fieldvalues(obj)...) do fields, x
        if x isa BroadcastableStruct
            (fields..., deconstruct(x)...)
        else
            (fields..., x)
        end
    end

struct StructSchema{Constructor, Fields} end
StructSchema(::Type{Constructor}, Fields::Tuple) where {Constructor} =
    StructSchema{Constructor, Fields}()

# Build a type-level tree reflecting the field locations of
# `BroadcastableStruct`s.
@inline function _structschema(obj::Constructor) where {Constructor}
    fields = foldlargs((), fieldvalues(obj)...) do fields, x
        if x isa BroadcastableStruct
            (fields..., _structschema(x))
        else
            (fields..., nothing)
        end
    end
    return StructSchema(Constructor, fields)
end

@inline _reconstruct(::Type{T}, fields) where T = constructorof(T)(fields...)

@inline reconstruct(f, obj::BroadcastableStruct, allargs...) =
    reconstruct(f, _structschema(obj), allargs...)

@inline function reconstruct(f::F, ::StructSchema{Constructor, Fields}, allargs...) where {F, Constructor, Fields}
    fields, args = foldlargs(((), allargs), Fields...) do (fields, allargs), x
        if x isa StructSchema
            y, rest = reconstruct(f, x, allargs...)
            ((fields..., y), rest)
        else
            ((fields..., allargs[1]), Base.tail(allargs))
        end
    end
    return f(Constructor, fields), args
end

# Manually flatten broadcast to avoid unbroadcast MethodError:
# https://github.com/FluxML/Zygote.jl/issues/313
calling(obj::T) where T =
    let schema = _structschema(obj)
        # Make sure to _not_ reference `obj` inside the closure.  It
        # must not have non-isbit types (like arrays) as its members.
        @inline function(allargs...)
            f, args = reconstruct(_reconstruct, schema, allargs...)
            return f(args...)
        end
    end

@adjoint fieldvalues(obj::T) where T = fieldvalues(obj), function(v)
    (NamedTuple{fieldnames(T)}(v),)
end

end # module
