using StrideArraysCore, ThreadingUtilities, Aqua
using Test

function closeopensum(x)
    s = zero(eltype(x))
    @inbounds @simd for i ∈ StrideArraysCore.CloseOpen(length(x))
        s += x[i+1]
    end
    s
end

@testset "StrideArraysCore.jl" begin

    Aqua.test_all(StrideArraysCore)
    
    @testset "StrideArrays Basic" begin
        A = rand(100, 100);
        B = copy(A);
        C = StrideArraysCore.PtrArray(A);
        GC.@preserve A begin
            @test closeopensum(C) == closeopensum(A)
            @test sum(C) == sum(A)
            @test closeopensum(C) ≈ sum(C)
            @test A == B
            C .*= 3;
            @test A == 3 .* B
            @test C == A
            @test C == 3 .* B

            D = copy(A);
            Cslice = view(C, 23:48, 17:89)
            Cslice .= 2;
            @test D != C
            D[23:48,17:89] .= 2;
            @test D == C
            @test C === view(C, :, :)
            @test @inferred(size(view(C, StaticInt(1):StaticInt(8), :), 1)) === 8
            @test @inferred(size(view(C, StaticInt(1):StaticInt(8), :), StaticInt(1))) === StaticInt(8)
            @test @inferred(StrideArraysCore.size(view(C, StaticInt(1):StaticInt(8), :), 1)) === 8
            @test @inferred(StrideArraysCore.size(view(C, StaticInt(1):StaticInt(8), :), StaticInt(1))) === StaticInt(8)

            @test C  isa PtrArray
            @test C' isa PtrArray
            @test @inferred(permutedims(C, Val((2,1)))) isa PtrArray
            @test @inferred(adjoint(C)) == D'
            @test @inferred(axes(C)) == axes(D)
            @test @inferred(axes(C')) == axes(D')
            @test @inferred(eachindex(view(C, :, 2:6))) == 1:(5*size(C,1))
            @test @inferred(eachindex(view(C', 2:6, :)')) == 1:(5*size(C,1))
            @test @inferred(eachindex(view(C, 2:6, :))) == CartesianIndices((5, size(C,2)))
            @test @inferred(axes(StrideArraysCore.zview(C, StaticInt(2):StaticInt(6), :), StaticInt(1))) === StrideArraysCore.CloseOpen(StaticInt(5))
            @test @inferred(axes(StrideArraysCore.zview(C, StaticInt(2):StaticInt(6), :), StaticInt(1))) === StrideArraysCore.CloseOpen(StaticInt(5))
            @test @inferred(length(axes(StrideArraysCore.zview(C, StaticInt(2):StaticInt(6), :), StaticInt(1)))) === StaticInt(5)
        end
        W = rand(2,3,4);
        X = PtrArray(W);
        GC.@preserve W begin
            @test W == X
            @test permutedims(W, (1,2,3)) == @inferred(permutedims(X, Val((1,2,3))))
            @test permutedims(W, (1,3,2)) == @inferred(permutedims(X, Val((1,3,2))))
            @test permutedims(W, (2,1,3)) == @inferred(permutedims(X, Val((2,1,3))))
            @test permutedims(W, (2,3,1)) == @inferred(permutedims(X, Val((2,3,1))))
            @test permutedims(W, (3,1,2)) == @inferred(permutedims(X, Val((3,1,2))))
            @test permutedims(W, (3,2,1)) == @inferred(permutedims(X, Val((3,2,1))))
            @test_throws BoundsError X[length(X) + 1]
            @test_throws BoundsError X[-4]
            @test_throws BoundsError X[2,5,3]
        end
        @test X === PtrArray(pointer(X), size(X))
        y = rand(77);
        GC.@preserve y begin
            z = PtrArray(y);
            @test y == z
            @test pointer(y) === pointer(z)
            @test_throws BoundsError z[-8]
            @test_throws BoundsError z[88]
        end
    end
    @testset "ThreadingUtilities" begin
        xu = zeros(UInt, 100);
        x = rand(100); y = rand(100); z = rand(100);
        t = (x,y,z)
        pt, gt = StrideArraysCore.object_and_preserve(t)
        greet = ["Hello", "world", "hang", "in", "there"]
        pg, gg = StrideArraysCore.object_and_preserve(greet)
        GC.@preserve xu gt gg begin
            ThreadingUtilities.store!(pointer(xu), pt, 0)
            @test @inferred(ThreadingUtilities.load(pointer(xu), typeof(pt), 0)) === (1, t)
            offset = 1
            for a ∈ t
                _p, g = StrideArraysCore.object_and_preserve(a)
                ThreadingUtilities.store!(pointer(xu), _p, offset)
                offset, p = @inferred(ThreadingUtilities.load(pointer(xu), typeof(_p), offset))
                @test g === a
                @test p isa PtrArray
                @test pointer(p) === pointer(a)
                @test p !== a
                @test p == a
            end
            ThreadingUtilities.store!(pointer(xu), pg, offset)
            @test @inferred(ThreadingUtilities.load(pointer(xu), typeof(pg), offset)) === (offset+1, greet)
        end
    end
end
