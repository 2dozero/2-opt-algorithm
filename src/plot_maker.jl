using Random
using Plots
import Plots: savefig
using ImageMagick

function generate_random_instance(n, seed = 1234)
    Random.seed!(seed)
    x = rand(n) .* 1000
    y = rand(n) .* 1000
    dist_matrix = zeros(n, n)
    for i in 1:n
        for j in i+1:n
            dist_matrix[i, j] = sqrt((x[i] - x[j])^2 + (y[i] - y[j])^2)
            dist_matrix[j, i] = dist_matrix[i, j]
        end
    end
    return x, y, dist_matrix
end

# function generate_random_instance(n, seed = 1234)
#     Random.seed!(seed)
#     angles = rand(n) .* 2 .* π  # Generate random angles
#     radius = 500  # Radius of the circle
#     x = cos.(angles) .* radius .+ radius  # Calculate x coordinates
#     y = sin.(angles) .* radius .+ radius  # Calculate y coordinates
#     dist_matrix = zeros(n, n)
#     for i in 1:n
#         for j in i+1:n
#             dist_matrix[i, j] = sqrt((x[i] - x[j])^2 + (y[i] - y[j])^2)
#             dist_matrix[j, i] = dist_matrix[i, j]
#         end
#     end
#     return x, y, dist_matrix
# end

# function generate_random_instance(n, seed = 1234)
#     Random.seed!(seed)
#     angles = sort(rand(n) .* 2 .* π)  # Generate and sort random angles
#     radius = 500  # Radius of the circle
#     x = cos.(angles) .* radius .+ radius  # Calculate x coordinates
#     y = sin.(angles) .* radius .+ radius  # Calculate y coordinates
#     dist_matrix = zeros(n, n)
#     for i in 1:n
#         for j in i+1:n
#             dist_matrix[i, j] = sqrt((x[i] - x[j])^2 + (y[i] - y[j])^2)
#             dist_matrix[j, i] = dist_matrix[i, j]
#         end
#     end
#     return x, y, dist_matrix
# end

# function generate_random_instance(n, seed = 1234)
#     Random.seed!(seed)
#     angles = sort(rand(n) .* 2 .* π)  # Generate and sort random angles
#     radius = 500  # Radius of the circle
#     radius_offsets = randn(n) .* 50  # Generate random radius offsets
#     x = cos.(angles) .* (radius .+ radius_offsets) .+ radius  # Calculate x coordinates
#     y = sin.(angles) .* (radius .+ radius_offsets) .+ radius  # Calculate y coordinates
#     dist_matrix = zeros(n, n)
#     for i in 1:n
#         for j in i+1:n
#             dist_matrix[i, j] = sqrt((x[i] - x[j])^2 + (y[i] - y[j])^2)
#             dist_matrix[j, i] = dist_matrix[i, j]
#         end
#     end
#     return x, y, dist_matrix
# end



function initial_tour(n)
    tour = [(i, i+1) for i in 1:n-1]
    push!(tour, (n, 1))
    return tour
end

function cal_cost_swap_arc(arc1, arc2, dist_matrix)
    (i, j) = arc1
    (k, l) = arc2
    cost = dist_matrix[i, k] + dist_matrix[j, l] - dist_matrix[i, j] - dist_matrix[k, l]
    return cost
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

function calc_tour_length(tour, dist_matrix)
    n = length(tour)
    tour_length = 0
    for i in 1:n
        tour_length += dist_matrix[tour[i][1], tour[i][2]]
    end
    return tour_length
end

function plot_tour(tour, coords, filename)
    x_coords = [coords[tour[i][1], 1] for i in 1:length(tour)]
    y_coords = [coords[tour[i][1], 2] for i in 1:length(tour)]
    
    # Add the first point at the end to close the tour
    push!(x_coords, coords[tour[1][1], 1])
    push!(y_coords, coords[tour[1][1], 2])

    plt = plot(x_coords, y_coords, legend = false)
    scatter!(plt, x_coords, y_coords, color = :red, markersize = 4)
    savefig(plt, filename)
end


function two_opt_algorithm_all_possible(dist_matrix, coords; calc_method)
    n = size(dist_matrix, 1)
    tour = initial_tour(n)
    tour_index = collect(1:n)

    # Plot the initial tour
    plot_tour(tour, coords, "images/initial_tour.png")
    num = 0
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
            num += 1

            # Plot the updated tour
            # plot_tour(tour, coords, "images/tour_after_swap_$(best_i)_$(best_j).png")
            plot_tour(tour, coords, "images/tour_after_swap_$(num).png")
        end
    end
    return tour
end


# Generate random instance
n = 100  # Number of nodes
seed = 123  # Seed for random number generator
x, y, dist_matrix = generate_random_instance(n, seed)
coords = hcat(x, y)  # Combine x and y into a 2D array

# Run the 2-opt algorithm
two_opt_algorithm_all_possible(dist_matrix, coords, calc_method = "direct")