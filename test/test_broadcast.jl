module TestBroadcast

using BroadcastableStructs
using Test

struct WeightedAdd{A, B} <: BroadcastableCallable
    a::A
    b::B
end

(f::WeightedAdd)(x, y) = f.a * x + f.b * y

f0 = WeightedAdd(1, 2)
f1 = WeightedAdd([1, 10], 2)

using Test
@test f0.(10, 100) == 210
@test f1.(10, 100) == [210, 300]
@test f0.([1, 10], 100) == [201, 210]
@test f1.([1, 10], 100) == [201, 300]

end  # module
