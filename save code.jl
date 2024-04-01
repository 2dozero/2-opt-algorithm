function generate_random_instance(n, seed = 0)
    x = rand(n) .* 1000
    y = rand(n) .* 1000
    dist_matrix = zeros(n, n)
    for i in 1:n
        for j in i+1:n
            dist_matrix[i, j] = sqrt((x[i] - x[j])^2 + (y[i] - y[j])^2)
            dist_matrix[j, i] = dist_matrix[i, j]
        end
    end
    return dist_matrix
end

function initial_tour(n)
    tour = [(i, i+1) for i in 1:n-1]
    push!(tour, (n, 1))
    return tour
end

function swap_arc(i, j, tour_index)
    # tour_index[i:j] = reverse(tour_index[i:j])
    i_index = findall(x -> x == i, tour_index)[1]
    j_index = findall(x -> x == j, tour_index)[1]
    if i_index > j_index
        i_index, j_index = j_index, i_index
    end
    tour_index[i_index:j_index] = reverse(tour_index[i_index:j_index])
    # @show tour_index
    n = length(tour_index)
    tour = [(tour_index[i], tour_index[i % n + 1]) for i in 1:n]
    return tour, tour_index
end

function cal_cost_swap_arc(arc1, arc2, dist_matrix)
    (i, j) = arc1
    (k, l) = arc2
    cost = dist_matrix[i, k] + dist_matrix[j, l] - dist_matrix[i, j] - dist_matrix[k, l]
    return cost
end

function calc_tour_length(tour, dist_matrix)
    n = length(tour)
    tour_length = 0
    for i in 1:n
        tour_length += dist_matrix[tour[i][1], tour[i][2]]
    end
    return tour_length
end

function two_opt_algorithm(dist_matrix; calc_method)
    n = size(dist_matrix, 1)
    tour = initial_tour(n)
    tour_index = collect(1:n)
    # @show tour_index
    for i in 2:n
        for j in i+2:n
            # println("i: ", i, " j: ", j)
            if i == n-2 && j == n
                @show calc_tour_length(tour, dist_matrix)
                println("Finish")
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

function main()
    n = 100
    dist_matrix = generate_random_instance(n)
    elapsed_time_direct = @elapsed begin
        two_opt_algorithm(dist_matrix; calc_method = "direct")
    end
    elapsed_time_else = @elapsed begin
        two_opt_algorithm(dist_matrix; calc_method = "else")
    end
    println("Execution time for 'direct': ", elapsed_time_direct, " seconds")
    println("Execution time for 'indirect': ", elapsed_time_else, " seconds")
    if elapsed_time_direct < elapsed_time_else
        println("Direct method is faster")
    else
        println("Indirect method is faster")
    end
end

main()

