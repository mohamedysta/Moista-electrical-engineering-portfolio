clc
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

%% Step 2: Define Variables for Energy Balance
% Decision variables:
%  PV, Charge, Discharge, Consumption, Trade In, Trade Out for each participant

Charge = zeros(N, T);  % Battery Charging (Decision Variable)
Discharge = zeros(N, T);  % Battery Discharging (Decision Variable)
Consumption = E_i;  % Load demand

TradeIn = zeros(N, T);  % Energy trade-in from other participants
TradeOut = zeros(N, T);  % Energy trade-out to other participants

%% Step 3: Define Constraints

% Energy balance: PV + Discharge + TradeIn = Consumption + Charge + TradeOut
EnergyBalance = Psolar + Discharge + TradeIn - Consumption - Charge - TradeOut;

% Battery capacity constraints (0 <= Charge, Discharge <= B)
BatteryCapacity = B;  % Capacity of battery

%% Step 4: Objective Function

% Profit = Revenue from Selling Energy − Cost of Buying Energy

% Revenue from selling energy (TradeOut -> energy sold to grid or other participants)
Revenue = TradeOut .* p_sell;

% Cost of buying energy (TradeIn -> energy bought from grid or other participants)
Cost = TradeIn .* p_buy;

% Profit for each participant
Profit = Revenue - Cost;

%% Step 5: Nikaido-Isoda Relaxation Algorithm

% Initialize strategy variables
Strategies = zeros(N, T, 4); % 4 strategies: Charge, Discharge, TradeIn, TradeOut

% Set relaxation parameters
max_iter = 100;  % Maximum number of iterations
tolerance = 1e-6;  % Convergence tolerance

% Initialize strategies randomly
Charge = rand(N, T) * B;  % Random initial charge strategies
Discharge = rand(N, T) * B;  % Random initial discharge strategies
TradeIn = rand(N, T) * B;  % Random initial trade-in strategies
TradeOut = rand(N, T) * B;  % Random initial trade-out strategies

%% Step 6: Nikaido-Isoda Iteration Loop
converged = false;
iter = 0;

while ~converged && iter < max_iter
    iter = iter + 1;
    
    % Save previous strategies for convergence check
    prev_Strategies = Strategies;
    
    for i = 1:N
        % Objective: maximize profit for each participant by optimizing their strategies
        
        % For each participant, solve the optimization problem with respect to others' strategies.
        % Use an optimization solver like fminunc/fmincon to solve the best response problem
        options = optimset('Display','off','TolX',1e-6);
        
        % Define the objective function (profit maximization)
        obj_fun = @(x) -sum(x(1:T).*p_sell + x(T+1:2*T).*p_sell - x(2*T+1:3*T).*p_buy - x(3*T+1:4*T).*p_buy);
        
        % Define constraints (e.g., energy balance, battery limits, non-negative trade)
        % Constraints:
        % 1. Energy balance: PV + Discharge + TradeIn = Consumption + Charge + TradeOut
        % 2. Charge, Discharge, TradeIn, TradeOut >= 0
        % 3. Charge, Discharge <= Battery Capacity
        
        lb = zeros(4*T,1); % Lower bound: no negative values for strategies
        ub = [B*ones(T,1); B*ones(T,1); B*ones(T,1); B*ones(T,1)]; % Upper bound: charging, discharging, trading within battery capacity
        
        % Solve using an optimization solver
        [optimized_strategies, fval] = fminunc(obj_fun, Strategies(i,:, :), options);
        
        % Update strategies based on optimization result
        Strategies(i, :, :) = optimized_strategies;
    end
    
    % Convergence check: the strategies haven't changed significantly
    strategy_diff = max(abs(Strategies - prev_Strategies), [], 'all');
    
    if strategy_diff < tolerance
        converged = true;
        fprintf('Convergence reached at iteration %d\n', iter);
    end
end

%% Step 7: Calculate Results (Profit, Revenue, Cost, etc.)
% Calculate total revenue, cost, and profit for each participant

Revenue = sum(Strategies(:,:,4) .* p_sell, 2);  % Revenue from selling energy
Cost = sum(Strategies(:,:,3) .* p_buy, 2);  % Cost of buying energy

TotalCost = Cost;  % Total cost for each participant
TotalRevenue = Revenue;  % Total revenue for each participant
TotalProfit = TotalRevenue - TotalCost;  % Total profit for each participant

%% Step 8: Plot Results
% Plot various results as described in the problem statement

figure;
subplot(3, 2, 1);
plot(1:T, Charge);
title('Battery Charging for Each Participant');

subplot(3, 2, 2);
plot(1:T, Psolar);
title('PV Generation for Each Participant');

subplot(3, 2, 3);
plot(1:T, E_i);
title('Load Demand for Each Participant');

subplot(3, 2, 4);
plot(1:T, p_buy);
title('Price to Buy Energy from Grid');

subplot(3, 2, 5);
plot(1:T, p_sell);
title('Price to Sell Energy to Grid');

subplot(3, 2, 6);
plot(1:T, p_trade);
title('Trade Price Between Participants');

% Additional plots
figure;
subplot(2, 2, 1);
bar(TotalProfit);
title('Profit for Each Participant');

subplot(2, 2, 2);
bar(TotalRevenue);
title('Revenue for Each Participant');

subplot(2, 2, 3);
bar(TotalCost);
title('Cost for Each Participant');