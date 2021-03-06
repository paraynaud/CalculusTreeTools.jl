module M_evaluation_expr_tree

    using ..trait_expr_tree, ..trait_expr_node
    using ..implementation_expr_tree, ..implementation_complete_expr_tree, ..implementation_pre_compiled_tree
    using ..abstract_expr_node

    using ..implementation_pre_n_compiled_tree


    using ForwardDiff

    # IMPORTANT La fonction evaluate_expr_tree garde le type des variables,
    # Il faut cependant veiller à modifier les constantes dans les expressions pour qu'elles
    # n'augmentent pas le type
    @inline evaluate_expr_tree(a :: Any) = (x :: AbstractVector{} -> evaluate_expr_tree(a,x) )
    @inline evaluate_expr_tree(a :: Any, elmt_var :: Vector{Int}) = (x :: AbstractVector{} -> evaluate_expr_tree(a,view(x,elmt_var) ) )
    @inline evaluate_expr_tree(a :: Any, x :: AbstractVector{T})  where T <: Number = _evaluate_expr_tree(a, trait_expr_tree.is_expr_tree(a), x)
    @inline evaluate_expr_tree(a :: Any, x :: AbstractVector) = _evaluate_expr_tree(a, trait_expr_tree.is_expr_tree(a), x)
    @inline evaluate_expr_tree(a :: Any, x :: AbstractArray) = _evaluate_expr_tree(a, trait_expr_tree.is_expr_tree(a), x)
    @inline _evaluate_expr_tree(a, :: trait_expr_tree.type_not_expr_tree, x :: AbstractVector{T})  where T <: Number = error(" This is not an Expr tree")
    @inline _evaluate_expr_tree(a, :: trait_expr_tree.type_expr_tree, x :: AbstractVector{T}) where T <: Number = _evaluate_expr_tree(a, x)
    @inline _evaluate_expr_tree(a, :: trait_expr_tree.type_not_expr_tree, x :: AbstractVector) = error(" This is not an Expr tree")
    @inline _evaluate_expr_tree(a, :: trait_expr_tree.type_expr_tree, x :: AbstractVector) = _evaluate_expr_tree(a, x)
    @inline _evaluate_expr_tree(a, :: trait_expr_tree.type_not_expr_tree, x :: AbstractArray) = error(" This is not an Expr tree")
    @inline _evaluate_expr_tree(a, :: trait_expr_tree.type_expr_tree, x :: AbstractArray) = _evaluate_expr_tree(a, x)
    @inline function _evaluate_expr_tree(expr_tree :: Y, x  :: AbstractVector{T}) where T <: Number where Y
        nd = trait_expr_tree._get_expr_node(expr_tree)
        if  trait_expr_node.node_is_operator(nd) == false
            trait_expr_node.evaluate_node(nd, x)
        else
            ch = trait_expr_tree._get_expr_children(expr_tree)
            n = length(ch)
            temp = Vector{T}(undef,n)
            @inbounds map!(y -> evaluate_expr_tree(y,x), temp, ch)
            trait_expr_node.evaluate_node(nd, temp)
        end
    end

    @inline function _evaluate_expr_tree(expr_tree :: implementation_expr_tree.t_expr_tree , x  :: AbstractVector{T}) where T <: Number
        if trait_expr_node.node_is_operator(expr_tree.field :: trait_expr_node.ab_ex_nd) :: Bool == false
            return trait_expr_node._evaluate_node(expr_tree.field, x)
        else
            n = length(expr_tree.children)
            temp = Vector{T}(undef, n)
            map!( y :: implementation_expr_tree.t_expr_tree  -> _evaluate_expr_tree(y,x) , temp, expr_tree.children)
            return trait_expr_node._evaluate_node(expr_tree.field,  temp)
        end
    end


    @inline function _evaluate_expr_tree(expr_tree_cmp :: implementation_complete_expr_tree.complete_expr_tree , x  :: AbstractVector{T}) where T <: Number
        op = trait_expr_tree.get_expr_node(expr_tree_cmp) :: trait_expr_node.ab_ex_nd
        if trait_expr_node.node_is_operator(op) :: Bool == false
            return trait_expr_node._evaluate_node(op, x)
        else
            children = trait_expr_tree.get_expr_children(expr_tree_cmp)
            n = length(children) :: Int
            temp = Vector{T}(undef, n)
            map!( y :: implementation_complete_expr_tree.complete_expr_tree  -> _evaluate_expr_tree(y,x), temp, children)
            return trait_expr_node._evaluate_node(op,  temp)
        end
    end

    @inline _evaluate_expr_tree(tree :: implementation_pre_compiled_tree.pre_compiled_tree{T} , x  :: AbstractVector{T}) where T <: Number = implementation_pre_compiled_tree.evaluate_pre_compiled_tree(tree, x)





    @inline function _evaluate_expr_tree_multiple_points(expr_tree :: implementation_expr_tree.t_expr_tree ,
                                        xs  ::  Array{SubArray{T,1,Array{T,1},N,false},1}) where N where T <: Number
        op = trait_expr_tree.get_expr_node(expr_tree) :: trait_expr_node.ab_ex_nd
        number_x = length(xs)
        if trait_expr_node.node_is_operator(op :: trait_expr_node.ab_ex_nd) :: Bool == false
            temp = Vector{T}(undef, number_x)
            map!( x -> trait_expr_node._evaluate_node(op, x), temp, xs)
            return temp
        else
            children = trait_expr_tree.get_expr_children(expr_tree)
            n = length(children)
            lx = length(xs[1])
            res = Vector{T}(undef,number_x)
            temp = Array{T,2}(undef, n, number_x)
            for i in 1:n
                view(temp, i, :) .= _evaluate_expr_tree_multiple_points(children[i], xs)
            end
            for i in 1:number_x
                res[i] = trait_expr_node._evaluate_node(op,  view(temp, : ,i ) )
            end
            return res
        end
    end




    @inline evaluate_expr_tree_multiple_points(tree :: implementation_pre_n_compiled_tree.pre_n_compiled_tree{T} , multiple_x :: Vector{Vector{T}}) where T <: Number = implementation_pre_n_compiled_tree.evaluate_pre_n_compiled_tree(tree, multiple_x)
    @inline evaluate_expr_tree_multiple_points(tree :: implementation_pre_n_compiled_tree.pre_n_compiled_tree{T} , multiple_x_view :: Array{SubArray{T,1,Array{T,1},N,false},1}) where N where T <: Number = implementation_pre_n_compiled_tree.evaluate_pre_n_compiled_tree(tree, multiple_x_view)

    @inline evaluate_expr_tree_multiple_points(a :: Any, x :: Array{Array{T,1},1} )  where T <: Number = _evaluate_expr_tree_multiple_points(a, trait_expr_tree.is_expr_tree(a), x)
    @inline _evaluate_expr_tree_multiple_points(a, :: trait_expr_tree.type_not_expr_tree, x :: Array{Array{T,1},1} )  where T <: Number = error(" This is not an Expr tree")
    @inline _evaluate_expr_tree_multiple_points(a, :: trait_expr_tree.type_expr_tree, x :: Array{Array{T,1},1} ) where T <: Number = _evaluate_expr_tree_multiple_points(a, x)

    @inline evaluate_expr_tree_multiple_points(a :: Any, x :: Array{SubArray{T,1,Array{T,1},N,true},1} )  where N where T <: Number = _evaluate_expr_tree_multiple_points(a, trait_expr_tree.is_expr_tree(a), x)
    @inline _evaluate_expr_tree_multiple_points(a, :: trait_expr_tree.type_not_expr_tree, x :: Array{SubArray{T,1,Array{T,1},N,true},1})  where N where T <: Number = error(" This is not an Expr tree")
    @inline _evaluate_expr_tree_multiple_points(a, :: trait_expr_tree.type_expr_tree, x :: Array{SubArray{T,1,Array{T,1},N,true},1}) where N where T <: Number = _evaluate_expr_tree_multiple_points(a, x)

    @inline evaluate_expr_tree_multiple_points(a :: Any, x :: Array{SubArray{T,1,Array{T,1},N,false},1}) where N where T <: Number = _evaluate_expr_tree_multiple_points(a, trait_expr_tree.is_expr_tree(a), x)
    @inline _evaluate_expr_tree_multiple_points(a, :: trait_expr_tree.type_not_expr_tree, x :: Array{SubArray{T,1,Array{T,1},N,false},1}) where N where T <: Number = error(" This is not an Expr tree")
    @inline _evaluate_expr_tree_multiple_points(a, :: trait_expr_tree.type_expr_tree, x :: Array{SubArray{T,1,Array{T,1},N,false},1}) where N where T <: Number = _evaluate_expr_tree_multiple_points(a, x)
    @inline function _evaluate_expr_tree_multiple_points(expr_tree_cmp :: implementation_complete_expr_tree.complete_expr_tree , xs  :: Array{Array{T,1},1} ) where T <: Number
        op = trait_expr_tree.get_expr_node(expr_tree_cmp) :: trait_expr_node.ab_ex_nd
        number_x = length(xs)
        if trait_expr_node.node_is_operator(op :: trait_expr_node.ab_ex_nd) :: Bool == false
            temp = Vector{T}(undef, number_x)
            map!( x -> trait_expr_node._evaluate_node(op, x), temp, xs)
            return temp
        else
            children = trait_expr_tree.get_expr_children(expr_tree_cmp)
            n = length(children)
            lx = length(xs[1])
            res = Vector{T}(undef,number_x)
            temp = Array{T,2}(undef, n, number_x)
            for i in 1:n
                view(temp, i, :) .= _evaluate_expr_tree_multiple_points(children[i], xs)
            end
            for i in 1:number_x
                res[i] = trait_expr_node._evaluate_node(op,  view(temp,: ,i ) )
            end
            return res
        end
    end


    function _evaluate_expr_tree_multiple_points(expr_tree_cmp :: implementation_complete_expr_tree.complete_expr_tree,
                                                 xs  :: Array{SubArray{T,1,Array{T,1},N,true},1}) where N where T <: Number
        op = trait_expr_tree.get_expr_node(expr_tree_cmp) :: trait_expr_node.ab_ex_nd
        number_x = length(xs)
        if trait_expr_node.node_is_operator(op :: trait_expr_node.ab_ex_nd) :: Bool == false
            temp = Vector{T}(undef, number_x)
            map!( x -> trait_expr_node._evaluate_node(op, x), temp, xs)
            return temp
        else
            children = trait_expr_tree.get_expr_children(expr_tree_cmp)
            n = length(children)
            lx = length(xs[1])
            res = Vector{T}(undef,number_x)
            temp = Array{T,2}(undef, n, number_x)
            for i in 1:n
                view(temp, i, :) .= _evaluate_expr_tree_multiple_points(children[i], xs)
            end
            for i in 1:number_x
                res[i] = trait_expr_node._evaluate_node(op,  view(temp,: ,i ) )
            end
            return res
        end
    end


    function _evaluate_expr_tree_multiple_points(expr_tree_cmp :: implementation_complete_expr_tree.complete_expr_tree,
                                                 xs  ::  Array{SubArray{T,1,Array{T,1},N,false},1}) where N where T <: Number
        op = trait_expr_tree.get_expr_node(expr_tree_cmp) :: trait_expr_node.ab_ex_nd
        number_x = length(xs)
        if trait_expr_node.node_is_operator(op :: trait_expr_node.ab_ex_nd) :: Bool == false
            temp = Vector{T}(undef, number_x)
            map!( x -> trait_expr_node._evaluate_node(op, x), temp, xs)
            return temp
        else
            children = trait_expr_tree.get_expr_children(expr_tree_cmp)
            n = length(children)
            lx = length(xs[1])
            res = Vector{T}(undef,number_x)
            temp = Array{T,2}(undef, n, number_x)
            for i in 1:n
                view(temp, i, :) .= _evaluate_expr_tree_multiple_points(children[i], xs)
            end
            for i in 1:number_x
                res[i] = trait_expr_node._evaluate_node(op,  view(temp,: ,i ) )
            end
            return res
        end
    end


    @inline calcul_gradient_expr_tree(a :: Any, x :: Vector{}) = _calcul_gradient_expr_tree(a, is_expr_tree(a), x )
    @inline _calcul_gradient_expr_tree(a :: Any,:: trait_expr_tree.type_not_expr_tree, x :: Vector{}) = error("ce n'est pas un arbre d'expression")
    @inline _calcul_gradient_expr_tree(a :: Any,:: trait_expr_tree.type_expr_tree, x :: Vector{}) = _calcul_gradient_expr_tree(a, x)
    @inline calcul_gradient_expr_tree(a :: Any, x :: Vector{}, elmt_var :: Vector{Int}) = _calcul_gradient_expr_tree(a, is_expr_tree(a), x, elmt_var)
    @inline _calcul_gradient_expr_tree(a :: Any,:: trait_expr_tree.type_not_expr_tree, x :: Vector{}, elmt_var :: Vector{Int}) = error("ce n'est pas un arbre d'expression")
    @inline _calcul_gradient_expr_tree(a :: Any,:: trait_expr_tree.type_expr_tree, x :: Vector{}, elmt_var :: Vector{Int}) = _calcul_gradient_expr_tree(a, x, elmt_var)
    @inline _calcul_gradient_expr_tree(expr_tree, x :: Vector{T}) where T <: Number = ForwardDiff.gradient( evaluate_expr_tree(expr_tree), x)
    @inline _calcul_gradient_expr_tree(expr_tree, x :: Vector{}, elmt_var :: Vector{Int}) = ForwardDiff.gradient( evaluate_expr_tree(expr_tree, elmt_var), x)

    using ReverseDiff
    @inline calcul_gradient_expr_tree2(a :: Any, x :: Vector{}, elmt_var :: Vector{Int}) = _calcul_gradient_expr_tree2(a, is_expr_tree(a), x, elmt_var)
    @inline calcul_gradient_expr_tree2(a :: Any, x :: Vector{}) = _calcul_gradient_expr_tree2(a, is_expr_tree(a), x )
    @inline _calcul_gradient_expr_tree2(a :: Any,:: trait_expr_tree.type_not_expr_tree, x :: Vector{}) = error("ce n'est pas un arbre d'expression")
    @inline _calcul_gradient_expr_tree2(a :: Any,:: trait_expr_tree.type_expr_tree, x :: Vector{}) = _calcul_gradient_expr_tree2(a, x)
    @inline _calcul_gradient_expr_tree2(a :: Any,:: trait_expr_tree.type_not_expr_tree, x :: Vector{}, elmt_var :: Vector{Int}) = error("ce n'est pas un arbre d'expression")
    @inline _calcul_gradient_expr_tree2(a :: Any,:: trait_expr_tree.type_expr_tree, x :: Vector{}, elmt_var :: Vector{Int}) = _calcul_gradient_expr_tree2(a, x, elmt_var)
    @inline _calcul_gradient_expr_tree2(expr_tree, x :: Vector{T}) where T <: Number = ReverseDiff.gradient( evaluate_expr_tree(expr_tree), x)
    @inline _calcul_gradient_expr_tree2(expr_tree, x :: Vector{}, elmt_var :: Vector{Int}) = ReverseDiff.gradient( evaluate_element_expr_tree(expr_tree, elmt_var), x)

    @inline calcul_Hessian_expr_tree(a :: Any, x :: Vector{}) = _calcul_Hessian_expr_tree(a, is_expr_tree(a), x )
    @inline _calcul_Hessian_expr_tree(a :: Any,:: trait_expr_tree.type_not_expr_tree, x :: Vector{}) = error("ce n'est pas un arbre d'expression")
    @inline _calcul_Hessian_expr_tree(a :: Any,:: trait_expr_tree.type_expr_tree, x :: Vector{}) = _calcul_Hessian_expr_tree(a, x)
    @inline _calcul_Hessian_expr_tree(expr_tree, x :: Vector{}) = ForwardDiff.hessian( evaluate_expr_tree(expr_tree), x)




#=-----------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------
Fonction de test pour améliorer
-----------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------=#


# evaluate_expr_tree(a :: Any) = (x :: AbstractVector{} -> evaluate_expr_tree(a,x) )
# evaluate_expr_tree(a :: Any, elmt_var :: Vector{Int}) = (x :: AbstractVector{} -> evaluate_expr_tree(a,view(x,elmt_var) ) )
@inline evaluate_expr_tree2(a :: implementation_expr_tree.t_expr_tree, x :: AbstractVector{T})  where T <: Number = _evaluate_expr_tree2(a, trait_expr_tree.is_expr_tree(a), x)
@inline _evaluate_expr_tree2(a :: implementation_expr_tree.t_expr_tree, :: trait_expr_tree.type_not_expr_tree, x :: AbstractVector{T})  where T <: Number = error(" This is not an Expr tree")
@inline _evaluate_expr_tree2(a :: implementation_expr_tree.t_expr_tree, :: trait_expr_tree.type_expr_tree, x :: AbstractVector{T}) where T <: Number = _evaluate_expr_tree2(a, x)
function _evaluate_expr_tree2(expr_tree :: implementation_expr_tree.t_expr_tree , x  :: AbstractVector{T}) where T <: Number
    n_children = length(expr_tree.children)
    if n_children == 0
        return trait_expr_node._evaluate_node2(expr_tree.field,  x) :: T
    elseif n_children == 1
        temp = Vector{T}(undef,1)
        temp[1] = _evaluate_expr_tree2( expr_tree.children[1],  x) :: T
        return trait_expr_node._evaluate_node2(expr_tree.field, temp) :: T
    else
        field = expr_tree.field
        return mapreduce( y :: implementation_expr_tree.t_expr_tree  -> _evaluate_expr_tree2(y, x) :: T , trait_expr_node._evaluate_node2(field) , expr_tree.children :: Vector{implementation_expr_tree.t_expr_tree} ) :: T
    end
end


end
