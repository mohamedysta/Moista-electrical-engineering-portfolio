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
revenue = zeros(1, N); % Participant revenue (from selling surplus)
additional_revenue = zeros(1, N); % Additional revenue from trading within the microgrid
savings = zeros(1, N); % Savings from using microgrid over direct grid purchase
renewable_traded = zeros(1, N); % Track total renewable energy traded within the microgrid

% Nikaido-Isoda Relaxation Method
max_iter = 100; % Maximum iterations
tolerance = 1e-3; % Convergence tolerance
lambda = 0.1; % Relaxation parameter

% Calculate total cost if participants buy all energy from the grid
total_cost_direct_grid = zeros(1, N); % Initialize total cost matrix
for participant = 1:N
    total_cost_direct_grid(participant) = sum(E_load(participant, :) .* p_buy(participant, :)); % Direct grid cost
end

% Main Loop for Nikaido-Isoda Relaxation Method
for iter = 1:max_iter
    prev_strategies = strategies;  % Store previous strategies for convergence check

    for participant = 1:N
        % Solve for the best response of the current participant
        optimal_strategy = optimize_strategy(participant, Psolar, E_load, p_buy, p_sell, B, BESS_capacity,T);
        
        % Update strategy using relaxation
        strategies(participant, :) = strategies(participant, :) + ...
            lambda * (optimal_strategy - strategies(participant, :));
    end
    
    % Check for convergence after all participants update their strategies
    if max(abs(strategies(:) - prev_strategies(:))) < tolerance
        disp(['Converged after ', num2str(iter), ' iterations.']);
        break;
    end
end

% Calculate results (profit, cost, etc.)
for participant = 1:N
    BESS_capacity(participant, :) = zeros(1, T); % Reset battery storage for the participant
    
    for t = 1:T
        net_energy = Psolar(participant, t) - E_load(participant, t) + strategies(participant, t);
        
        if net_energy > 0
            % Surplus: Store in battery or sell surplus
            surplus = min(net_energy, B - BESS_capacity(participant, t)); % Limited by battery capacity
            BESS_capacity(participant, t) = BESS_capacity(participant, t) + surplus; % Store in battery
            profit(participant) = profit(participant) + surplus * p_sell(participant, t); % Revenue from selling surplus
            revenue(participant) = revenue(participant) + surplus * p_sell(participant, t); % Total revenue from surplus
            renewable_traded(participant) = renewable_traded(participant) + surplus; % Track renewable energy traded
            % Calculate additional revenue from internal energy trading (for example)
            % If energy is not sold to the grid, assume it's traded within the microgrid
            additional_revenue(participant) = additional_revenue(participant) + surplus * p_trade(participant, t);

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

% Results Display
net_profit = profit - cost; % Net profit calculation
disp('Participant Results:');
disp(table((1:N)', profit', cost', net_profit', ...
    'VariableNames', {'Participant', 'Profit', 'Cost', 'Net_Profit'}));

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

% Ensure both arrays have the same dimensions for the bar plot
cost = cost(:)'; % Convert to a row vector
total_cost_direct_grid = total_cost_direct_grid(:)'; % Convert to a row vector

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
savings = total_cost_direct_grid - revenue; % Calculate savings
bar(savings);
title('Total Savings for Each Participant');
xlabel('Participant');
ylabel('Savings ($)');
grid on;

% --- Graphs ---
% Graph showing total cost for each participant (microgrid vs grid)
figure;
bar([revenue' total_cost_direct_grid'], 'grouped'); % Corrected dimensions
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
bar(net_profit);
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



% --- Helper Functions ---

function optimal_strategy = optimize_strategy(participant, Psolar, E_load, p_buy, p_sell, B, BESS_capacity,T)
    % Define the participant's profit maximization problem using fmincon
    f = @(x) -profit_function(x, participant, Psolar, E_load, p_buy, p_sell, B, BESS_capacity); % Negative for maximization
    lb = zeros(1, T); % Lower bounds (no negative trade)
    ub = B * ones(1, T); % Upper bounds (battery capacity)
    options = optimoptions('fmincon', 'Display', 'off'); % Optimization options
    optimal_strategy = fmincon(f, zeros(1, T), [], [], [], [], lb, ub, [], options);
end

function profit = profit_function(x, participant, Psolar, E_load, p_buy, p_sell, B, BESS_capacity)
    % Calculate profit based on the strategy x
    net_energy = Psolar(participant, :) - E_load(participant, :) + x; % Net energy with trade
    profit = 0;

    for t = 1:length(net_energy)
        if net_energy(t) > 0
            % Surplus energy: Try to store in the battery or sell it
            surplus = min(net_energy(t), B - BESS_capacity(t)); % Limit to battery capacity
            BESS_capacity(t) = BESS_capacity(t) + surplus; % Store in battery
            profit = profit + surplus * p_sell(participant, t); % Revenue from surplus
        elseif net_energy(t) < 0
            % Energy deficit: Use from battery or buy from grid
            deficit = abs(net_energy(t));
            if BESS_capacity(t) >= deficit
                % Use battery to cover deficit
                BESS_capacity(t) = BESS_capacity(t) - deficit;
            else
                % Not enough battery: Buy from grid
                profit = profit - (deficit - BESS_capacity(t)) * p_buy(participant, t); % Deduct cost from profit
                BESS_capacity(t) = 0; % Battery emptied
            end
        end
    end
end
