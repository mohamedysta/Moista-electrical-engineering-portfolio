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
charge=zeros(N,T);
discharge=zeros(N,T);
%(kWh)
trade_in=zeros(N,T);
trade_out=zeros(N,T);
%battery state (kWh)
battery_capacity = zeros(N,T);

% Nikaido-Isoda Relaxation Method
max_iter = 100; % Maximum iterations
tolerance = 1e-3; % Convergence tolerance
lambda = 0.1; % Relaxation parameter

strategies = zeros(N,T);
prev_strategies=strategies;

profit = zeros(1, N); % Participant profit
cost = zeros(1, N); % Participant cost
revenue = zeros(1, N); % Participant revenue
additional_revenue = zeros(1, N); % Additional revenue
renewable_traded = zeros(1, N); % Renewable energy traded

% Main Loop for Nikaido-Isoda Relaxation Method
for iter = 1:max_iter
    disp(['Iteration',num2str(iter)]);
    prev_strategies = strategies;


    for participant = 1:N
        % Optimize strategy
        optimal_strategy = optimize_strategy(participant, Psolar, E_load, p_buy, p_sell,p_trade, B, battery_capacity, T);
        
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


for participant = 1:N
    [profit(participant),cost(participant), revenue(participant), additional_revenue(participant),renewable_traded(participant)] = calculate_results(participant,Psolar,E_load,strategies,p_buy,p_sell,p_trade,B,T,battery_capacity);
end

% --- Graphs ---

% Graph1 showing BESS capacity for each participant
figure;
plot(BESS_capacity');
title('BESS Capacity for Each Participant');
xlabel('Hour');
ylabel('Energy Stored (kWh)');
grid on;

% Graph2 showing PV Generation for each participant
figure;
plot(Psolar');
title('PV Generation for Each Participant');
xlabel('Hour');
ylabel('Energy Generated (kWh)');
grid on;

% Graph3 showing Load Demand for each participant
figure;
plot(E_load');
title('Load Demand for Each Participant');
xlabel('Hour');
ylabel('Energy Consumed (kWh)');
grid on;

% Graph4 showing p_buy (buying price) over the 24 hours
figure;
plot(p_buy(1, :), 'DisplayName', 'p\_buy');
title('Energy Buying Price (p\_buy)');
xlabel('Hour');
ylabel('Price ($/kWh)');
grid on;

% Graph5 showing p_sell (selling price) over the 24 hours
figure;
plot(p_sell(1, :), 'DisplayName', 'p\_sell');
title('Energy Selling Price (p\_sell)');
xlabel('Hour');
ylabel('Price ($/kWh)');
grid on;


% Plot the comparison bar chart7
figure;
bar([cost' total_cost_direct_grid'], 'grouped'); % Corrected dimensions
title('Cost Comparison: Microgrid vs Direct Grid');
xlabel('Participant');
ylabel('Total Cost ($)');
legend('Microgrid', 'Direct Grid');
grid on;
% Graph8 showing total savings for each participant
figure;
bar(savings);
title('Total Savings for Each Participant');
xlabel('Participant');
ylabel('Savings ($)');
grid on;

% --- Graphs ---
% Graph showing total cost for each participant (microgrid vs grid)
figure;
bar([revenue' total_revenue_direct_grid'], 'grouped'); % Corrected dimensions
title('Revenue Comparison: Microgrid vs Direct Grid');
xlabel('Participant');
ylabel('Total Revenue ($)');
legend('Microgrid', 'Direct Grid');
grid on;



% Graph showing additional revenue for each participant
figure;
bar(additional_revenue);
title('Additional Revenue for Each Participant');
xlabel('Participant');
ylabel('Additional Revenue ($)');
grid on;

% Graph showing profit for each participant
figure;
bar(profit);
title('Profit for Each Participant');
xlabel('Participant');
ylabel('Profit ($)');
grid on;

% Simply pass the renewable_traded directly to bar
figure;
bar(renewable_traded);
title('Renewable Energy Traded Within the Microgrid');
xlabel('Participant');
ylabel('Renewable Energy (kWh)');
grid on;

% Simply pass the renewable_traded directly to bar
figure;
bar([profit' profit_direct_grid'],'grouped');
title('Profit Comparison: Microgrid vs Direct Grid');
xlabel('Participant');
ylabel('Profit ($)');
legend('Microgrid','Direct Grid');
grid on;
% Simply pass the renewable_traded directly to bar
figure;
bar(additional_profit);
title('Renewable Energy Traded Within the Microgrid');
xlabel('Participant');
ylabel('Renewable Energy (kWh)');
grid on;

% --- Helper Functions ---
function optimal_strategy = optimize_strategy(participant, Psolar, E_load, p_buy, p_sell, p_trade, B, T, battery_capacity)
    % Profit Maximization Objective Function
    f = @(x) -profit_function(x, participant, Psolar, E_load, p_buy, p_sell, p_trade, B, battery_capacity);
    
    % Constraints
    lb = zeros(1, T); % Lower bounds (no negative trade)
    ub = B * ones(1, T); % Upper bounds (battery capacity)

    % Solve Using fmincon
    options = optimoptions('fmincon', 'Display', 'off');
    optimal_strategy = fmincon(f, zeros(1, T), [], [], [], [], lb, ub, [], options);
end

function profit = profit_function(strategy, participant, Psolar, E_load, p_buy, p_sell, p_trade, B, battery_capacity)
    net_energy = Psolar(participant, :) - E_load(participant, :) + strategy; % Net energy with strategy
    profit = 0;

    for t = 1:length(net_energy)
        if net_energy(t) > 0
            % Surplus Energy: Store in battery or sell
            surplus = min(net_energy(t), B - battery_capacity(participant, t));
            battery_capacity(participant, t) = battery_capacity(participant, t) + surplus;
            profit = profit + surplus * p_sell(participant, t);
        elseif net_energy(t) < 0
            % Deficit Energy: Use from battery or buy from grid
            deficit = abs(net_energy(t));
            if battery_capacity(participant, t) >= deficit
                battery_capacity(participant, t) = battery_capacity(participant, t) - deficit;
            else
                grid_energy = deficit - battery_capacity(participant, t);
                profit = profit - grid_energy * p_buy(participant, t);
                battery_capacity(participant, t) = 0;
            end
        end
    end
end

function [profit, cost, revenue, additional_revenue, renewable_traded] = calculate_results(participant, Psolar, E_load, strategies, p_buy, p_sell, p_trade, B, T, battery_capacity)
    profit = 0;
    cost = 0;
    revenue = 0;
    additional_revenue = 0;
    renewable_traded = 0;

    for t = 1:T
        net_energy = Psolar(participant, t) - E_load(participant, t) + strategies(participant, t);

        if net_energy > 0
            % Surplus: Sell to grid or trade
            surplus = min(net_energy, B - battery_capacity(participant, t));
            battery_capacity(participant, t) = battery_capacity(participant, t) + surplus;
            revenue = revenue + surplus * p_sell(participant, t);
            renewable_traded = renewable_traded + surplus;
        else
            % Deficit: Buy from grid or trade
            deficit = abs(net_energy);
            if battery_capacity(participant, t) >= deficit
                battery_capacity(participant, t) = battery_capacity(participant, t) - deficit;
            else
                grid_energy = deficit - battery_capacity(participant, t);
                cost = cost + grid_energy * p_buy(participant, t);
                battery_capacity(participant, t) = 0;
            end
        end
    end
    profit = revenue - cost;
    additional_revenue = revenue - (sum(abs((E_load(participant, :) - Psolar(participant, :)) .* (E_load(participant, :) - Psolar(participant, :) < 0)) .* p_sell(participant, :)) + B * p_sell(participant, 1));
end