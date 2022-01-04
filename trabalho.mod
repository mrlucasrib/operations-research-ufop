# Modelo referente ao artigo "Inventory sharing strategy and optimization for reusable transport items"
# DOI: https://doi.org/10.1016/j.ijpe.2020.107742
# Autor do codigo: Lucas Moreira Ribeiro
# RA: 20.1.4972

# Explicações:
# _aoc => amount of containers

# Conjuntos
set I;  # CMCs
set J;  # Customers
set Ki; # Veicles deployed
#set N,i union J, 

# Parametros não declarados na tabela
set Ti, within I cross I;
set Oi, within I cross I;

# Conjuntos continuação
set N, within (Oi union Ti) union J


#set cmc_custumer, within Oi cross J;
#set nodes, within Oi union Ti union J

# Paramentros
param R_transportation_distance{(i, j) in N};
param U_unit_transportation_cost{(i, j) in N};
param V_volume_conversion_factor_of_c;
param D_demand_for_c_from_custumer{J};
param S_supply_of_containers{I};
param C_loading_capacity_of_each_veicle{Ki};
param M_large_positive_number;
param small_positive_number;

# Variaveis de decisão
var x_transportation_aoc{i in I, j in J} >= 0, integer;
var z_binary{j in Ni, jj in Ni, k in Ki}, binary;
var y_vehicle_loads_when_arrives_at_node{k in Ki, n in Ni}, >= 0;
var w_transport_oac_from_cmc_to_custumer_by_vehicle{J, I, Ki}, >= 0, integer;
var v_binary{I,J}, binary, if x_transportation_aoc > 0 then 1 else 0; #todo: erro

# Função objetivo
minimize Z{i in I, j in J}: (U_unit_transportation_cost[i, j] * R_transportation_distance[i, j] * V_volume_conversion_factor_of_c * x_transportation_aoc[i, j] + 
    sum{n in Ni, k in Ki}(U_unit_transportation_cost[j, n] *  R_transportation_distance[j, n] * V_volume_conversion_factor_of_c * z_binary[j, n, k]));


# Constraint (2)
subject to demands_are_fulfilled {j in J}:
    sum{i in I} x_transportation_aoc[i,j] >= D_demand_for_c_from_custumer[j];

# Constraint (3)
subject to e total nu_of_c_shipped_from_CMC_be_less_than_onhand_containers {i in I}:
    sum{j in J} x_transportation_aoc[i,j] <= S_supply_of_containers[i];

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
    sum{n in Ni diff Ti} z_binary[n, j, k] = sum{n2 in Ni} z_binary[j, n2, jk] <= x_transportation_aoc[i,j];
    
# Constraint (8) # daq ok pra frente
subject to if_customer_is_covered_by_CMC_then_at_least_one_vehicle_should_visit_the_customer_c8 {k in K, u in J}:
    sum{j in Ni diff Ti} z_binary[j, u, j] >= v_binary[i, u];

# Constraint (9)
subject to if_customer_is_covered_by_CMC_then_at_least_one_vehicle_should_visit_the_customer_c9 {i in I, k in Ki, u in J}:
    sum{j in Ni diff  Oi} z_binary[j,u,k] <= M_large_positive_number * v_binary[i, u];

# Constraint (10)
subject to guarantee_that_any_vehicle_starts_from_0i_and_finally_visits_Ti_c10 {i in I, k in Ki}:
    sum{j in Ni diff Oi} z_binary[Oi, j, k] = 1; #TODO: Possivel erro em usar Oi como index

# Constraint (11)
subject to guarantee_that_any_vehicle_starts_from_0i_and_finally_visits_Ti_c11 {i in I, k in Ki}:
    sum{j in Ni diff Oi} z_binary[j,Ti, k] = 1; #TODO: Possivel erro em usar Ti como index

# Constraint (12)
subject to eliminate_subtours_c12 {i in I, j in Ni diff Ti, jj in Ni diff (J union Oi), k in Ki}: #TODO: Possivel erro em union
    y_vehicle_loads_when_arrives_at_node[j,k] - y_vehicle_loads_when_arrives_at_node[jj, k] + C_loading_capacity_of_each_veicle * z_binary[j, jj, k] <= C_loading_capacity_of_each_veicle + w_transport_oac_from_cmc_to_custumer_by_vehicle[i, j, k];

# Constraint (13)
subject to eliminate_subtours_c13 {i in I, j in J, k in Ki}:
    w_transport_oac_from_cmc_to_custumer_by_vehicle[i,j, k] <= y_vehicle_loads_when_arrives_at_node[j, k] <= C_loading_capacity_of_each_veicle;

# Constraint (14)
subject to scopes_for_all_decision_variables {i in I, j in J, k in Ki}: # TODO: ERRO
    w_transport_oac_from_cmc_to_custumer_by_vehicle[i,j,k] * y_vehicle_loads_when_arrives_at_node[j,k] * w_transport_oac_from_cmc_to_custumer_by_vehicle[i, j, k] >= 0; C_loading_capacity_of_each_veicle;

solve;

data;

param: M_large_positive_number := 99999
param: small_positive_number := 0.0009

set I := CMC1,CMC2;
set J := COSTUMER1, COSTUMER2;
set Ki := K21, K22, K11, K12;

param: N: R_transportation_distance : 
CMC1        COSTUMER1   500
CMC1        COSTUMER2   235
CMC2        COSTUMER1   420
CMC2        COSTUMER2   193

param: N : U_unit_transportation_cost := 
CMC1        COSTUMER1   50
CMC1        COSTUMER2   30
CMC2        COSTUMER1   40
CMC2        COSTUMER2   40

param: V_volume_conversion_factor_of_c := 50

param: D_demand_for_c_from_custumer := 
CUSTOMER1 4
CUSTOMER2 3

param: S_supply_of_containers := 
CMC1 200
CMC2 150

param: C_loading_capacity_of_each_veicle := 
K11 30
K21 35
K22 50
K12 70
