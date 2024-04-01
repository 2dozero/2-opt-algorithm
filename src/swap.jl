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