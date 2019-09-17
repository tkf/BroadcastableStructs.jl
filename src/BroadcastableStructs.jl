module BroadcastableStructs

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
    Broadcast.broadcasted(calling(c), fieldvalues(c)..., args...)

@inline leq(::Val{i}, n) where i = i <= n
@inline inc(::Val{i}) where i = Val(i + 1)

# Manually flatten broadcast to avoid unbroadcast MethodError:
# https://github.com/FluxML/Zygote.jl/issues/313
calling(obj::T) where T = @inline function(allargs...)
    fields, args = foldlargs(((), (), Val(1)), allargs...) do (fields, args, i), x
        if leq(i, nfields(obj))
            ((fields..., x), args, inc(i))
        else
            (fields, (args..., x), inc(i))
        end
    end
    return constructor_of(T)(fields...)(args...)
end

@adjoint fieldvalues(obj::T) where T = fieldvalues(obj), function(v)
    (NamedTuple{fieldnames(T)}(v),)
end

end # module
