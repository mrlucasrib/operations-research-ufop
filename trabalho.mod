# Modelo referente ao artigo "Inventory sharing strategy and optimization for reusable transport items"
# DOI: https://doi.org/10.1016/j.ijpe.2020.107742
# Disciplina de Introdução a Otimização -   BCC342
# Universidade Federal de Ouro Preto
# Autor do codigo: Lucas Moreira Ribeiro
# RA: 20.1.4972

# Explicações:
# _aoc => amount of containers

# Conjuntos
set I := 1..3;  # CMCs
set J := 1..5;  # Customers
set Ki{I}; # Veicles deployed

# Parametros não declarados na tabela
param Oi{I};
param Ti{I};

set Ni {i in I} := {Oi[i],Ti[i]} union J;
set N := 1..11;

# Paramentros
param R_transportation_distance{i in N, j in N};
param U_unit_transportation_cost{i in N, j in N};
param V_volume_conversion_factor_of_c;

param D_demand_for_c_from_custumer{J};
param S_supply_of_containers{I};
param C_loading_capacity_of_each_veicle;
param M_large_positive_number := 99999;
param small_positive_number := 0.0009;

# Variaveis de decisão
var x_transportation_aoc{i in I, j in J} >= 0, integer;
var z_binary{i in I, k in Ki[i], j in Ni[i],jj in Ni[i]}, binary;
var y_vehicle_loads_when_arrives_at_node{i in I, j in Ni[i], k in Ki[i]}, >= 0;
var w_transport_oac_from_cmc_to_custumer_by_vehicle{i in I,j in J, k in Ki[i]}, >= 0, integer;
var v_binary{i in I,j in J}, binary; #, if x_transportation_aoc[i,j] > 0 then 1 else 0; #todo: erro

# Função objetivo
minimize Z: sum{i in I, j in J} U_unit_transportation_cost[i, j] * R_transportation_distance[i, j] * V_volume_conversion_factor_of_c * x_transportation_aoc[i, j] + 
    sum{i in I, j in Ni[i], jj in Ni[i], k in Ki[i]}U_unit_transportation_cost[j, jj] *  R_transportation_distance[j, jj] * V_volume_conversion_factor_of_c * 
    z_binary[i, k ,j, jj];

# Constraint (2)
subject to demands_are_fulfilled {j in J}:
    sum{i in I} x_transportation_aoc[i,j] >= D_demand_for_c_from_custumer[j];

# Constraint (3)
subject to e_total_nu_of_c_shipped_from_CMC_be_less_than_onhand_containers {i in I}:
    sum{j in J} x_transportation_aoc[i,j] <= S_supply_of_containers[i];

# Constraint (4)
subject to Link_w_x {i in I, j in J}:
    sum{k in Ki[i]} w_transport_oac_from_cmc_to_custumer_by_vehicle[i,j, k] == x_transportation_aoc[i, j];

# Constraint (5)
subject to Define_decision_variable_v {i in I, j in J}:
    x_transportation_aoc[i,j] <= M_large_positive_number * v_binary[i, j];

# Constraint (6)
subject to Define_decision_the_variable_v {i in I, j in J}:
    small_positive_number * v_binary[i, j] <= x_transportation_aoc[i,j];

# Constraint (7) 
# var z_binary{i in N, k in Ki[i], j in Ni[i],jj in Ni[i]}, binary;
display {i in I} {Ni[i]} diff {Ti[i]};
subject to Flow_conservation_conditions {i in I, k in Ki[i], u in J}:
    sum{j in Ni[i] diff {Ti[i]}} 
    z_binary[i, j, u, k] = 1#= sum{jj in Ni[i]} z_binary[i, u, jj, k];
/*    
# Constraint (8) 
subject to if_customer_is_covered_by_CMC_then_at_least_one_vehicle_should_visit_the_customer_c8 {i in I, k in Ki[i], u in J}:
    sum{j in Ni[i] diff Ti[i]} z_binary[j, u, j] >= v_binary[i, u];

# Constraint (9)
subject to if_customer_is_covered_by_CMC_then_at_least_one_vehicle_should_visit_the_customer_c9 {i in I, k in Ki, u in J}:
    sum{j in Ni diff  Oi} z_binary[j,u,k] <= M_large_positive_number * v_binary[i, u];

# Constraint (10)
subject to guarantee_that_any_vehicle_starts_from_0i_and_finally_visits_Ti_c10 {i in I, k in Ki}:
    sum{j in Ni[i] diff Oi[i]} z_binary[i, Oi[i], j, k] = 1;

# Constraint (11)
subject to guarantee_that_any_vehicle_starts_from_0i_and_finally_visits_Ti_c11 {i in I, k in Ki}:
    sum{j in Ni[i] diff Oi} z_binary[i, j, Ti[i], k] = 1; 
    
# Constraint (12)
subject to eliminate_subtours_c12 {i in I, j in Ni diff Ti, jj in Ni diff (J union Oi), k in Ki}: #TODO: Possivel erro em union
    y_vehicle_loads_when_arrives_at_node[j,k] - y_vehicle_loads_when_arrives_at_node[jj, k] + C_loading_capacity_of_each_veicle * z_binary[j, jj, k] <= C_loading_capacity_of_each_veicle + w_transport_oac_from_cmc_to_custumer_by_vehicle[i, j, k];
*/
# Constraint (13)
subject to eliminate_subtours_c13 {i in I, j in J, k in Ki[i]}:
    w_transport_oac_from_cmc_to_custumer_by_vehicle[i, j, k] <= 0;
    
subject to eliminate_subtours_c13_2 {i in I, j in Ni[i], k in Ki[i]}:
 y_vehicle_loads_when_arrives_at_node[i, j, k] <= C_loading_capacity_of_each_veicle;

# Constraint (14)
subject to scopes_for_all_decision_variables_c14_1 {i in I, j in J, k in Ki[i]}:
    w_transport_oac_from_cmc_to_custumer_by_vehicle[i,j,k] >= C_loading_capacity_of_each_veicle; 

subject to scopes_for_all_decision_variables_c14_2 {i in I, j in J, k in Ki[i]}:
    y_vehicle_loads_when_arrives_at_node[i, j, k] >= 0;

subject to scopes_for_all_decision_variables_c14_3 {i in I, j in J, k in Ki[i]}:
    w_transport_oac_from_cmc_to_custumer_by_vehicle[i, j, k] >= 0;


solve;

data;

set Ki[1] := 1,2;
set Ki[2] := 3,4; 
set Ki[3] := 5; 

param Oi :=
1 6
2 8
3 10;
param Ti :=
1 7
2 9
3 11;

param R_transportation_distance :
    1       2       3       4       5       6       7       8       9       10      11 :=
1   0       500     300     250     200     220     320     310     100     140     180
2   310     0       400     210     270     490     230     210     125     143     120
3   100     110     0       250     410     130     210     240     125     190     130
4   130     210     410     0       452     142     128     256     364     445     123
5   140     240     500     210     0       140     32      28      201     320     210
6   180     290     428     381     127     0       120     134     410     177     254
7   500     510     244     321     322     345     0       136     320     182     199
8   250     102     203     204     400     450     40      0       198     199     200
9   147     148     452     201     203     240     501     270     0       140     150
10  170     123     321     456     506     401     203     420     256     0       420
11  140     25      62      120     250     310     250     214     420     256     0;

param U_unit_transportation_cost :
    1    2      3    4     5     6     7     8     9     10     11 :=
1  0     50    30    25    20    22    32    31    10    14    180
2  31    0     40    21    27    49    23    21    12    14    120
3  10    11    0     25    41    13    21    24    12    19    130
4  13    21    41    0     45    14    12    25    36    44    123
5  14    24    50    21    0     14    3     2     20    32    210
6  18    29    42    38    12    0     12    13    41    17    254
7  50    51    24    32    32    34    0     13    32    18    199
8  25    10    20    20    40    45    4     0     19    19    200
9  14    14    45    20    20    24    50    27    0     14    150
10 17    12    32    45    50    40    20    42    25    0     420
11 14    2     6     12    25    31    25    21    42    25    0;
param V_volume_conversion_factor_of_c := 50;


param D_demand_for_c_from_custumer :=
1 8 
2 4
3 3
4 5
5 2;

param S_supply_of_containers := 
1   200
2   150
3   100;

param C_loading_capacity_of_each_veicle := 5;
