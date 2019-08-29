using BroadcastableStructs
using Test

struct WeightedAdd{A, B} <: BroadcastableCallable
    a::A
    b::B
end

(f::WeightedAdd)(x, y) = f.a * x + f.b * y
