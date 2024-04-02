include("generate_dist_matrix.jl")
include("swap.jl")
include("calculate.jl")
using Statistics

function two_opt_algorithm_first_improve(dist_matrix; calc_method)
    n = size(dist_matrix, 1)
    tour = initial_tour(n)
    tour_index = collect(1:n)
    # @show tour_index
    for i in 2:n
        for j in i+2:n
            # println("i: ", i, " j: ", j)
            if i == n-2 && j == n
                # @show calc_tour_length(tour, dist_matrix)
                # println("Finish")
                return
            end
            if abs(i - j) < 2 || abs(i - j) >= n - 1
                nothing
            else
                if calc_method == "direct"
                    i_index = findall(x -> x == i, tour_index)[1]
                    j_index = findall(x -> x == j, tour_index)[1]
                    if i_index > j_index
                        i_index, j_index = j_index, i_index
                    end
                    delta = cal_cost_swap_arc(tour[i_index-1], tour[j_index], dist_matrix)
                else
                    tour_length = calc_tour_length(tour, dist_matrix)
                    new_tour_index = copy(tour_index)
                    new_tour_, new_tour_index_ = swap_arc(i, j, new_tour_index)
                    new_tour_length = calc_tour_length(new_tour_, dist_matrix)
                    delta = new_tour_length - tour_length
                end
                if delta < 0
                    # if i == 1
                    #     println(tour[n], tour[j])
                    # else
                    #     println(tour[i-1], tour[j])
                    # end
                    tour, tour_index = swap_arc(i, j, tour_index)
                    # @show i, j
                    # @show tour_index
                    break
                end
            end
        end
    end
end

function two_opt_algorithm_all_possible(dist_matrix; calc_method)
    n = size(dist_matrix, 1)
    tour = initial_tour(n)
    tour_index = collect(1:n)
    improvement = true
    while improvement
        improvement = false
        best_delta = 0
        best_i, best_j = 1, 1  # Initialize best_i and best_j
        for i in 2:n
            for j in i+2:n
                if abs(i - j) < 2 || abs(i - j) >= n - 1
                    continue
                else
                    if calc_method == "direct"
                        i_index = findall(x -> x == i, tour_index)[1]
                        j_index = findall(x -> x == j, tour_index)[1]
                        if i_index > j_index
                            i_index, j_index = j_index, i_index
                        end
                        delta = cal_cost_swap_arc(tour[i_index-1], tour[j_index], dist_matrix)
                    else
                        tour_length = calc_tour_length(tour, dist_matrix)
                        new_tour_index = copy(tour_index)
                        new_tour_, new_tour_index_ = swap_arc(i, j, new_tour_index)
                        new_tour_length = calc_tour_length(new_tour_, dist_matrix)
                        delta = new_tour_length - tour_length
                    end
                    if delta < best_delta
                        best_delta = delta
                        best_i = i
                        best_j = j
                    end
                end
            end
        end
        if best_delta < 0
            tour, tour_index = swap_arc(best_i, best_j, tour_index)
            improvement = true
        end
    end
    # @show calc_tour_length(tour, dist_matrix)
    return tour
end

function simmulated_2_opt_algorithm(dist_matrix, T=3000.0, cooling_rate=0.9997, min_temp=0.1)
    n = size(dist_matrix, 1)
    tour = initial_tour(n)
    tour_index = collect(1:n)
    current_energy = calc_tour_length(tour, dist_matrix)

    while T > min_temp
        i = rand(2:n-2)
        j = rand(i+2:n)
        if abs(i - j) < 2 || abs(i - j) >= n - 1
            continue
        else
            new_tour_index = copy(tour_index)
            new_tour_, new_tour_index_ = swap_arc(i, j, new_tour_index)
            new_energy = calc_tour_length(new_tour_, dist_matrix)
            delta = new_energy - current_energy

            if delta < 0 || exp(-delta / T) > rand()
                tour, tour_index = new_tour_, new_tour_index_
                current_energy = new_energy
            end
        end
        T *= cooling_rate
    end
    # @show calc_tour_length(tour, dist_matrix)
    return tour
end

function main()
    n = 20
    X, Y, dist_matrix = generate_random_instance(n)
    println("-------------------------[Two-opt algorithm]-------------------------")
    ###########################[Accept the first improvement]###########################
    elapsed_time_direct = mean([@elapsed(two_opt_algorithm_first_improve(dist_matrix; calc_method = "direct")) for _ in 1:100])
    elapsed_time_else = mean([@elapsed(two_opt_algorithm_first_improve(dist_matrix; calc_method = "else")) for _ in 1:100])
    println("two_opt_algorithm_first_improve")
    println("Average execution time for 'direct': ", elapsed_time_direct, " seconds")
    println("Average execution time for 'indirect': ", elapsed_time_else, " seconds")
    if elapsed_time_direct < elapsed_time_else
        println("Direct method is faster")
    else
        println("Indirect method is faster")
    end
    println()
    ###########################[Accept among all possible improvements]#################
    elapsed_time_direct = mean([@elapsed(two_opt_algorithm_all_possible(dist_matrix; calc_method = "direct")) for _ in 1:100])
    elapsed_time_else = mean([@elapsed(two_opt_algorithm_all_possible(dist_matrix; calc_method = "else")) for _ in 1:100])
    println("two_opt_algorithm_all_possible")
    println("Average execution time for 'direct': ", elapsed_time_direct, " seconds")
    println("Average execution time for 'indirect': ", elapsed_time_else, " seconds")
    if elapsed_time_direct < elapsed_time_else
        println("Direct method is faster")
    else
        println("Indirect method is faster")
    end
    println()
    ################################[Simmulated Annealing]##############################
    elapsed_time_simmulated = mean([@elapsed(simmulated_2_opt_algorithm(dist_matrix)) for _ in 1:100])
    println("simmulated_2_opt_algorithm")
    println("Average execution time for 'direct': ", elapsed_time_simmulated, " seconds")
    println("--------------------------------------------------------------------")
end

main()