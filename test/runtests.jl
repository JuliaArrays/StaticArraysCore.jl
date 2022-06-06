using StaticArraysCore, Test

using StaticArraysCore: SArray, SVector, SMatrix
using StaticArraysCore: MArray, MVector, MMatrix
using StaticArraysCore: SizedArray, SizedVector, SizedMatrix

@testset "types" begin
    @test SArray{Tuple{2},Int,1}((1, 2)) isa SArray
    @test SArray{Tuple{2},Float64,1}((1, 2)) isa SVector{2,Float64}
    @test SVector{2,Int}((1, 2)) isa SVector
    @test SMatrix{1,2,Int}((1, 2)) isa SMatrix

    @test MArray{Tuple{2},Int,1}((1, 2)) isa MArray
    @test MArray{Tuple{2},Int,1,2}(undef) isa MArray
    @test MArray{Tuple{2},Float64,1}((1, 2)) isa MVector{2,Float64}
    @test MVector{2,Int}((1, 2)) isa MVector
    @test MMatrix{1,2,Int}((1, 2)) isa MMatrix

    @test SizedArray{Tuple{2},Int,2,1,Vector{Int}}([1, 2]) isa SizedArray
    @test SizedArray{Tuple{2},Int,2,1,Vector{Int}}(undef) isa SizedArray
end
