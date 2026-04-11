%% Lightsaber Heat Transfer Analysis
% MAE 4230 Project 1
% Name: [Your Name]
% Date: [Date]

clear; clc; close all;

%% Part 1: Parameters and Setup
fprintf('Lightsaber Heat Transfer Analysis\n');
fprintf('================================\n\n');

% Geometry
L1 = 1.2;        % Core length (m)
L2 = 0.25;       % Handle length (m)
Rcore = 0.02;    % Core/handle radius (m)

% Material properties
kcore = 0.35;    % Core thermal conductivity (W/m-K)
khandle = 0.05;  % Handle thermal conductivity (W/m-K)

% Heat generation
q_max = 1e6;     % Maximum heat generation at centerline (W/m^3)

% Boundary conditions - Air scenario
h_air = 50;      % Convection coefficient in air (W/m^2-K)
T_air = 20;      % Air temperature (C)
T_hand = 37.1;   % Hand temperature (C)
Rtc_interface = 1e-5;  % Contact resistance core-handle (m^2-K/W)
Rtc_hand = 1e-4;       % Contact resistance handle-hand (m^2-K/W)

% Mesh parameters
nr = 11;         % Radial nodes (must be odd for symmetry)
nx_core = 24;    % Axial nodes in core
nx_handle = 10;  % Axial nodes in handle

fprintf('Mesh Information:\n');
fprintf('Radial nodes: %d\n', nr);
fprintf('Core axial nodes: %d\n', nx_core);
fprintf('Handle axial nodes: %d\n', nx_handle);

%% Part 2: Mesh Generation
dr = Rcore/(nr-1);
dx_core = L1/(nx_core-1);
dx_handle = L2/(nx_handle-1);

% Total nodes (accounting for shared interface node)
nx_total = nx_core + nx_handle - 1;  % -1 because interface is shared
n_total = nr * nx_total;

fprintf('Total axial nodes: %d\n', nx_total);
fprintf('Total nodes: %d\n\n', n_total);

% Coordinate arrays
r = linspace(0, Rcore, nr)';

% Create x-coordinate array
x = zeros(1, nx_total);
% Handle nodes
for j = 1:nx_handle
    x(j) = -L2 + (j-1)*dx_handle;
end
% Core nodes (starting after interface)
for j = 1:nx_core-1
    x(nx_handle + j) = j*dx_core;
end

% Node mapping
node_map = reshape(1:n_total, nr, nx_total);

% Heat generation function
q_gen = @(r) q_max * (1 - (r/Rcore).^2);

%% Part 3: Solve for Air Scenario
fprintf('Solving for air scenario (h = %d W/m^2-K)...\n', h_air);
[T_air_case, A, b] = solve_lightsaber(nr, nx_total, nx_handle, r, dr, dx_core, ...
    dx_handle, kcore, khandle, q_gen, h_air, T_air, T_hand, Rtc_interface, Rtc_hand, x);

%% Part 4: Calculate Heat Transfer to Hand
q_hand_air = calculate_hand_heat(T_air_case, T_hand, dr, r, dx_handle, khandle, Rtc_hand);
fprintf('Heat transfer to hand (air): %.2f W\n', q_hand_air);
fprintf('Maximum temperature (air): %.2f C\n', max(T_air_case(:)));
fprintf('Minimum temperature (air): %.2f C\n\n', min(T_air_case(:)));

%% Part 5: Solve for Lake Scenario
h_lake = 5000;   % Boiling heat transfer coefficient
T_lake = 10;     % Lake temperature
fprintf('Solving for lake scenario (h = %d W/m^2-K)...\n', h_lake);
[T_lake_case, ~, ~] = solve_lightsaber(nr, nx_total, nx_handle, r, dr, dx_core, ...
    dx_handle, kcore, khandle, q_gen, h_lake, T_lake, T_hand, Rtc_interface, Rtc_hand, x);

q_hand_lake = calculate_hand_heat(T_lake_case, T_hand, dr, r, dx_handle, khandle, Rtc_hand);
fprintf('Heat transfer to hand (lake): %.2f W\n', q_hand_lake);
fprintf('Maximum temperature (lake): %.2f C\n', max(T_lake_case(:)));
fprintf('Minimum temperature (lake): %.2f C\n\n', min(T_lake_case(:)));

%% Part 6: Plotting
% Create meshgrid for plotting
[X, R] = meshgrid(x*100, r*100); % Convert to cm for better visualization

% Figure 1: Temperature contours
figure('Position', [100, 100, 1200, 800]);

% Air scenario
subplot(2,1,1);
contourf(X, R, T_air_case, 30);
hold on;
contourf(X, -R, T_air_case, 30); % Mirror for lower half
colorbar;
xlabel('Axial position (cm)');
ylabel('Radial position (cm)');
title(sprintf('Temperature Distribution - Air Scenario (h = %d W/m²·K)', h_air));
colormap('jet');
% Add region labels
xline(0, 'k--', 'LineWidth', 2);
text(-12.5, 0, 'Handle', 'HorizontalAlignment', 'center', 'FontSize', 12, 'FontWeight', 'bold');
text(60, 0, 'Core', 'HorizontalAlignment', 'center', 'FontSize', 12, 'FontWeight', 'bold');
axis equal tight;
caxis([min(T_air_case(:)), max(T_air_case(:))]);

% Lake scenario
subplot(2,1,2);
contourf(X, R, T_lake_case, 30);
hold on;
contourf(X, -R, T_lake_case, 30);
colorbar;
xlabel('Axial position (cm)');
ylabel('Radial position (cm)');
title(sprintf('Temperature Distribution - Lake Scenario (h = %d W/m²·K)', h_lake));
colormap('jet');
xline(0, 'k--', 'LineWidth', 2);
text(-12.5, 0, 'Handle', 'HorizontalAlignment', 'center', 'FontSize', 12, 'FontWeight', 'bold');
text(60, 0, 'Core', 'HorizontalAlignment', 'center', 'FontSize', 12, 'FontWeight', 'bold');
axis equal tight;
caxis([min(T_lake_case(:)), max(T_lake_case(:))]);

% Figure 2: Temperature profiles
figure('Position', [100, 100, 1000, 800]);

% Centerline temperatures
subplot(2,2,1);
plot(x*100, T_air_case(1,:), 'b-', 'LineWidth', 2);
hold on;
plot(x*100, T_lake_case(1,:), 'r-', 'LineWidth', 2);
xlabel('Axial position (cm)');
ylabel('Temperature (°C)');
title('Centerline Temperature Profiles');
legend('Air', 'Lake', 'Location', 'best');
grid on;
xline(0, 'k--', 'Interface');

% Surface temperatures
subplot(2,2,2);
plot(x*100, T_air_case(end,:), 'b-', 'LineWidth', 2);
hold on;
plot(x*100, T_lake_case(end,:), 'r-', 'LineWidth', 2);
xlabel('Axial position (cm)');
ylabel('Temperature (°C)');
title('Outer Surface Temperature Profiles');
legend('Air', 'Lake', 'Location', 'best');
grid on;
xline(0, 'k--', 'Interface');

% Radial profiles at different locations
subplot(2,2,3);
plot(r*100, T_air_case(:,1), 'b-', 'LineWidth', 2);
hold on;
plot(r*100, T_lake_case(:,1), 'r-', 'LineWidth', 2);
xlabel('Radial position (cm)');
ylabel('Temperature (°C)');
title('Radial Profile at Handle Base');
legend('Air', 'Lake', 'Location', 'best');
grid on;

subplot(2,2,4);
plot(r*100, T_air_case(:,end), 'b-', 'LineWidth', 2);
hold on;
plot(r*100, T_lake_case(:,end), 'r-', 'LineWidth', 2);
xlabel('Radial position (cm)');
ylabel('Temperature (°C)');
title('Radial Profile at Core Tip');
legend('Air', 'Lake', 'Location', 'best');
grid on;

%% Part 7: Heat generation visualization
figure('Position', [100, 100, 600, 500]);
r_plot = linspace(0, Rcore, 100);
q_plot = q_gen(r_plot);
plot(r_plot*100, q_plot/1e6, 'b-', 'LineWidth', 2);
xlabel('Radial position (cm)');
ylabel('Heat generation (MW/m³)');
title('Volumetric Heat Generation Profile');
grid on;

%% Part 8: Output Summary
fprintf('\n=== RESULTS SUMMARY ===\n');
fprintf('Air Scenario:\n');
fprintf('  Max temperature: %.2f °C\n', max(T_air_case(:)));
fprintf('  Min temperature: %.2f °C\n', min(T_air_case(:)));
fprintf('  Heat to hand: %.2f W\n', q_hand_air);
fprintf('  Temperature at interface (centerline): %.2f °C\n', T_air_case(1, nx_handle));
fprintf('  Temperature at core tip (centerline): %.2f °C\n', T_air_case(1, end));
fprintf('\nLake Scenario:\n');
fprintf('  Max temperature: %.2f °C\n', max(T_lake_case(:)));
fprintf('  Min temperature: %.2f °C\n', min(T_lake_case(:)));
fprintf('  Heat to hand: %.2f W\n', q_hand_lake);
fprintf('  Temperature at interface (centerline): %.2f °C\n', T_lake_case(1, nx_handle));
fprintf('  Temperature at core tip (centerline): %.2f °C\n', T_lake_case(1, end));

%% Function: Solve lightsaber temperature distribution
function [T, A, b] = solve_lightsaber(nr, nx_total, nx_handle, r, dr, dx_core, ...
    dx_handle, kcore, khandle, q_gen, h_conv, T_conv, T_hand, Rtc_interface, Rtc_hand, x)
    
    % Initialize system
    n_total = nr * nx_total;
    A = sparse(n_total, n_total);
    b = zeros(n_total, 1);
    
    % Node mapping
    node_map = reshape(1:n_total, nr, nx_total);
    
            % Loop through all nodes
        for j = 1:nx_total
            for i = 1:nr
                node = node_map(i,j);
                
                % Determine region and properties
                if j < nx_handle
                    % Handle region (before interface)
                    k = khandle;
                    dx = dx_handle;
                    q_vol = 0;  % No heat generation in handle
                elseif j == nx_handle
                    % Interface node
                    k = khandle;  % Use handle properties for interface
                    dx = dx_handle;
                    q_vol = 0;
                else
                    % Core region
                    k = kcore;
                    dx = dx_core;
                    q_vol = q_gen(r(i));
                end
                
                % Apply finite difference equations based on node location
                
                % Case 1: Handle base (j = 1) - Contact with hand
                if j == 1
                    h_hand = 1/(Rtc_hand);
                    if i == 1
                        % Centerline at handle base
                        A(node, node) = -4*k/dr^2 - 2*h_hand/k;
                        A(node, node_map(i+1,j)) = 4*k/dr^2;
                        A(node, node_map(i,j+1)) = 2*k/dx^2;
                        b(node) = -2*h_hand*T_hand/k - q_vol;
                    elseif i == nr
                        % Outer surface at handle base
                        A(node, node) = -2*k/dr^2 - 2*h_hand/k;
                        A(node, node_map(i-1,j)) = 2*k/dr^2;
                        A(node, node_map(i,j+1)) = 2*k/dx^2;
                        b(node) = -2*h_hand*T_hand/k - q_vol;
                    else
                        % Interior at handle base
                        A(node, node) = -2*k/dr^2 - 2*h_hand/k;
                        A(node, node_map(i+1,j)) = k/dr^2 + k/(2*r(i)*dr);
                        A(node, node_map(i-1,j)) = k/dr^2 - k/(2*r(i)*dr);
                        A(node, node_map(i,j+1)) = 2*k/dx^2;
                        b(node) = -2*h_hand*T_hand/k - q_vol;
                    end
                    
                % Case 2: Core tip (j = nx_total) - Convection
                elseif j == nx_total
                    if i == 1
                        % Centerline at core tip
                        A(node, node) = -4*k/dr^2 - 2*k/dx^2 - 2*h_conv*dx/k;
                        A(node, node_map(i+1,j)) = 4*k/dr^2;
                        A(node, node_map(i,j-1)) = 2*k/dx^2;
                        b(node) = -2*h_conv*dx*T_conv/k - q_vol;
                    elseif i == nr
                        % Outer surface at core tip
                        A(node, node) = -2*k/dr^2 - 2*k/dx^2 - 2*h_conv*dr/k - 2*h_conv*dx/k;
                        A(node, node_map(i-1,j)) = 2*k/dr^2;
                        A(node, node_map(i,j-1)) = 2*k/dx^2;
                        b(node) = -2*h_conv*(dr + dx)*T_conv/k - q_vol;
                    else
                        % Interior at core tip
                        A(node, node) = -2*k/dr^2 - 2*k/dx^2 - 2*h_conv*dx/k;
                        A(node, node_map(i+1,j)) = k/dr^2 + k/(2*r(i)*dr);
                        A(node, node_map(i-1,j)) = k/dr^2 - k/(2*r(i)*dr);
                        A(node, node_map(i,j-1)) = 2*k/dx^2;
                        b(node) = -2*h_conv*dx*T_conv/k - q_vol;
                    end
                    
                % Case 3: Interface (j = nx_handle)
                elseif j == nx_handle
                    if i == 1
                        % Centerline at interface
                        % Energy balance: q_from_core = q_to_handle
                        R_total = Rtc_interface + dx_handle/(2*khandle) + dx_core/(2*kcore);
                        k_eff = 1/R_total;
                        
                        A(node, node) = -4*khandle/dr^2 - khandle/dx_handle^2 - k_eff;
                        A(node, node_map(i+1,j)) = 4*khandle/dr^2;
                        A(node, node_map(i,j-1)) = khandle/dx_handle^2;
                        A(node, node_map(i,j+1)) = k_eff;  % Connection to core
                        b(node) = 0;
                    elseif i == nr
                        % Outer surface at interface
                        R_total = Rtc_interface + dx_handle/(2*khandle) + dx_core/(2*kcore);
                        k_eff = 1/R_total;
                        
                        A(node, node) = -2*khandle/dr^2 - khandle/dx_handle^2 - k_eff - 2*h_conv*dr/khandle;
                        A(node, node_map(i-1,j)) = 2*khandle/dr^2;
                        A(node, node_map(i,j-1)) = khandle/dx_handle^2;
                        A(node, node_map(i,j+1)) = k_eff;
                        b(node) = -2*h_conv*dr*T_conv/khandle;
                    else
                        % Interior at interface
                        R_total = Rtc_interface + dx_handle/(2*khandle) + dx_core/(2*kcore);
                        k_eff = 1/R_total;
                        
                        A(node, node) = -2*khandle/dr^2 - khandle/dx_handle^2 - k_eff;
                        A(node, node_map(i+1,j)) = khandle/dr^2 + khandle/(2*r(i)*dr);
                        A(node, node_map(i-1,j)) = khandle/dr^2 - khandle/(2*r(i)*dr);
                        A(node, node_map(i,j-1)) = khandle/dx_handle^2;
                        A(node, node_map(i,j+1)) = k_eff;
                        b(node) = 0;
                    end
                    
                % Case 4: Symmetry axis (i = 1)
                elseif i == 1
                    if j < nx_handle
                        % Handle region
                        A(node, node) = -4*k/dr^2 - 2*k/dx^2;
                        A(node, node_map(i+1,j)) = 4*k/dr^2;
                        A(node, node_map(i,j+1)) = k/dx^2;
                        A(node, node_map(i,j-1)) = k/dx^2;
                        b(node) = -q_vol;
                    else
                        % Core region
                        A(node, node) = -4*k/dr^2 - 2*k/dx^2;
                        A(node, node_map(i+1,j)) = 4*k/dr^2;
                        A(node, node_map(i,j+1)) = k/dx^2;
                        A(node, node_map(i,j-1)) = k/dx^2;
                        b(node) = -q_vol;
                    end
                    
                % Case 5: Outer surface (i = nr)
                elseif i == nr
                    A(node, node) = -2*k/dr^2 - 2*k/dx^2 - 2*h_conv*dr/k;
                    A(node, node_map(i-1,j)) = 2*k/dr^2;
                    A(node, node_map(i,j+1)) = k/dx^2;
                    A(node, node_map(i,j-1)) = k/dx^2;
                    b(node) = -2*h_conv*dr*T_conv/k - q_vol;
                    
                % Case 6: Interior nodes
                else
                    A(node, node) = -2*k/dr^2 - 2*k/dx^2;
                    A(node, node_map(i+1,j)) = k/dr^2 + k/(2*r(i)*dr);
                    A(node, node_map(i-1,j)) = k/dr^2 - k/(2*r(i)*dr);
                    A(node, node_map(i,j+1)) = k/dx^2;
                    A(node, node_map(i,j-1)) = k/dx^2;
                    b(node) = -q_vol;
                end
            end
        end
    
    % Solve system
    T_vector = A\b;
    T = reshape(T_vector, nr, nx_total);
end

%% Function: Calculate heat transfer to hand
function q_hand = calculate_hand_heat(T, T_hand, dr, r, dx_handle, khandle, Rtc_hand)
    % Calculate heat flux at handle base using energy balance
    h_hand = 1/Rtc_hand;
    q_hand = 0;
    
    nr = length(r);
    for i = 1:nr
        if i == 1
            % Centerline: use circular area
            area = pi * (dr/2)^2;
        elseif i == nr
            % Outer edge: use annular area
            area = pi * (r(i)^2 - (r(i) - dr/2)^2);
        else
            % Interior: use annular area
            area = pi * ((r(i) + dr/2)^2 - (r(i) - dr/2)^2);
        end
        
        % Heat flux from lightsaber to hand (positive when T > T_hand)
        q_local = h_hand * (T(i,1) - T_hand);
        q_hand = q_hand + q_local * area;
    end
end