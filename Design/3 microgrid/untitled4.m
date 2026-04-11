%% Step 1: Initialize Parameters
N = 15;  % Number of participants
T = 24;  % Time horizon (hours)
B = 10;  % Battery Storage Size (kWh)

% PV Generation (kW) for each participant (Nx24)
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
E_i = vertcat(Ei1, Ei2, Ei3, Ei4, Ei5, Ei6, Ei7, Ei8, Ei9, Ei10, Ei11, Ei12, Ei13, Ei14, Ei15); % Nx24 Load Matrix 

% Price Matrices (Nx24 matrices)
p_buy = repmat([0.1425, 0.1425, 0.1425, 0.1425, 0.1425, 0.1425, 0.1425, 0.1425, 0.1425, 0.1425, 0.1425, 0.1425, 0.1967, 0.1967, 0.1967, 0.1967, 0.1967, 0.3462, 0.3462, 0.3462, 0.1967, 0.1967, 0.1967, 0.1967], N, 1); % Nx24
p_sell = repmat([0.074, 0.074, 0.074, 0.074, 0.074, 0.074, 0.074, 0.074, 0.074, 0.074, 0.074, 0.074, 0.074, 0.074, 0.074, 0.074, 0.074, 0.074, 0.074, 0.074, 0.074, 0.074, 0.074, 0.074], N, 1);
p_trade = p_sell; % Trade price assumed to be same as sell price

%% Step 2: Define Struct for Participants
% Initialize the structure for participants
participants = struct('Psolar', [], 'E_i', [], 'p_buy', [], 'p_sell', [], 'p_trade', [], ...
    'Charge', [], 'Discharge', [], 'TradeIn', [], 'TradeOut', [], 'TotalCost', [], ...
    'TotalRevenue', [], 'TotalProfit', []);

% Assign values to each participant's structure
for i = 1:N
    participants(i).Psolar = Psolar(i, :);  % PV generation for participant i
    participants(i).E_i = E_i(i, :);  % Load demand for participant i
    participants(i).p_buy = p_buy(i, :);  % Price to buy energy from grid
    participants(i).p_sell = p_sell(i, :);  % Price to sell energy to grid
    participants(i).p_trade = p_trade(i, :);  % Price for trading energy
    participants(i).Charge = zeros(1, T);  % Battery charging strategy (decision variable)
    participants(i).Discharge = zeros(1, T);  % Battery discharging strategy (decision variable)
    participants(i).TradeIn = zeros(1, T);  % Energy trade-in strategy (decision variable)
    participants(i).TradeOut = zeros(1, T);  % Energy trade-out strategy (decision variable)
    participants(i).TotalCost = 0;  % Initialize total cost
    participants(i).TotalRevenue = 0;  % Initialize total revenue
    participants(i).TotalProfit = 0;  % Initialize total profit
end

%% Step 3: Objective Function and Optimization

% Relaxed convergence parameters
max_iter = 100;  % Maximum number of iterations
tolerance = 1e-2;  % Relaxed convergence tolerance (larger than previous)

converged = false;
iter = 0;

while ~converged && iter < max_iter
    iter = iter + 1;
    
    % Save previous strategies for convergence check
    prev_Strategies = participants;
    
    % Track objective function values for debugging
    obj_values = zeros(N, 1);
    
    % Loop over each participant to solve the optimization problem
    for i = 1:N
        % Objective: maximize profit for each participant
        
        options = optimset('Display','off','TolX',1e-6);
        
        % Define the objective function (profit maximization for a single participant)
        obj_fun = @(x) -sum(x(1:T).*participants(i).p_sell + ...
                             x(T+1:2*T).*participants(i).p_sell - ...
                             x(2*T+1:3*T).*participants(i).p_buy - ...
                             x(3*T+1:4*T).*participants(i).p_buy);
        
        % Constraints:
        lb = zeros(4*T,1); % Lower bound: no negative values for strategies
        ub = [B*ones(T,1); B*ones(T,1); B*ones(T,1); B*ones(T,1)]; % Upper bound: charging, discharging, trading within battery capacity
        
        % Solve using an optimization solver
        [optimized_strategies, fval] = fminunc(obj_fun, ...
            [participants(i).Charge, participants(i).Discharge, ...
            participants(i).TradeIn, participants(i).TradeOut], options);
        
        % Track the objective function value
        obj_values(i) = fval;
        
        % Update strategies based on optimization result
        participants(i).Charge = optimized_strategies(1:T);
        participants(i).Discharge = optimized_strategies(T+1:2*T);
        participants(i).TradeIn = optimized_strategies(2*T+1:3*T);
        participants(i).TradeOut = optimized_strategies(3*T+1:4*T);
    end
    
    % Print out objective function values (for debugging)
    disp(['Iteration ', num2str(iter), ' Objective Values:']);
    disp(obj_values);
    
    % Convergence check: the strategies haven't changed significantly
    strategy_diff = 0;
    for i = 1:N
        strategy_diff = max(strategy_diff, max(abs([participants(i).Charge, participants(i).Discharge, participants(i).TradeIn, participants(i).TradeOut] - ...
            [prev_Strategies(i).Charge, prev_Strategies(i).Discharge, prev_Strategies(i).TradeIn, prev_Strategies(i).TradeOut]), [], 'all'));
    end
    
    % Check convergence
    if strategy_diff < tolerance
        converged = true;
        fprintf('Convergence reached at iteration %d\n', iter);
    end
end

%% Step 4: Calculate Results (Profit, Revenue, Cost, etc.)

% Calculate total revenue, cost, and profit for each participant
for i = 1:N
    Revenue = sum(participants(i).TradeOut .* participants(i).p_sell, 2);  % Revenue from selling energy
    Cost = sum(participants(i).TradeIn .* participants(i).p_buy, 2);  % Cost of buying energy
    participants(i).TotalCost = Cost;  % Total cost for participant i
    participants(i).TotalRevenue = Revenue;  % Total revenue for participant i
    participants(i).TotalProfit = Revenue - Cost;  % Total profit for participant i
end

%% Step 5: Plot Results
% Plot various results for all participants
figure;
for i = 1:N
    subplot(3, N, i);
    plot(1:T, participants(i).Charge);
    title(['Participant ', num2str(i), ' Charging']);

    subplot(3, N, N + i);
    plot(1:T, participants(i).Discharge);
    title(['Participant ', num2str(i), ' Discharging']);

    subplot(3, N, 2 * N + i);
    plot(1:T, participants(i).TradeOut);
    title(['Participant ', num2str(i), ' TradeOut']);
end