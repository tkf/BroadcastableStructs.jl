module TestBroadcast

include("preamble.jl")

f0 = WeightedAdd(1, 2)
f1 = WeightedAdd([1, 10], 2)

using Test
@test f0.(10, 100) == 210
@test f1.(10, 100) == [210, 300]
@test f0.([1, 10], 100) == [201, 210]
@test f1.([1, 10], 100) == [201, 300]

c0 = poly([1, 10], [2, 20])
c1 = AddCall(poly([1, 10], 0), poly(0, [2, 20]))
@test c0.(1) == c1.(1)
@test c0.([1, 2]) == c1.([1, 2])

end  # module
