using StaticArraysCore, Test

using StaticArraysCore: SArray, SVector, SMatrix
using StaticArraysCore: MArray, MVector, MMatrix
using StaticArraysCore: SizedArray, SizedVector, SizedMatrix

@testset "types" begin
    @test SArray{Tuple{2},Int,1}((1, 2)) isa SArray
    @test SVector{2,Int}((1, 2)) isa SVector
    @test SMatrix{1,2,Int}((1, 2)) isa SMatrix

    @test MArray{Tuple{2},Int,1}((1, 2)) isa MArray
    @test MVector{2,Int}((1, 2)) isa MVector
    @test MMatrix{1,2,Int}((1, 2)) isa MMatrix

    @test SizedArray{Tuple{2},Int,1}([1, 2]) isa SizedArray
    @test SizedVector{2,Int}([1, 2]) isa SizedVector
    @test SizedMatrix{1,2,Int}(fill(0, 1, 2)) isa SizedMatrix
end

