# Modelo referente ao artigo "Inventory sharing strategy and optimization for reusable transport items"
# DOI: https://doi.org/10.1016/j.ijpe.2020.107742
# Autor do codigo: Lucas Moreira Ribeiro
# RA: 20.1.4972

# Explicações:
# _aoc => amount of containers

param qtd_cmc, integer, >= 0 := 2;
param qtd_clientes, integer, >= 0 := 2;

# Conjuntos
set I := CMC1, CMC2# CMCs
set J; := 1..qtd_clientes; # Customers
set Ki; 
set Ni, within I union J;
set N{I}, union J, 

# Parametros fora do artigo
set Ti :=  T1, T2;
set Oi := O1 O2;

set cmc_custumer, within Oi cross J;
set nodes, within Oi union Ti union J

# Paramentros
param R_transportation_distance{(i, j) in N} #TODO: Note that 𝑅0 𝑖 ,𝑇 𝑖 , ∀𝑖 ∈ 𝐼 is 0
param U_unit_transportation_cost{(i, j) in N}
param V_volume_conversion_factor_of_c #TODO: é escalar?
param D_demand_for_c_from_custumer{J};
param S_supply_of_containers{I};
param C_loading_capacity_of_each_veicle;
param M_large_positive_number;
param small_positive_number;

# Variaveis de decisão
var x_transportation_aoc{i in Oi, j in J};
var z_binary{orig in nodes, dest in nodes, k in Ki[orig]) in nodes}, binary #todo:
var y_vehicle_loads_when_arrives_at_node{(k,j) in Ki union Ni} # todo: erro
var w_transport_oac_from_cmc_to_custumer_by_vehicle #todo:
var v_binary, binary, if x_transportation_aoc > 0 then 1 else 0; #todo: erro

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


data;


set Ki := K21, K22, K11, K12;

param R_transportation_distance :=  # Matriz de distancias
            CUSTOMER1  COSTUMER2    T1     T2
O1              1          5       0        999999999
O2              1          0       99999
CUSTOMER1      1           1          1         1
COSTUMER2
param U_unit_transportation_cost := 
param V_volume_conversion_factor_of_c := 50
param D_demand_for_c_from_custumer := 
CUSTOMER1 4
CUSTOMER2 3
param S_supply_of_containers := 
param C_loading_capacity_of_each_veicle := 
K11 3
K21 3
K22 3
K12 3
param M_large_positive_number := 99999
param small_positive_number := 0.0009
