include("generate_dist_matrix.jl")
include("main.jl")

function experiment(dist_matrix)
    T_values = [1000.0, 2000.0, 3000.0]
    cooling_rate_values = collect(range(0.9999, stop=0.9, step=-0.0001))
    min_temp_values = [0.1, 0.01, 0.001]

    best_tour_length = Inf
    best_parameters = (0.0, 0.0, 0.0)

    for T in T_values
        for cooling_rate in cooling_rate_values
            for min_temp in min_temp_values
                tour = simmulated_2_opt_algorithm(dist_matrix, T, cooling_rate, min_temp)
                tour_length = calc_tour_length(tour, dist_matrix)
                if tour_length < best_tour_length
                    best_tour_length = tour_length
                    best_parameters = (T, cooling_rate, min_temp)
                end
            end
        end
    end

    return best_parameters
end

n = 50
dist_matrix = generate_random_instance(n)

best_parameters = experiment(dist_matrix)

println("Best parameters: ", best_parameters)