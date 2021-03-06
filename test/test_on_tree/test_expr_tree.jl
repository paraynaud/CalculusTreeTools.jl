using Test
using MathOptInterface, JuMP



using .trait_expr_tree
using .abstract_expr_tree
using .algo_expr_tree
using .algo_tree


println("\n\n test_expr_tree\n\n")

@testset "test building of trees and equality" begin
    expr_1 = :(x[1] + x[2] )
    t_expr_1 = abstract_expr_tree.create_expr_tree(expr_1)
    @test t_expr_1 == expr_1
    @test trait_expr_tree.expr_tree_equal(t_expr_1, expr_1)

    t1 = trait_expr_tree.transform_to_expr_tree(t_expr_1)
    @test trait_expr_tree.expr_tree_equal(t1, t_expr_1)

    expr_2 = :( (x[3]+x[4])^2 +  x[1] * x[2] )
    @test trait_expr_tree.expr_tree_equal(expr_1, expr_2) == false
    t_expr_2 = abstract_expr_tree.create_expr_tree(expr_2)
    @test t_expr_2 == expr_2
    t2 = trait_expr_tree.transform_to_expr_tree(t_expr_2)
    @test  trait_expr_tree.expr_tree_equal(expr_2, t2)
    @test  trait_expr_tree.expr_tree_equal(t_expr_2, t2)

    n3_1_1 = abstract_expr_tree.create_expr_tree(abstract_expr_node.create_node_expr(:x,1))
    n3_1_2 = abstract_expr_tree.create_expr_tree(abstract_expr_node.create_node_expr(:x,2))
    n3_1_op = abstract_expr_node.create_node_expr(:*)
    n3_1 = abstract_expr_tree.create_expr_tree( n3_1_op, [n3_1_1, n3_1_2])

    n3_2_1_1 = abstract_expr_tree.create_expr_tree(abstract_expr_node.create_node_expr(:x,3))
    n3_2_1_2 = abstract_expr_tree.create_expr_tree(abstract_expr_node.create_node_expr(:x,4))
    n3_2_1_op = abstract_expr_node.create_node_expr(:+)
    n3_2_1 = abstract_expr_tree.create_expr_tree(n3_2_1_op, [n3_2_1_1, n3_2_1_2])
    n3_2_op = abstract_expr_node.create_node_expr(:^,2, true)
    n3_2 = abstract_expr_tree.create_expr_tree(n3_2_op, [n3_2_1])
    n3_op = abstract_expr_node.create_node_expr(:+)
    t3 = abstract_expr_tree.create_expr_tree(n3_op,[n3_2,n3_1])
    @test  trait_expr_tree.expr_tree_equal(t_expr_2, t3)
    @test  trait_expr_tree.expr_tree_equal(t2, t3)

 end


@testset " Deletion of imbricated +" begin
    t_expr_4 = abstract_expr_tree.create_expr_tree( :( (x[3]+x[4]) + (x[1] + x[2]) ) )
    t4 = trait_expr_tree.transform_to_expr_tree(t_expr_4)
    res_t4 = algo_expr_tree.delete_imbricated_plus(t4)
    res_t_expr_4 = algo_expr_tree.delete_imbricated_plus(t_expr_4)
    test_res_t_expr_4 = [:(x[3]), :(x[4]), :(x[1]), :(x[2])]
    @test res_t_expr_4 == test_res_t_expr_4
    @test foldl(&,trait_expr_tree.expr_tree_equal.(res_t4, res_t_expr_4))

    t_expr_5 = abstract_expr_tree.create_expr_tree( :( (x[3])^2+ (x[5] * x[4]) + (x[1] + x[2]) ) )
    t5 = trait_expr_tree.transform_to_expr_tree(t_expr_5)
    res_t_expr_5 = algo_expr_tree.delete_imbricated_plus(t_expr_5)
    res_t5 = algo_expr_tree.delete_imbricated_plus(t5)
    test_res_t_expr_5 = [ :(x[3]^2), :(x[5] * x[4]), :(x[1]), :(x[2])]
    @test res_t_expr_5 == test_res_t_expr_5
    @test foldl(&,trait_expr_tree.expr_tree_equal.(res_t5, res_t_expr_5))


    t_expr_6 = abstract_expr_tree.create_expr_tree( :( (x[3])^2+ (x[5] * x[4]) - (x[1] + x[2]) ) )
    t6 = trait_expr_tree.transform_to_expr_tree(t_expr_6)
    res_t_expr_6 = algo_expr_tree.delete_imbricated_plus(t_expr_6)
    res_t6 = algo_expr_tree.delete_imbricated_plus(t6)
    test_res_t_expr_6 = [ :(x[3]^2), :(x[5] * x[4]), :(-(x[1])), :(-(x[2]))]
    @test res_t_expr_6 == test_res_t_expr_6
    @test foldl(&,trait_expr_tree.expr_tree_equal.(res_t6, res_t_expr_6))


    t_expr_7 = abstract_expr_tree.create_expr_tree( :( (x[3])^2+ (x[5] * x[4]) - (x[1] - x[2]) ) )
    t7 = trait_expr_tree.transform_to_expr_tree(t_expr_7)
    res_t_expr_7 = algo_expr_tree.delete_imbricated_plus(t_expr_7)
    res_t7 = algo_expr_tree.delete_imbricated_plus(t7)
    test_res_t_expr_7 = [ :(x[3]^2), :(x[5] * x[4]), :(-(x[1])), :(-(-(x[2])))]
    @test res_t_expr_7 == test_res_t_expr_7
    @test foldl(&,trait_expr_tree.expr_tree_equal.(res_t7, res_t_expr_7))
end


# code warntype
# InteractiveUtils.@code_warntype algo_expr_tree.delete_imbricated_plus(t_expr_7)
# InteractiveUtils.@code_warntype abstract_expr_tree.create_expr_tree( :( (x[3])^2+ (x[5] * x[4]) - (x[1] - x[2]) ) )



@testset "get type of a expr tree" begin

    t_expr_8 = abstract_expr_tree.create_expr_tree( :( (x[3]^4)+ (x[5] * x[4]) - (x[1] - x[2]) ) )
    t8 = trait_expr_tree.transform_to_expr_tree(t_expr_8)

    test_res8 =  algo_expr_tree.get_type_tree(t_expr_8)
    test_res_t8 =  algo_expr_tree.get_type_tree(t8)
    @test test_res8 == test_res_t8
    @test trait_type_expr.is_more(test_res_t8)


    t_expr_cubic = abstract_expr_tree.create_expr_tree( :( (x[3]^3)+ (x[5] * x[4]) - (x[1] - x[2]) ) )
    t_cubic = trait_expr_tree.transform_to_expr_tree(t_expr_cubic)

    res_cubic =  algo_expr_tree.get_type_tree(t_expr_cubic)
    res_t_cubic =  algo_expr_tree.get_type_tree(t_cubic)
    @test res_cubic == res_t_cubic
    @test trait_type_expr._is_cubic(res_t_cubic)

    t_expr_cubic2 = abstract_expr_tree.create_expr_tree( :( (x[3]^3)+ (x[5] * x[4]) - (x[1] - x[2]) + sin(5)) )
    t_cubic2 = trait_expr_tree.transform_to_expr_tree(t_expr_cubic2)

    res_cubic2 =  algo_expr_tree.get_type_tree(t_expr_cubic2)
    res_t_cubic2 =  algo_expr_tree.get_type_tree(t_cubic2)
    @test res_cubic2 == res_t_cubic2
    @test trait_type_expr._is_cubic(res_t_cubic2)

    t_expr_sin = abstract_expr_tree.create_expr_tree( :( (x[3]^3)+ sin(x[5] * x[4]) - (x[1] - x[2]) ) )
    t_sin = trait_expr_tree.transform_to_expr_tree(t_expr_sin)

    res_sin =  algo_expr_tree.get_type_tree(t_expr_sin)
    res_t_sin =  algo_expr_tree.get_type_tree(t_sin)
    @test res_sin == res_t_sin
    @test trait_type_expr.is_more(res_t_sin)



    m = Model()
    n_x = 100
    # n_x = 5
    @variable(m, x[1:n_x])
    @NLobjective(m, Min, sum( (x[j] * x[j+1]   for j in 1:n_x-1  ) ) )
    eval_test = JuMP.NLPEvaluator(m)
    MathOptInterface.initialize(eval_test, [:ExprGraph])
    obj = MathOptInterface.objective_expr(eval_test)
    t_obj =  trait_expr_tree.transform_to_expr_tree(obj)

    test_res_obj = algo_expr_tree.get_type_tree(t_obj)
    @test trait_type_expr._is_quadratic(test_res_obj)
    @test trait_type_expr.is_more(test_res_obj) == false

    t_expr_9 = abstract_expr_tree.create_expr_tree( :( x[1] + sin(x[2])) )
    res_t_expr_9 = algo_expr_tree.delete_imbricated_plus(t_expr_9)

    # InteractiveUtils.@code_warntype algo_expr_tree.delete_imbricated_plus(t_expr_9)

    @test trait_type_expr.is_linear(algo_expr_tree.get_type_tree(t_expr_9)) == false
    @test trait_type_expr.is_more(algo_expr_tree.get_type_tree(t_expr_9))


end


@testset "test de la récupération des variable élementaires" begin
    t_expr_var = abstract_expr_tree.create_expr_tree( :( (x[1]^3)+ sin(x[1] * x[2]) - (x[3] - x[2]) ) )
    t_var = trait_expr_tree.transform_to_expr_tree(t_expr_var)
    res = algo_expr_tree.get_elemental_variable(t_var)
    res2 = algo_expr_tree.get_elemental_variable(t_expr_var)
    @test res == res2
    @test res == [1,2,3]
    t_expr_var1= abstract_expr_tree.create_expr_tree( :( (x[1]^3) ) )
    t_var1 = trait_expr_tree.transform_to_expr_tree(t_expr_var1)
    res_expr_var1 = algo_expr_tree.get_elemental_variable(t_expr_var1)
    res_var1 = algo_expr_tree.get_elemental_variable(t_var1)
    @test res_var1 == res_expr_var1
    @test res_var1 == [1]
end


@testset "test complet à partir d'un modèle JuMP" begin
    m = Model()
    # n_x = 50000
    n_x = 10
    @variable(m, x[1:n_x])
    @NLobjective(m, Min, sum( x[j] * x[j+1] for j in 1:n_x-1 ) + (sin(x[1]))^2 + x[n_x-1]^3  + 5 )
    # @NLobjective(m, Min, sum( (x[j] * x[j+1]   for j in 1:n_x-1  ) ) + sin(x[1]))
    eval_test = JuMP.NLPEvaluator(m)
    MathOptInterface.initialize(eval_test, [:ExprGraph])
    obj = MathOptInterface.objective_expr(eval_test)
    t_obj =  trait_expr_tree.transform_to_expr_tree(obj)
    # DEFINITION DES OBJETS A TESTER
    elmt_fun = algo_expr_tree.delete_imbricated_plus(obj)
    type_elmt_fun = algo_expr_tree.get_type_tree.(elmt_fun)
    U = algo_expr_tree.get_elemental_variable.(elmt_fun)

    t_elmt_fun = algo_expr_tree.delete_imbricated_plus(t_obj)
    t_type_elmt_fun = algo_expr_tree.get_type_tree.(t_elmt_fun)
    t_U = algo_expr_tree.get_elemental_variable.(t_elmt_fun)

    #DEBUT DES TESTS
    x = ones(Float32, n_x)
    eval_ones = 15.708073371141893
    # TEST SUR LES FONCTIONS ELEMENTS
        # @test elmt_fun == t_elmt_fun # car type initiaux différents
        @test foldl(&,trait_expr_tree.expr_tree_equal.(elmt_fun, t_elmt_fun) )
        @test type_elmt_fun == t_type_elmt_fun

    # TEST SUR LES VARIABLES ELEMENTAIRE
        res_elemental_variable = Array{Int64,1}[[1, 2], [2, 3], [3, 4], [4, 5], [5, 6], [6, 7], [7, 8], [8, 9], [9, 10], [1], [9], []]
        @test U == t_U
        @test U == res_elemental_variable

    # TEST SUR LES EVALUATIONS
        # @time res = algo_expr_tree.evaluate_expr_tree(obj, x)
        # @time t_res = algo_expr_tree.evaluate_expr_tree(t_obj, x)
        # @time res = algo_expr_tree.evaluate_expr_tree(obj, x)
        # @time t_res = algo_expr_tree.evaluate_expr_tree(t_obj, x)
        res = M_evaluation_expr_tree.evaluate_expr_tree(obj, x)
        t_res = M_evaluation_expr_tree.evaluate_expr_tree(t_obj, x)
        # @test res == t_res
        @test res == (Float32)(eval_ones)
    # TEST SUR LES EVALUATIONS DE FONCTIONS ELEMENTS
        n_element = length(elmt_fun)
        res_p = Vector{Number}(undef, n_element)

        for i in 1:n_element
            res_p[i] = M_evaluation_expr_tree.evaluate_expr_tree(elmt_fun[i], x)
            # InteractiveUtils.@code_warntype res_p[i] = algo_expr_tree.evaluate_element_expr_tree(elmt_fun[i], x, U[i])
        end
        # @time (Threads.@threads for i in 1:n_element
        #     res_p[i] = algo_expr_tree.evaluate_element_expr_tree(elmt_fun[i], x, U[i])
        #     # InteractiveUtils.@code_warntype res_p[i] = algo_expr_tree.evaluate_element_expr_tree(elmt_fun[i], x, U[i])
        # end)
        res_total = sum(res_p)
        @test (typeof(res))(res_total) == res
end












function expr_tree_factorielle_dif_node( n :: Integer)
    if n == 0
        constant_node = abstract_expr_node.create_node_expr(:x,1)
        new_leaf = abstract_expr_tree.create_expr_tree(constant_node)
        return new_leaf
    else
        if n % 3 == 0
            op_node = abstract_expr_node.create_node_expr(:+)
            new_node = abstract_expr_tree.create_expr_tree(op_node, expr_tree_factorielle_dif_node.((n-1) * ones(Integer,n)) )
            return new_node
        elseif n % 3 == 1
            op_node = abstract_expr_node.create_node_expr(:-)
            new_node = abstract_expr_tree.create_expr_tree(op_node, expr_tree_factorielle_dif_node.((n-1) * ones(Integer,n)) )
            return new_node
        elseif n % 3 == 2
            op_node = abstract_expr_node.create_node_expr(:*)
            new_node = abstract_expr_tree.create_expr_tree(op_node, expr_tree_factorielle_dif_node.((n-1) * ones(Integer,n)) )
            return new_node
        end
    end
end


function expr_tree_factorielle_plus( n :: Integer, op :: Symbol)
    if n == 0
        constant_node = abstract_expr_node.create_node_expr(1)
        new_leaf = abstract_expr_tree.create_expr_tree(constant_node)
        return new_leaf
        # return abstract_expr_tree.create_expr_tree(abstract_expr_node.create_node_expr(0))
    else
        op_node = abstract_expr_node.create_node_expr(op)
        new_node = abstract_expr_tree.create_expr_tree(op_node, expr_tree_factorielle_plus.( (n-1) * ones(Integer,n), op) )
        return new_node
        # return abstract_expr_tree.create_expr_tree(abstract_expr_node.create_node_expr(op), expr_tree_factorielle_plus.( (n-1) * ones(Integer,n), op) )
    end
end


@testset "test arbres factorielle désimbriqué les + et get_type " begin
    n = 5
    @time test_fac_expr_tree_plus = expr_tree_factorielle_plus(n, :+) :: implementation_expr_tree.t_expr_tree
    # test_fac_expr_tree = expr_tree_factorielle_dif_node(3) :: implementation_expr_tree.t_expr_tree
    # algo_tree.printer_tree(test_fac_expr_tree)
    # algo_tree.printer_tree(test_fac_expr_tree_plus)
    # @time algo_expr_tree.get_type_tree.(test_fac_expr_tree_plus_no_plus) # ca ne semble pas être une bonne idée ou alors encore parralélisé
    # algo_tree.printer_tree.(test_fac_expr_tree_plus_no_plus)
    # InteractiveUtils.@code_warntype algo_expr_tree.get_type_tree(test_fac_expr_tree_plus)
     test_fac_expr_tree_plus_no_plus = algo_expr_tree.delete_imbricated_plus(test_fac_expr_tree_plus)
     algo_expr_tree.get_type_tree(test_fac_expr_tree_plus)
     res3 = algo_expr_tree.get_elemental_variable(test_fac_expr_tree_plus)
     res = M_evaluation_expr_tree.evaluate_expr_tree(test_fac_expr_tree_plus,ones(5))
    @test res == factorial(n)

    # InteractiveUtils.@code_warntype algo_expr_tree.get_type_tree(test_fac_expr_tree_plus)
    # InteractiveUtils.@code_warntype algo_expr_tree.delete_imbricated_plus(test_fac_expr_tree_plus)
end


function create_trees(n :: Int)
    m = Model()
    @variable(m, x[1:n])
    @NLobjective(m, Min, sum( (1/2) * (x[j+1]/(x[j]^2)) + sin(x[j+1]^3) for j in 1:n-1 ) + tan(x[1])*1/x[3] + exp(x[2]) - 4)
    evaluator = JuMP.NLPEvaluator(m)
    MathOptInterface.initialize(evaluator, [:ExprGraph, :Hess])
    v = ones(n)
    Expr_j = MathOptInterface.objective_expr(evaluator)
    expr_tree = CalculusTreeTools.transform_to_expr_tree(Expr_j)
    expr_tree_j = copy(expr_tree)
    complete_tree = CalculusTreeTools.create_complete_tree(expr_tree_j)

    return Expr_j, expr_tree_j, complete_tree, evaluator
end

γ(a,b) = (a-b) < 1e-5

@testset "test de la création de la fonction d'évaluation" begin
    n = 50
    expr, expr_tree, comp_tree, evaluator = create_trees(n)
    f = CalculusTreeTools.get_function_of_evaluation(expr_tree)
    x = ones(50)
    obj_MOI_x = MathOptInterface.eval_objective(evaluator, x)
    obj_f =CalculusTreeTools.algo_expr_tree.eval_function_wrapper(f,x)
    @show obj_f, obj_MOI_x
    @test obj_f == obj_MOI_x
    @test γ(obj_f, obj_MOI_x)
end
