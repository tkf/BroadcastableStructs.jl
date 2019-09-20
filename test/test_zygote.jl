module TestZygote

include("preamble.jl")

using Zygote

f0 = WeightedAdd(1, 2)
f1 = WeightedAdd([1, 10], 2)

@test gradient((x, y) -> sum(f0.(x, y)), [1, 10], 100) == ([1, 1], 4)
@test gradient((x, y) -> sum(f1.(x, y)), [1, 10], 100) == ([1, 10], 4)

c0 = poly([1, 10], [2, 20])
c1 = AddCall(poly([1, 10], 0), poly(0, [2, 20]))
@test gradient(x -> sum(c0.(x)), [1, 2]) == ([2, 20],)
@test gradient(x -> sum(c1.(x)), [1, 2]) == ([2, 20],)

end  # module
