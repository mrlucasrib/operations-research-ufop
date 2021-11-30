
minimize Z{i in I, j in J}: sum{}(unit_transportation_cost[i, j] * transportation_distance[i, j] * volume_conversion_factor_oac * x_transportation_aoc[i, j]) + 
    sum{n in Ni, k in Ki}(unit_transportation_cost[j, n] *  transportation_distance[j, n] * volume_conversion_factor_oac * z_binary[j, n, k);
    
# Constraint (4)
subject to Link_w_x {i in I, j in J}:
    sum{k in Ki} w_transport_oac_from_cmc_to_custumer_by_vehicle[i,j, k] = x_transportation_aoc[i, j];

# Constraint (5)
subject to Define_decision_variable_v {i in I, j in J}:
    x_transportation_aoc[i,j] <= M_large_positive_number * v[i, j];

# Constraint (6)
subject to Define_decision_the_variable_v {i in I, j in J}:
    small_positive_number * v[i, j] <= x_transportation_aoc[i,j];

# Constraint (7)
subject to Flow_conservation_conditions {i in I, j in J}:
    sum{n in Ni} z_binary[n, j, k] = sum{n2 in Ni} z_binary[j, n2, jk] <= x_transportation_aoc[i,j];