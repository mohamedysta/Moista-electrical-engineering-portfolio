% Microgrid Simulation with Nikaido-Isoda Relaxation Method and Graphs
clear; clc;

% Parameters
N = 15; % Number of participants
T = 24; % Time horizon in hours
B = 10; % Battery size (kWh)

% Participant PV Generation and Consumption for each time block 
% PV Generation 
Psolar = repmat([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2.25, 2.25, 4.5, 5, 4.5, 2.25, 2.25, 0, 0, 0, 0, 0, 0, 0], N, 1);

%Consumption - Load Demand 
Ei1= [0.5, 0.4, 0.3, 0.3, 0.3, 0.5, 1.5, 2.0, 2.0, 1.5, 1.0, 1.0, 1.5, 1.5, 1.5, 1.5, 2.0, 2.5, 3.0, 3.5, 2.5, 1.5, 1.0, 0.7]; 
Ei2= [1.5, 1.2, 1.0, 1.0, 1.0, 2.0, 4.0, 5.5, 6.0, 4.0, 3.5, 3.0, 4.0, 4.5, 5.0, 5.5, 6.5, 7.0, 6.0, 5.0, 4.0, 3.0, 2.0, 1.5]; 
Ei3= [0.8, 0.7, 0.5, 0.5, 0.5, 0.7, 1.5, 2.5, 3.0, 2.0, 1.5, 1.5, 2.0, 2.5, 2.5, 2.5, 2.0, 2.0, 2.5, 2.0, 1.5, 1.0, 0.8, 0.8]; 
Ei4= [1.2, 1.0, 0.9, 0.8, 0.8, 1.0, 2.0, 3.0, 4.0, 3.5, 3.0, 2.5, 3.0, 3.5, 4.0, 5.0, 6.0, 6.5, 5.5, 4.5, 3.5, 2.5, 1.5, 1.3]; 
Ei5= [2.0, 1.8, 1.5, 1.5, 1.5, 3.0, 6.0, 7.0, 8.0, 9.0, 5.5, 4.0, 4.5, 5.0, 6.0, 6.5, 7.0, 8.0, 9.0, 10.0, 8.0, 6.0, 5.0, 4.0]; 
Ei6= [1.5, 1.3, 1.2, 1.0, 0.9, 1.2, 1.8, 2.5, 3.0, 3.5, 2.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0, 5.5, 4.5, 3.5, 2.5, 1.5, 1.5]; 
Ei7= [1.0, 0.8, 0.7, 0.6, 0.6, 1.0, 2.0, 3.0, 4.0, 4.5, 5.0, 4.0, 4.5, 5.5, 5.5, 5.0, 4.0, 3.0, 3.5, 2.5, 2.0, 1.5, 1.0, 1.0]; 
Ei8= [1.0, 0.8, 0.7, 0.6, 0.6, 0.8, 1.5, 2.0, 3.0, 2.5, 2.0, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 4.0, 3.0, 2.0, 1.5, 1.0, 0.7, 0.8]; 
Ei9= [1.2, 1.0, 1.0, 0.8, 0.8, 1.5, 3.0, 4.0, 5.0, 4.0, 3.0, 3.5, 4.0, 5.0, 5.5, 6.0, 6.5, 6.0, 5.0, 4.0, 3.0, 2.0, 1.5, 1.3]; 
Ei10= [1.0, 0.8, 0.7, 0.6, 0.6, 0.8, 1.5, 2.5, 3.0, 3.5, 3.0, 2.5, 3.0, 3.5, 4.0, 5.0, 5.5, 6.0, 5.0, 4.0, 3.0, 2.0, 1.5, 1.3]; 
Ei11= [2.5, 2.0, 1.8, 1.5, 1.5, 3.0, 5.0, 7.0, 8.0, 6.0, 5.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 10.0, 8.0, 6.0, 5.0, 4.0]; 
Ei12= [0.4, 0.3, 0.3, 0.2, 0.2, 0.3, 0.7, 1.0, 1.5, 1.2, 1.0, 0.9, 1.0, 1.0, 1.1, 1.2, 1.5, 1.7, 1.5, 1.2, 1.0, 0.8, 0.6, 0.5]; 
Ei13= [1.8, 1.5, 1.2, 1.0, 1.0, 1.2, 1.5, 1.8, 2.0, 1.5, 1.0, 1.0, 1.5, 1.5, 2.0, 2.5, 3.0, 3.5, 3.0, 2.0, 1.5, 1.2, 1.4, 1.6]; 
Ei14= [2.0, 1.8, 1.5, 1.5, 1.5, 3.0, 6.0, 7.0, 8.0, 9.0, 5.5, 4.0, 4.5, 5.0, 6.0, 6.5, 7.0, 8.0, 9.0, 8.0, 6.0, 5.0, 4.0, 3.0]; 
Ei15= [0.5, 0.4, 0.3, 0.3, 0.3, 0.4, 0.8, 1.5, 2.0, 1.5, 1.0, 1.0, 1.5, 2.0, 2.5, 2.0, 1.5, 1.0, 1.0, 0.8, 0.7, 0.5, 0.4, 0.3]; 

E_load = vertcat(Ei1, Ei2, Ei3, Ei4, Ei5, Ei6, Ei7, Ei8, Ei9, Ei10, Ei11, Ei12, Ei13, Ei14, Ei15); % Nx24 Load Matrix

% Price matrices
p_buy = repmat([0.1425, 0.1425, 0.1425, 0.1425, 0.1425, 0.1425, 0.1425, 0.1425, 0.1425, 0.1425, ...
                0.1967, 0.1967, 0.1967, 0.1967, 0.1967, 0.1967, 0.3462, 0.3462, 0.3462, 0.3462, ...
                0.1967, 0.1967, 0.1967, 0.1967], N, 1);
p_sell = repmat(0.074 * ones(1, T), N, 1);
p_trade = p_sell;

% Storage and results tracking
strategies = zeros(N, T); % Initial energy trade strategy
BESS_capacity = zeros(N, T); % Battery storage
profit = zeros(1, N); % Participant profit
cost = zeros(1, N); % Participant cost
revenue = zeros(1, N); % Participant revenue
additional_revenue = zeros(1, N); % Additional revenue
savings = zeros(1, N); % Savings
renewable_traded = zeros(1, N); % Renewable energy traded

% Nikaido-Isoda Relaxation Method
max_iter = 100; % Maximum iterations
tolerance = 1e-3; % Convergence tolerance
lambda = 0.1; % Relaxation parameter

% Calculate total cost if participants buy all energy from the grid
total_cost_direct_grid = zeros(1, N);
for participant = 1:N
    total_cost_direct_grid(participant) = sum(E_load(participant, :) .* p_buy(participant, :));
end

% Main Loop for Nikaido-Isoda Relaxation Method
for iter = 1:max_iter
    prev_strategies = strategies; 

    for participant = 1:N
        % Optimize strategy
        optimal_strategy = optimize_strategy(participant, Psolar, E_load, p_buy, p_sell, B, BESS_capacity, T);
        
        % Update strategy using relaxation
        strategies(participant, :) = strategies(participant, :) + ...
            lambda * (optimal_strategy - strategies(participant, :));
    end
    
    % Check for convergence
    if max(abs(strategies(:) - prev_strategies(:))) < tolerance
        disp(['Converged after ', num2str(iter), ' iterations.']);
        break;
    end
end

% Results Calculation
for participant = 1:N
    BESS_capacity(participant, :) = zeros(1, T);
    for t = 1:T
        net_energy = Psolar(participant, t) - E_load(participant, t) + strategies(participant, t);
        if net_energy > 0
            surplus = min(net_energy, B - BESS_capacity(participant, t)); 
            BESS_capacity(participant, t) = BESS_capacity(participant, t) + surplus; 
            profit(participant) = profit(participant) + surplus * p_sell(participant, t); 
            revenue(participant) = revenue(participant) + surplus * p_sell(participant, t);
            renewable_traded(participant) = renewable_traded(participant) + surplus;
        else
            deficit = abs(net_energy);
            if BESS_capacity(participant, t) >= deficit
                BESS_capacity(participant, t) = BESS_capacity(participant, t) - deficit; 
            else
                grid_energy = deficit - BESS_capacity(participant, t);
                BESS_capacity(participant, t) = 0;
                cost(participant) = cost(participant) + grid_energy * p_buy(participant, t); 
            end
        end
    end
end

% Updated Calculations for Graphs
total_cost_direct_grid = sum(((E_load - Psolar) .* (E_load - Psolar > 0)) .* p_buy, 2)' + ((B * T) * 0.1425);
savings = total_cost_direct_grid - cost;
total_revenue_direct_grid = sum(abs((E_load - Psolar) .* (E_load - Psolar < 0)) .* p_sell, 2)' + ((B * T) * 0.074);
additional_revenue = revenue - total_revenue_direct_grid;
renewable_traded = (total_cost_direct_grid ./ p_buy(1, :)) - (cost ./ p_buy(1, :));
profit_microgrid = net_profit;
profit_direct_grid = revenue - total_cost_direct_grid;
additional_profit = profit_microgrid - profit_direct_grid;
% Results Display
net_profit = profit - cost; % Net profit calculation
disp('Participant Results:');
disp(table((1:N)', profit', cost', net_profit', ...
    'VariableNames', {'Participant', 'Profit', 'Cost', 'Net_Profit'}));

% Graphs
% (Insert all updated graphs here as per the previous message)
% Graph 1: BESS Capacity for Each Participant
figure;
plot(BESS_capacity');
title('BESS Capacity for Each Participant');
xlabel('Hour');
ylabel('Energy Stored (kWh)');
grid on;

% Graph 2: PV Generation for Each Participant
figure;
plot(Psolar');
title('PV Generation for Each Participant');
xlabel('Hour');
ylabel('Energy Generated (kWh)');
grid on;

% Graph 3: Load Demand for Each Participant
figure;
plot(E_load');
title('Load Demand for Each Participant');
xlabel('Hour');
ylabel('Energy Consumed (kWh)');
grid on;

% Graph 4: Energy Buying Price (p_buy)
figure;
plot(p_buy(1, :), 'DisplayName', 'p\_buy');
title('Energy Buying Price (p\_buy)');
xlabel('Hour');
ylabel('Price ($/kWh)');
grid on;

% Graph 5: Energy Selling Price (p_sell)
figure;
plot(p_sell(1, :), 'DisplayName', 'p\_sell');
title('Energy Selling Price (p\_sell)');
xlabel('Hour');
ylabel('Price ($/kWh)');
grid on;

% Graph 6: Cost Comparison (Community Microgrid vs Direct Grid)
figure;
bar([cost' total_cost_direct_grid'], 'grouped');
title('Cost Comparison: Microgrid vs Direct Grid');
xlabel('Participant');
ylabel('Total Cost ($)');
legend('Microgrid', 'Direct Grid');
grid on;

% Graph 7: Total Savings for Each Participant
figure;
bar(savings);
title('Total Savings for Each Participant');
xlabel('Participant');
ylabel('Savings ($)');
grid on;

% Graph 8: Revenue Comparison (Community Microgrid vs Direct Grid)
figure;
bar([revenue' total_revenue_direct_grid'], 'grouped');
title('Revenue Comparison: Microgrid vs Direct Grid');
xlabel('Participant');
ylabel('Revenue ($)');
legend('Microgrid', 'Direct Grid');
grid on;

% Graph 9: Additional Revenue for Each Participant
figure;
bar(additional_revenue);
title('Additional Revenue for Each Participant');
xlabel('Participant');
ylabel('Additional Revenue ($)');
grid on;

% Graph 10: Profit for Each Participant in the Microgrid
figure;
bar(net_profit);
title('Profit for Each Participant');
xlabel('Participant');
ylabel('Profit ($)');
grid on;

% Graph 11: Renewable Energy Traded in the Microgrid
figure;
bar(renewable_traded);
title('Renewable Energy Traded Within the Microgrid');
xlabel('Participant');
ylabel('Renewable Energy (kWh)');
grid on;

% New Graph 12: Profit Comparison (Microgrid vs Direct Grid)
figure;
bar([profit_microgrid' profit_direct_grid'], 'grouped');
title('Profit Comparison: Microgrid vs Direct Grid');
xlabel('Participant');
ylabel('Profit ($)');
legend('Microgrid', 'Direct Grid');
grid on;

% New Graph 13: Additional Profit for Each Participant
figure;
bar(additional_profit);
title('Additional Profit for Each Participant');
xlabel('Participant');
ylabel('Additional Profit ($)');
grid on;

% --- Helper Functions ---
function optimal_strategy = optimize_strategy(participant, Psolar, E_load, p_buy, p_sell, B, BESS_capacity, T)
    f = @(x) -profit_function(x, participant, Psolar, E_load, p_buy, p_sell, B, BESS_capacity);
    lb = zeros(1, T); 
    ub = B * ones(1, T); 
    options = optimoptions('fmincon', 'Display', 'off'); 
    optimal_strategy = fmincon(f, zeros(1, T), [], [], [], [], lb, ub, [], options);
end

function profit = profit_function(x, participant, Psolar, E_load, p_buy, p_sell, B, BESS_capacity)
    net_energy = Psolar(participant, :) - E_load(participant, :) + x; 
    profit = 0;
    for t = 1:length(net_energy)
        if net_energy(t) > 0
            surplus = min(net_energy(t), B - BESS_capacity(t));
            BESS_capacity(t) = BESS_capacity(t) + surplus;
            profit = profit + surplus * p_sell(participant, t);
        elseif net_energy(t) < 0
            deficit = abs(net_energy(t));
            if BESS_capacity(t) >= deficit
                BESS_capacity(t) = BESS_capacity(t) - deficit;
            else
                profit = profit - (deficit - BESS_capacity(t)) * p_buy(participant, t);
                BESS_capacity(t) = 0;
            end
        end
    end
end