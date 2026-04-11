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
p_trade = p_sell; % Start with trade price equal to sell price

% Storage and results tracking
strategies = zeros(N, T); % Initial energy trade strategy
prev_strategies = strategies; % To track convergence
BESS_capacity = zeros(N, T); % Battery storage
profit = zeros(1, N); % Participant profit
cost = zeros(1, N); % Participant cost
renewable_traded = 0; % Renewable energy traded

% Nikaido-Isoda Relaxation Method
max_iter = 100; % Maximum iterations
tolerance = 1e-3; % Convergence tolerance
lambda = 0.1; % Relaxation parameter

for iter = 1:max_iter
    for participant = 1:N
        % Solve for the best response of the current participant
        optimal_strategy = optimize_strategy(participant, Psolar, E_load, p_buy, p_sell);
        
        % Update strategy using relaxation
        strategies(participant, :) = strategies(participant, :) + ...
            lambda * (optimal_strategy - strategies(participant, :));
    end
    
    % Check for convergence
    if max(abs(strategies(:) - prev_strategies(:))) < tolerance
        disp(['Converged after ', num2str(iter), ' iterations.']);
        break;
    end
    prev_strategies = strategies;
end

% Calculate results
for participant = 1:N
    for t = 1:T
        net_energy = Psolar(participant, t) - E_load(participant, t) + strategies(participant, t);
        if net_energy > 0
            % Surplus: Store in battery or sell surplus
            surplus = min(net_energy, B - BESS_capacity(participant, t)); % Limited by battery capacity
            BESS_capacity(participant, t) = BESS_capacity(participant, t) + surplus; % Store in battery
            profit(participant) = profit(participant) + surplus * p_sell(participant, t); % Revenue from selling surplus
            renewable_traded = renewable_traded + surplus; % Track renewable energy traded
        else
            % Deficit: Use from battery or buy from grid
            deficit = abs(net_energy);
            if BESS_capacity(participant, t) >= deficit
                BESS_capacity(participant, t) = BESS_capacity(participant, t) - deficit; % Use battery
            else
                grid_energy = deficit - BESS_capacity(participant, t);
                BESS_capacity(participant, t) = 0;
                cost(participant) = cost(participant) + grid_energy * p_buy(participant, t); % Cost from grid
            end
        end
    end
end

% Calculate total cost without community microgrid
total_cost_direct_grid = sum(E_load .* p_buy, 2); % Each participant deals directly with the grid
savings = total_cost_direct_grid' - cost; % Savings by participating in the microgrid
revenue = profit; % Revenue in the microgrid
additional_revenue = revenue - total_cost_direct_grid';

% Display results
net_profit = revenue - cost;% Profit = Revenue - Cost
disp('Participant Results:');
disp(table((1:N)', profit', cost', net_profit', ...
    'VariableNames', {'Participant', 'Profit', 'Cost', 'Net_Profit'}));

% --- Graphs ---

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

% Graph 4: Prices (p_buy, p_sell, p_trade)
figure;
plot(p_buy(1, :), 'DisplayName', 'p_buy');
hold on;
plot(p_sell(1, :), 'DisplayName', 'p_sell');
plot(p_trade(1, :), 'DisplayName', 'p_trade');
hold off;
title('Energy Prices (p\_buy, p\_sell, p\_trade)');
xlabel('Hour');
ylabel('Price ($/kWh)');
legend;
grid on;

% Corrected Graph 5: Total Cost for Each Participant
figure;
bar([cost' total_cost_direct_grid], 'grouped'); % Use 'grouped' to separate the bars
title('Cost Comparison: Microgrid vs Direct Grid');
xlabel('Participant');
ylabel('Total Cost ($)');
legend('Microgrid', 'Direct Grid');
grid on;


% Graph 6: Total Savings for Each Participant
figure;
bar(savings);
title('Total Savings for Each Participant');
xlabel('Participant');
ylabel('Savings ($)');
grid on;

% Corrected Graph 7: Total Revenue for Each Participant
figure;
bar([revenue' total_cost_direct_grid], 'grouped'); % Use grouped bars
title('Revenue Comparison: Microgrid vs Direct Grid');
xlabel('Participant');
ylabel('Total Revenue ($)');
legend('Microgrid', 'Direct Grid');
grid on;

% Corrected Graph 8: Additional Revenue for Each Participant
figure;
bar(additional_revenue);
title('Additional Revenue for Each Participant');
xlabel('Participant');
ylabel('Additional Revenue ($)');
grid on;


% Corrected Graph 9: Profit for Each Participant
figure;
bar(net_profit);
title('Profit for Each Participant');
xlabel('Participant');
ylabel('Profit ($)');
grid on;


% Corrected Graph 10: Renewable Energy Traded
figure;
bar(renewable_traded * ones(1, N));
title('Renewable Energy Traded Within the Microgrid');
xlabel('Participant');
ylabel('Renewable Energy (kWh)');
grid on;


%% Helper Functions
function profit = profit_function(x, participant, Psolar, E_load, p_buy, p_sell)
    % Calculate profit based on the strategy x
    net_energy = Psolar(participant, :) - E_load(participant, :) + x; % Net energy with trade
    profit = sum(max(net_energy, 0) .* p_sell(participant, :)) - ...
             sum(max(-net_energy, 0) .* p_buy(participant, :));
end

function optimal_strategy = optimize_strategy(participant, Psolar, E_load, p_buy, p_sell)
    % Define the participant's profit maximization problem
    f = @(x) -profit_function(x, participant, Psolar, E_load, p_buy, p_sell); % Negative for maximization
    lb = zeros(1, 24); % Lower bounds (no negative trade)
    ub = ones(1, 24); % Upper bounds (battery capacity, set arbitrarily to 1)
    options = optimoptions('fmincon', 'Display', 'off'); % Optimization options
    optimal_strategy = fmincon(f, zeros(1, 24), [], [], [], [], lb, ub, [], options);
end