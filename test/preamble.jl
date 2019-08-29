using BroadcastableStructs
using Test

bcapp(f, args...) = f.(args...)

struct WeightedAdd{A, B} <: BroadcastableCallable
    a::A
    b::B
end

(f::WeightedAdd)(x, y) = f.a * x + f.b * y

struct ManyAdd{T1, T2, T3, T4, T5} <: BroadcastableCallable
    x1::T1
    x2::T2
    x3::T3
    x4::T4
    x5::T5
end

ManyAdd() = ManyAdd(1:5...)

(f::ManyAdd)(y1, y2, y3, y4, y5) =
    f.x1 * y1 + f.x2 * y2 + f.x3 * y3 + f.x4 * y4 + f.x5 * y5

macro test_inferred(ex)
    esc(:($Test.@test (($Test.@inferred $ex); true)))
end

macro test_broken_inferred(ex)
    esc(:($Test.@test_broken (($Test.@inferred $ex); true)))
end
