using BlockArrays, Test

@testset "append!(::BlockVector, vector)" begin
    @testset for alias in [false, true],
        compatible in [false, true],
        srctype in [:BlockVector, :PseudoBlockVector, :Vector]

        dest = mortar([[1, 2, 3], [4, 5]])

        # Create `src` array:
        if compatible
            T = Int
        else
            T = Float64
        end
        if srctype === :BlockVector
            src = mortar([T[6, 7], T[8, 9]])
        elseif srctype === :PseudoBlockVector
            src = PseudoBlockVector(T[6:9;], [3, 1])
        elseif srctype === :Vector
            src = T[6:9;]
        else
            error("Unknown srctype = $srctype")
        end

        @test append!(dest, src; alias = alias) === dest
        @test dest == 1:9

        @test dest[Block(1)] == [1, 2, 3]
        if alias && compatible
            @test dest[Block(2)] == [4, 5]
            if srctype === :BlockVector
                @test dest[Block(3)] == [6, 7]
                @test dest[Block(4)] == [8, 9]
            else
                @test dest[Block(3)] == [6, 7, 8, 9]
            end
        else
            @test dest[Block(2)] == 4:9
        end

        src[1] = 666
        if alias && compatible
            @test dest[6] == 666
        else
            @test dest[6] == 6
        end
    end
end

@testset "append!(::BlockVector, iterator)" begin
    @testset "$label" for (label, itr) in [
        "with length" => (x + 0 for x in 6:9),
        "no length" => (x for x in 6:9 if x > 0),
    ]
        dest = mortar([[1, 2, 3], [4, 5]])
        @test append!(dest, itr) === dest
        @test dest == 1:9
    end
end

@testset "push!" begin
    A = mortar([[1, 2, 3], [4, 5]])
    push!(A, 6)
    push!(A, 7, 8, 9)
    @test A == 1:9
end

@testset "pushfirst!" begin
    A = mortar([[1, 2, 3], [4, 5]])
    pushfirst!(A, 0)
    pushfirst!(A, -3, -2, -1)
    @test A == -3:5
end

@testset "pop!" begin
    A = mortar([[1, 2, 3], [4, 5]])
    B = []
    while !isempty(A)
        push!(B, pop!(A))
    end
    @test A == []
    @test B == 5:-1:1
end

@testset "popfirst!" begin
    A = mortar([[1, 2, 3], [4, 5]])
    B = []
    while !isempty(A)
        push!(B, popfirst!(A))
    end
    @test A == []
    @test B == 1:5
end