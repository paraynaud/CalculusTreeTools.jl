using CalculusTreeTools
using JuMP, MathOptInterface
using Test

println("test 1 \n")
e1 = :(x[1] - x[2])
et1 = CalculusTreeTools.transform_to_expr_tree(e1)
bound_tree = CalculusTreeTools.create_bound_tree(et1)
# bound_tree2 = CalculusTreeTools.create_bound_tree(e1)
# CalculusTreeTools.print_tree(bound_tree2)
# CalculusTreeTools.print_tree(bound_tree)
CalculusTreeTools.set_bound(et1, bound_tree)
CalculusTreeTools.print_tree(bound_tree)

println("\n\n\ntest 2 \n")
e2 = :(4 - ( sin(x[3]) - sin(x[4])*3 ) )
et2 = CalculusTreeTools.transform_to_expr_tree(e2)
bound_tree2 = CalculusTreeTools.create_bound_tree(et2)
# bound_tree2 = CalculusTreeTools.create_bound_tree(e1)
# CalculusTreeTools.print_tree(bound_tree2)
# CalculusTreeTools.print_tree(bound_tree2)
CalculusTreeTools.set_bound(et2, bound_tree2)
CalculusTreeTools.print_tree(bound_tree2)

println("\n\n\ntest 3 \n")
m = Model()
n = 3
@variable(m, x[1:n])

@NLobjective(m, Min, sin(sum( (x[j]^2 * x[j+1]^3) for j in 1:n-1 )) + ( sin(sin(x[1])*(π*0.5)) - (x[1]^2 * - (x[2])^2 - 1)) + cos(sin(x[3])*(0.5*π )) )

evaluator = JuMP.NLPEvaluator(m)
MathOptInterface.initialize(evaluator, [:ExprGraph])
Expr_j = MathOptInterface.objective_expr(evaluator)
expr_tree_j = CalculusTreeTools.transform_to_expr_tree(Expr_j)

bound_expr_tree = CalculusTreeTools.create_bound_tree(expr_tree_j)
# CalculusTreeTools.print_tree(bound_expr_tree)
CalculusTreeTools.set_bound(expr_tree_j, bound_expr_tree)
CalculusTreeTools.print_tree(bound_expr_tree)
