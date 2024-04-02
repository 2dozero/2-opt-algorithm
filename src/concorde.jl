using Concorde
include("main.jl")



n = 150
X, Y, dist_matrix = generate_random_instance(n)
opt_tour, opt_len = Concorde.solve_tsp(X, Y; dist = "EUC_2D")
println("-------------------------[Two-opt algorithm]-------------------------")
###########################[Accept the first improvement]###########################
# two_opt_algorithm_first_improve(dist_matrix; calc_method = "direct")
# two_opt_algorithm_first_improve(dist_matrix; calc_method = "else")
println("Opt_tour length by Concorde : ", opt_len)
# println("two_opt_algorithm_first_improve")
# println("Optimality gap for 'direct': ")

# println("Optimality gap for 'indirect': ")
# println()
# ###########################[Accept among all possible improvements]#################
# two_opt_algorithm_all_possible(dist_matrix; calc_method = "direct")
# two_opt_algorithm_all_possible(dist_matrix; calc_method = "else")
# println()
# ################################[Simmulated Annealing]##############################
simmulated_2_opt_algorithm(dist_matrix)
println("simmulated_2_opt_algorithm")
# println("Average execution time for 'direct': ", elapsed_time_simmulated, " seconds")
println("--------------------------------------------------------------------")
