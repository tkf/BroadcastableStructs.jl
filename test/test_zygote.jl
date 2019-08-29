module TestZygote

include("preamble.jl")

using Zygote

f0 = WeightedAdd(1, 2)
f1 = WeightedAdd([1, 10], 2)

@test_broken gradient((x, y) -> sum(f0.(x, y)), [1, 10], 100) == ([1, 1], 4)
@test gradient((x, y) -> sum(f1.(x, y)), [1, 10], 100) == ([1, 10], 4)

end  # module
