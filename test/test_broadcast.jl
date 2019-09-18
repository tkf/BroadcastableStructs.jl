module TestBroadcast

include("preamble.jl")

f0 = WeightedAdd(1, 2)
f1 = WeightedAdd([1, 10], 2)
f2 = WeightedAdd((x for x in [1, 10]), 2)

using Test
@test f0.(10, 100) == 210
@test f1.(10, 100) == [210, 300]
@test f2.(10, 100) == [210, 300]
@test f0.([1, 10], 100) == [201, 210]
@test f1.([1, 10], 100) == [201, 300]
@test f2.([1, 10], 100) == [201, 300]

end  # module
