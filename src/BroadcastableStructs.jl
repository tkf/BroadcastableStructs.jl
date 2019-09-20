module BroadcastableStructs

# Use README as the docstring of the module:
@doc let path = joinpath(dirname(@__DIR__), "README.md")
    include_dependency(path)
    replace(read(path, String), r"^```julia"m => "```jldoctest README")
end BroadcastableStructs

export BroadcastableStruct, BroadcastableCallable

using Setfield: constructor_of
using ZygoteRules: @adjoint

@inline foldlargs(op, x) = x
@inline foldlargs(op, x1, x2, xs...) = foldlargs(op, op(x1, x2), xs...)

abstract type BroadcastableStruct end

fieldvalues(obj) = ntuple(i -> getfield(obj, i), nfields(obj))

Broadcast.broadcastable(obj::BroadcastableStruct) =
    Broadcast.broadcasted(constructor_of(typeof(obj)), fieldvalues(obj)...)

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

@inline _reconstruct(::T, fields) where T = constructor_of(T)(fields...)

@inline function reconstruct(f, obj::T, allargs...) where T
    fields, args = foldlargs(((), allargs), fieldvalues(obj)...) do (fields, allargs), x
        if x isa BroadcastableStruct
            y, rest = reconstruct(f, x, allargs...)
            ((fields..., y), rest)
        else
            ((fields..., allargs[1]), Base.tail(allargs))
        end
    end
    return f(obj, fields), args
end

# Manually flatten broadcast to avoid unbroadcast MethodError:
# https://github.com/FluxML/Zygote.jl/issues/313
calling(obj::T) where T = @inline function(allargs...)
    f, args = reconstruct(_reconstruct, obj, allargs...)
    return f(args...)
end

@adjoint fieldvalues(obj::T) where T = fieldvalues(obj), function(v)
    (NamedTuple{fieldnames(T)}(v),)
end

end # module
