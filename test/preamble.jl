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

struct Poly3{T0, T1, T2, T3} <: BroadcastableCallable
    c0::T0
    c1::T1
    c2::T2
    c3::T3
end

poly(c0=false, c1=false, c2=false, c3=false) = Poly3(c0, c1, c2, c3)

(p::Poly3)(x) = p.c0 + p.c1 * x + p.c2 * x^2 + p.c3 * x^3

struct AddCall{F, G} <: BroadcastableCallable
    f::F
    g::G
end

(c::AddCall)(x) = c.f(x) + c.g(x)

macro test_inferred(ex)
    esc(:($Test.@test (($Test.@inferred $ex); true)))
end

macro test_broken_inferred(ex)
    esc(:($Test.@test_broken (($Test.@inferred $ex); true)))
end
