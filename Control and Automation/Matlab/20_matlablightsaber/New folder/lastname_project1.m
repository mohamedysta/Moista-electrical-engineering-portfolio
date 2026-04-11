%% Lightsaber 2D Heat Transfer Analysis
% Clear workspace
clear; close all; clc;

%% Problem Parameters
% Geometric parameters
L1 = 1.2;        % Core length (m)
L2 = 0.25;       % Handle length (m)
Rcore = 0.02;    % Core radius (m)

% Thermal properties
kcore = 0.35;    % Core thermal conductivity (W/m-K)
khandle = 0.05;  % Handle thermal conductivity (W/m-K)
Rtc_core_handle = 1e-5;  % Contact resistance core-handle (m²-K/W)
Rtc_hand = 1e-4;         % Contact resistance handle-hand (m²-K/W)

% Heat generation
q_gen_0 = 1e6;   % Volumetric heat generation at r=0 (W/m³)

% Boundary conditions
h_air = 50;      % Convection coefficient in air (W/m²-K)
T_air = 20;      % Air temperature (°C)
T_hand = 37.1;   % Hand temperature (°C)
h_water = 5000;  % Convection coefficient in water (W/m²-K)
T_water = 10;    % Water temperature (°C)

%% Grid Generation
% Radial nodes
nr_core = 5;     % Minimum 5 nodes in radial direction
nr_handle = 5;   % Same radial nodes for handle

% Axial nodes
nx_core = 12;    % Minimum 12 nodes for core
nx_handle = 5;   % Minimum 5 nodes for handle

% Grid spacing
dr = Rcore / (nr_core - 1);
dx_core = L1 / (nx_core - 1);
dx_handle = L2 / (nx_handle - 1);

% Create radial positions
r = linspace(0, Rcore, nr_core);

% Create axial positions
x_core = linspace(0, L1, nx_core);
x_handle = linspace(L1, L1 + L2, nx_handle);
x = [x_core, x_handle(2:end)];  % Avoid duplicate at interface

% Update total nodes
nx_total = length(x);
nr_total = nr_core;

% Total number of nodes
N = nx_total * nr_total;

%% Node Numbering and Mapping
% Create node numbering matrix
node_map = zeros(nr_total, nx_total);
node_num = 1;
for j = 1:nx_total
    for i = 1:nr_total
        node_map(i,j) = node_num;
        node_num = node_num + 1;
    end
end

%% Initialize Coefficient Matrix and RHS Vector
A = zeros(N, N);
b = zeros(N, 1);

%% Energy Balance Equations
for j = 1:nx_total
    for i = 1:nr_total
        n = node_map(i,j);  % Current node number
        
        % Determine if in core or handle region
        if j <= nx_core
            k = kcore;
            dx = dx_core;
            % Heat generation term
            q_gen = q_gen_0 * (1 - (r(i)/Rcore)^2);
        else
            k = khandle;
            dx = dx_handle;
            q_gen = 0;  % No heat generation in handle
        end
        
        %% Case 1: Symmetry axis (r = 0)
        if i == 1
            if j == 1
                % Corner node: symmetry + left boundary (hand contact)
                A(n,n) = 1;
                b(n) = T_hand;
            elseif j == nx_total
                % Corner node: symmetry + right boundary (tip of core)
                % Using L'Hopital's rule for cylindrical coordinates
                n_east = node_map(i+1,j);
                n_south = node_map(i,j-1);
                
                A(n,n) = -4*k/dr^2 - 2*k/dx^2 - 2*h_air/(k*dr);
                A(n,n_east) = 4*k/dr^2;
                A(n,n_south) = 2*k/dx^2;
                b(n) = -q_gen - 2*h_air*T_air/(k*dr);
            elseif j == nx_core
                % Interface node on symmetry axis
                n_east = node_map(i+1,j);
                n_south = node_map(i,j-1);
                n_north = node_map(i,j+1);
                
                % Account for contact resistance
                Rex = Rtc_core_handle / (pi * dr^2);
                
                A(n,n) = -4*kcore/dr^2 - kcore/dx_core^2 - 1/(Rex*dx_core);
                A(n,n_east) = 4*kcore/dr^2;
                A(n,n_south) = kcore/dx_core^2;
                A(n,n_north) = 1/(Rex*dx_core);
                b(n) = -q_gen;
            else
                % Interior node on symmetry axis
                n_east = node_map(i+1,j);
                n_south = node_map(i,j-1);
                n_north = node_map(i,j+1);
                
                A(n,n) = -4*k/dr^2 - 2*k/dx^2;
                A(n,n_east) = 4*k/dr^2;
                A(n,n_south) = k/dx^2;
                A(n,n_north) = k/dx^2;
                b(n) = -q_gen;
            end
            
        %% Case 2: Outer surface (r = Rcore)
        elseif i == nr_total
            if j == 1
                % Handle base in contact with hand
                A(n,n) = 1;
                b(n) = T_hand;
            elseif j == nx_total
                % Corner: outer surface + tip
                n_west = node_map(i-1,j);
                n_south = node_map(i,j-1);
                
                A(n,n) = -k/dr - h_air - k/(dx^2) - h_air/(k*dx);
                A(n,n_west) = k/dr;
                A(n,n_south) = k/(dx^2);
                b(n) = -h_air*T_air - h_air*T_air/(k*dx) - q_gen*dr/2;
            else
                % Core outer surface with convection
                n_west = node_map(i-1,j);
                n_south = node_map(i,j-1);
                n_north = node_map(i,j+1);
                
                A(n,n) = -k/dr - h_air - 2*k/(dx^2);
                A(n,n_west) = k/dr;
                A(n,n_south) = k/(dx^2);
                A(n,n_north) = k/(dx^2);
                b(n) = -h_air*T_air - q_gen*dr/2;
            end
            
        %% Case 3: Interface between core and handle
        elseif j == nx_core && i > 1 && i < nr_total
            % Interior interface nodes
            n_west = node_map(i-1,j);
            n_east = node_map(i+1,j);
            n_south = node_map(i,j-1);
            n_north = node_map(i,j+1);
            
            % Contact resistance
            Rex = Rtc_core_handle / (2*pi*r(i)*dr);
            
            A(n,n) = -kcore*(2/dr^2) - kcore/dx_core^2 - 1/(Rex*dx_core);
            A(n,n_west) = kcore*(1/dr^2 - 1/(2*r(i)*dr));
            A(n,n_east) = kcore*(1/dr^2 + 1/(2*r(i)*dr));
            A(n,n_south) = kcore/dx_core^2;
            A(n,n_north) = 1/(Rex*dx_core);
            b(n) = -q_gen;
            
%% Case 4: Handle base (j = 1) - WITH CONTACT RESISTANCE
elseif j == 1
    if i == 1
        % Center node at handle base
        n_north = node_map(i,j+1);
        n_east = node_map(i+1,j);
        
        % Thermal resistance for center node
        R_contact = Rtc_hand / (pi * (dr/2)^2);
        
        A(n,n) = -4*khandle/dr^2 - khandle/dx_handle^2 - 1/(R_contact*dx_handle);
        A(n,n_east) = 4*khandle/dr^2;
        A(n,n_north) = khandle/dx_handle^2;
        b(n) = -T_hand/(R_contact*dx_handle);
        
    elseif i == nr_total
        % Outer edge at handle base (also has convection)
        n_west = node_map(i-1,j);
        n_north = node_map(i,j+1);
        
        % Thermal resistance for outer edge
        R_contact = Rtc_hand / (2*pi*r(i)*dr);
        
        A(n,n) = -khandle/dr - khandle/dx_handle^2 - 1/(R_contact*dx_handle) - h_air;
        A(n,n_west) = khandle/dr;
        A(n,n_north) = khandle/dx_handle^2;
        b(n) = -T_hand/(R_contact*dx_handle) - h_air*T_air;
        
    else
        % Interior nodes at handle base
        n_west = node_map(i-1,j);
        n_east = node_map(i+1,j);
        n_north = node_map(i,j+1);
        
        % Thermal resistance for ring area
        R_contact = Rtc_hand / (2*pi*r(i)*dr);
        
        A(n,n) = -khandle*(2/dr^2) - khandle/dx_handle^2 - 1/(R_contact*dx_handle);
        A(n,n_west) = khandle*(1/dr^2 - 1/(2*r(i)*dr));
        A(n,n_east) = khandle*(1/dr^2 + 1/(2*r(i)*dr));
        A(n,n_north) = khandle/dx_handle^2;
        b(n) = -T_hand/(R_contact*dx_handle);
    end
            
        %% Case 5: Tip nodes (j = nx_total, excluding corners)
        elseif j == nx_total && i > 1 && i < nr_total
            % Interior nodes at the tip
            n_west = node_map(i-1,j);
            n_east = node_map(i+1,j);
            n_south = node_map(i,j-1);
            
            % Energy balance with convection at tip
            A(n,n) = -k*(2/dr^2 + 1/(dx^2)) - h_air/(k*dx);
            A(n,n_west) = k*(1/dr^2 - 1/(2*r(i)*dr));
            A(n,n_east) = k*(1/dr^2 + 1/(2*r(i)*dr));
            A(n,n_south) = k/(dx^2);
            b(n) = -q_gen - h_air*T_air/(k*dx);
            
        %% Case 6: Interior nodes
        else
            n_west = node_map(i-1,j);
            n_east = node_map(i+1,j);
            n_south = node_map(i,j-1);
            n_north = node_map(i,j+1);
            
            % Standard interior node equation
            A(n,n) = -k*(2/dr^2 + 2/(dx^2));
            A(n,n_west) = k*(1/dr^2 - 1/(2*r(i)*dr));
            A(n,n_east) = k*(1/dr^2 + 1/(2*r(i)*dr));
            A(n,n_south) = k/(dx^2);
            A(n,n_north) = k/(dx^2);
            b(n) = -q_gen;
        end
    end
end

%% Solve for Air Scenario
T_air_case = A\b;

% Reshape temperature vector to 2D array
T_2D_air = zeros(nr_total, nx_total);
for j = 1:nx_total
    for i = 1:nr_total
        T_2D_air(i,j) = T_air_case(node_map(i,j));
    end
end

%% Calculate heat transfer to hand
Q_hand = 0;

for i = 1:nr_total
    % Get temperature at handle base
    T_base = T_2D_air(i,1);
    
    if i == 1
        % Center node area
        area = pi * (dr/2)^2;
    else
        % Ring area
        area = 2 * pi * r(i) * dr;
    end
    
    % Heat flux through contact resistance
    q_flux = (T_base - T_hand) / Rtc_hand;
    Q_hand = Q_hand + q_flux * area;
end

fprintf('Heat transfer to Luke''s hand (air): %.2f W\n', Q_hand);

%% Solve for Water Scenario
%% Solve for Water Scenario
% Modify boundary conditions for water
b_water = b;  % Copy RHS vector
A_water = A;  % Copy coefficient matrix

% Update handle base for water case too
for i = 1:nr_total
    n = node_map(i,1);
    
    if i == 1
        R_contact = Rtc_hand / (pi * (dr/2)^2);
        A_water(n,n) = -4*khandle/dr^2 - khandle/dx_handle^2 - 1/(R_contact*dx_handle);
        b_water(n) = -T_hand/(R_contact*dx_handle);
    elseif i == nr_total
        R_contact = Rtc_hand / (2*pi*r(i)*dr);
        A_water(n,n) = -khandle/dr - khandle/dx_handle^2 - 1/(R_contact*dx_handle) - h_water;
        b_water(n) = -T_hand/(R_contact*dx_handle) - h_water*T_water;
    else
        R_contact = Rtc_hand / (2*pi*r(i)*dr);
        A_water(n,n) = -khandle*(2/dr^2) - khandle/dx_handle^2 - 1/(R_contact*dx_handle);
        b_water(n) = -T_hand/(R_contact*dx_handle);
    end
end

% ADD THIS SECTION - Update ALL convection boundary conditions for water
for j = 2:nx_total  % Start from j=2 to skip handle base
    for i = 1:nr_total
        n = node_map(i,j);
        
        % Determine if in core or handle region
        if j <= nx_core
            k = kcore;
            dx = dx_core;
            q_gen = q_gen_0 * (1 - (r(i)/Rcore)^2);
        else
            k = khandle;
            dx = dx_handle;
            q_gen = 0;
        end
        
        % Update outer surface nodes (i = nr_total)
        if i == nr_total
            if j == nx_total
                % Tip corner node - outer surface + tip
                A_water(n,n) = -k/dr - h_water - k/(dx^2) - h_water/(k*dx);
                b_water(n) = -h_water*T_water - h_water*T_water/(k*dx) - q_gen*dr/2;
            else
                % Regular outer surface nodes
                A_water(n,n) = -k/dr - h_water - 2*k/(dx^2);
                b_water(n) = -h_water*T_water - q_gen*dr/2;
            end
        end
        
        % Update tip nodes on symmetry axis
        if i == 1 && j == nx_total
            A_water(n,n) = -4*k/dr^2 - 2*k/dx^2 - 2*h_water/(k*dr);
            b_water(n) = -q_gen - 2*h_water*T_water/(k*dr);
        end
        
        % Update interior tip nodes
        if j == nx_total && i > 1 && i < nr_total
            A_water(n,n) = -k*(2/dr^2 + 1/(dx^2)) - h_water/(k*dx);
            b_water(n) = -q_gen - h_water*T_water/(k*dx);
        end
    end
end

% Solve for water case
T_water_case = A_water\b_water;

% Reshape temperature vector for water case
T_2D_water = zeros(nr_total, nx_total);
for j = 1:nx_total
    for i = 1:nr_total
        T_2D_water(i,j) = T_water_case(node_map(i,j));
    end
end

%% Create meshgrid for plotting
[X, R] = meshgrid(x, r);

%% Plot temperature contours - Air case
figure(1);
subplot(2,1,1);
contourf(X, R, T_2D_air, 20);
colorbar;
xlabel('Axial Distance (m)');
ylabel('Radial Distance (m)');
title('Temperature Distribution in Lightsaber - Air Cooling');
hold on;
% Mark interface
plot([L1, L1], [0, Rcore], 'k--', 'LineWidth', 2);
text(L1/2, Rcore*1.1, 'Core', 'HorizontalAlignment', 'center');
text(L1+L2/2, Rcore*1.1, 'Handle', 'HorizontalAlignment', 'center');
hold off;

% Plot temperature contours - Water case
subplot(2,1,2);
contourf(X, R, T_2D_water, 20);
colorbar;
xlabel('Axial Distance (m)');
ylabel('Radial Distance (m)');
title('Temperature Distribution in Lightsaber - Water Cooling (Boiling)');
hold on;
% Mark interface
plot([L1, L1], [0, Rcore], 'k--', 'LineWidth', 2);
text(L1/2, Rcore*1.1, 'Core', 'HorizontalAlignment', 'center');
text(L1+L2/2, Rcore*1.1, 'Handle', 'HorizontalAlignment', 'center');
hold off;

%% Create more detailed contour plots
figure(2);
% Air case
subplot(1,2,1);
[C,h] = contourf(X*100, R*100, T_2D_air, 15);
clabel(C,h,'Color','white');
colormap(hot);
c = colorbar;
c.Label.String = 'Temperature (°C)';
xlabel('Axial Distance (cm)');
ylabel('Radial Distance (cm)');
title('Air Cooling (h = 50 W/m²·K)');
grid on;
hold on;
plot([L1*100, L1*100], [0, Rcore*100], 'b--', 'LineWidth', 2);
hold off;

% Water case
subplot(1,2,2);
[C,h] = contourf(X*100, R*100, T_2D_water, 15);
clabel(C,h,'Color','white');
colormap(hot);
c = colorbar;
c.Label.String = 'Temperature (°C)';
xlabel('Axial Distance (cm)');
ylabel('Radial Distance (cm)');
title('Water Cooling - Boiling (h = 5000 W/m²·K)');
grid on;
hold on;
plot([L1*100, L1*100], [0, Rcore*100], 'b--', 'LineWidth', 2);
hold off;

%% Print maximum temperatures
fprintf('\nMaximum Temperatures:\n');
fprintf('Air cooling: %.2f °C\n', max(T_2D_air(:)));
fprintf('Water cooling: %.2f °C\n', max(T_2D_water(:)));

%% Plot axial temperature distribution along centerline
figure(3);
plot(x*100, T_2D_air(1,:), 'r-', 'LineWidth', 2);
hold on;
plot(x*100, T_2D_water(1,:), 'b-', 'LineWidth', 2);
xlabel('Axial Distance (cm)');
ylabel('Temperature (°C)');
title('Centerline Temperature Distribution');
legend('Air Cooling', 'Water Cooling', 'Location', 'best');
grid on;
% Mark interface
xline(L1*100, '--k', 'Core-Handle Interface');

%% Plot radial temperature distribution at different axial locations
figure(4);
% Select a few axial locations
x_locs = [0.3, 0.6, 0.9, 1.2, 1.35];  % in meters
subplot(2,1,1);
for loc = x_locs
    [~, idx] = min(abs(x - loc));
    plot(r*100, T_2D_air(:,idx), 'LineWidth', 2, 'DisplayName', sprintf('x = %.1f m', loc));
    hold on;
end
xlabel('Radial Distance (cm)');
ylabel('Temperature (°C)');
title('Radial Temperature Profiles - Air Cooling');
legend('Location', 'best');
grid on;

subplot(2,1,2);
for loc = x_locs
    [~, idx] = min(abs(x - loc));
    plot(r*100, T_2D_water(:,idx), 'LineWidth', 2, 'DisplayName', sprintf('x = %.1f m', loc));
    hold on;
end
xlabel('Radial Distance (cm)');
ylabel('Temperature (°C)');
title('Radial Temperature Profiles - Water Cooling');
legend('Location', 'best');
grid on;

%% Display heat generation profile
figure(5);
r_plot = linspace(0, Rcore, 100);
q_plot = q_gen_0 * (1 - (r_plot/Rcore).^2);
plot(r_plot*100, q_plot/1e6, 'LineWidth', 2);
xlabel('Radial Distance (cm)');
ylabel('Heat Generation (MW/m³)');
title('Volumetric Heat Generation Profile in Core');
grid on;

%% Call energy balance check for air case
check_energy_balance(T_2D_air, r, x, kcore, khandle, q_gen_0, Rcore, h_air, T_air, Q_hand, L1, L2);

%% Summary Report
fprintf('\n=== LIGHTSABER THERMAL ANALYSIS SUMMARY ===\n');
fprintf('Grid: %d radial × %d axial = %d total nodes\n', nr_total, nx_total, N);
fprintf('Core: %d axial nodes, Handle: %d axial nodes\n', nx_core, nx_handle);
fprintf('\nBoundary Conditions:\n');
fprintf('- Hand temperature: %.1f °C\n', T_hand);
fprintf('- Air temperature: %.1f °C (h = %d W/m²·K)\n', T_air, h_air);
fprintf('- Water temperature: %.1f °C (h = %d W/m²·K)\n', T_water, h_water);
fprintf('\nResults:\n');
fprintf('- Heat to hand (air): %.2f W\n', Q_hand);
fprintf('- Max temp (air): %.1f °C\n', max(T_2D_air(:)));
fprintf('- Max temp (water): %.1f °C\n', max(T_2D_water(:)));
fprintf('- Location of max temp: Core centerline near handle interface\n');

%% Create sketch for documentation
figure(6);
clf;
% Draw lightsaber schematic
rectangle('Position', [0, -Rcore*100, L1*100, 2*Rcore*100], 'FaceColor', [1 0.5 0], 'EdgeColor', 'k', 'LineWidth', 2);
rectangle('Position', [L1*100, -Rcore*100, L2*100, 2*Rcore*100], 'FaceColor', [0.5 0.5 1], 'EdgeColor', 'k', 'LineWidth', 2);

% Add labels
text(L1*50, 0, 'CORE', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 12);
text((L1+L2/2)*100, 0, 'HANDLE', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 12);

% Add dimensions
annotation('doublearrow', [0.1 0.55], [0.25 0.25]);
text(L1*50, -Rcore*150, sprintf('L₁ = %d cm', L1*100), 'HorizontalAlignment', 'center');

annotation('doublearrow', [0.55 0.75], [0.25 0.25]);
text((L1+L2/2)*100, -Rcore*150, sprintf('L₂ = %d cm', L2*100), 'HorizontalAlignment', 'center');

% Add coordinate system
annotation('arrow', [0.1 0.2], [0.5 0.5]);
text(15, 0, 'x', 'FontSize', 12, 'FontWeight', 'bold');
annotation('arrow', [0.1 0.1], [0.5 0.6]);
text(0, Rcore*150, 'r', 'FontSize', 12, 'FontWeight', 'bold');

% Add boundary conditions
text(-10, 0, 'r=0 (symmetry)', 'HorizontalAlignment', 'right', 'FontSize', 10);
text((L1+L2)*100+5, 0, sprintf('h=%d W/m²K\nT∞=%d°C', h_air, T_air), 'FontSize', 10);
text(L1*100, Rcore*120, 'R"tc', 'HorizontalAlignment', 'center', 'FontSize', 10);

title('Lightsaber Geometry and Boundary Conditions');
axis equal;
xlim([-20 (L1+L2)*100+20]);
ylim([-Rcore*200 Rcore*200]);
set(gca, 'YTick', []);
xlabel('Axial Distance (cm)');
% % %% 
% %%Create Nodal Diagram and Control Volume Figure
% figure(8);
% clf;
% 
% % Set up the plot
% subplot(2,1,1);
% title('Node Numbering Scheme and Grid Layout', 'FontSize', 14, 'FontWeight', 'bold');
% 
% % Define display parameters
% n_show_x = 8;  % Show first 8 axial nodes for clarity
% n_show_r = nr_total;  % Show all radial nodes
% 
% % Create grid for visualization
% hold on;
% 
% % Draw grid lines
% for i = 1:n_show_r+1
%     plot([0, n_show_x], [(i-1), (i-1)], 'k-', 'LineWidth', 1);
% end
% for j = 1:n_show_x+1
%     plot([(j-1), (j-1)], [0, n_show_r], 'k-', 'LineWidth', 1);
% end
% 
% % Add node numbers
% for j = 1:n_show_x
%     for i = 1:n_show_r
%         node_num = node_map(i,j);
%         text(j-0.5, n_show_r-i+0.5, num2str(node_num), ...
%             'HorizontalAlignment', 'center', 'FontSize', 10);
%     end
% end
% 
% % Add axis labels
% xlabel('Axial Node Index (j)', 'FontSize', 12);
% ylabel('Radial Node Index (i)', 'FontSize', 12);
% set(gca, 'YDir', 'reverse');
% axis equal;
% xlim([0, n_show_x]);
% ylim([0, n_show_r]);
% 
% % Add annotations
% text(n_show_x/2, -0.5, 'x →', 'FontSize', 12, 'HorizontalAlignment', 'center');
% text(-0.5, n_show_r/2, 'r →', 'FontSize', 12, 'HorizontalAlignment', 'center', 'Rotation', 90);
% 
% % Mark special regions
% text(0.5, -1, 'j=1\nHandle\nBase', 'FontSize', 9, 'HorizontalAlignment', 'center');
% text(n_show_x-0.5, -1, '...\nj=16\nTip', 'FontSize', 9, 'HorizontalAlignment', 'center');
% text(-1.5, 0.5, 'i=1\nSymmetry', 'FontSize', 9, 'HorizontalAlignment', 'center');
% text(-1.5, n_show_r-0.5, 'i=5\nOuter\nSurface', 'FontSize', 9, 'HorizontalAlignment', 'center');
% 
% % Control Volume Identification
% subplot(2,1,2);
% title('Unique Control Volume Types', 'FontSize', 14, 'FontWeight', 'bold');
% 
% % Create a simplified grid showing different CV types
% cv_grid = zeros(5, 7);
% cv_types = {'Interior', 'Symmetry', 'Surface', 'Base', 'Interface', 'Corner'};
% cv_colors = [1 1 1;      % Interior - white
%              0.9 0.9 0.5; % Symmetry - light yellow
%              0.5 0.9 0.5; % Surface - light green
%              0.5 0.5 0.9; % Base - light blue
%              0.9 0.5 0.5; % Interface - light red
%              0.7 0.7 0.7]; % Corner - gray
% 
% % Set control volume types
% cv_grid(:,:) = 1;  % Interior
% cv_grid(1,:) = 2;  % Symmetry axis
% cv_grid(5,:) = 3;  % Outer surface
% cv_grid(:,1) = 4;  % Handle base
% cv_grid(:,5) = 5;  % Interface
% cv_grid([1,5],[1,5,7]) = 6;  % Corners
% 
% % Display the grid
% imagesc(cv_grid);
% colormap(cv_colors);
% hold on;
% 
% % Draw grid lines
% for i = 0.5:1:5.5
%     plot([0.5, 7.5], [i, i], 'k-', 'LineWidth', 1);
% end
% for j = 0.5:1:7.5
%     plot([j, j], [0.5, 5.5], 'k-', 'LineWidth', 1);
% end
% 
% % Add labels
% text(3.5, -0.5, 'Axial Direction', 'FontSize', 12, 'HorizontalAlignment', 'center');
% text(-0.5, 3, 'Radial', 'FontSize', 12, 'HorizontalAlignment', 'center', 'Rotation', 90);
% 
% % Add legend
% for i = 1:length(cv_types)
%     rectangle('Position', [8, 5.5-i, 0.5, 0.5], 'FaceColor', cv_colors(i,:), ...
%         'EdgeColor', 'k');
%     text(8.7, 5.75-i, cv_types{i}, 'FontSize', 10, 'VerticalAlignment', 'middle');
% end
% 
% axis equal;
% xlim([0, 11]);
% ylim([0, 6]);
% set(gca, 'XTick', [], 'YTick', []);
% 
% saveas(figure(8), 'nodal_diagram.png');


%% Create a 3D visualization
figure(7);
[X3D, R3D] = meshgrid(x*100, r*100);
surf(X3D, R3D, T_2D_air);
shading interp;
colormap(hot);
colorbar;
xlabel('Axial Distance (cm)');
ylabel('Radial Distance (cm)');
zlabel('Temperature (°C)');
title('3D Temperature Distribution - Air Cooling');
view(45, 30);
grid on;

%% Export results to file for documentation
if exist('results.txt', 'file')
    delete('results.txt');
end

fileID = fopen('results.txt', 'w');
fprintf(fileID, 'LIGHTSABER THERMAL ANALYSIS RESULTS\n');
fprintf(fileID, '====================================\n\n');
fprintf(fileID, 'Problem Parameters:\n');
fprintf(fileID, '- Core length: %.2f m\n', L1);
fprintf(fileID, '- Handle length: %.2f m\n', L2);
fprintf(fileID, '- Core radius: %.3f m\n', Rcore);
fprintf(fileID, '- Core thermal conductivity: %.2f W/m-K\n', kcore);
fprintf(fileID, '- Handle thermal conductivity: %.2f W/m-K\n', khandle);
fprintf(fileID, '- Max heat generation: %.1e W/m³\n', q_gen_0);
fprintf(fileID, '\nNumerical Grid:\n');
fprintf(fileID, '- Radial nodes: %d\n', nr_total);
fprintf(fileID, '- Axial nodes (core): %d\n', nx_core);
fprintf(fileID, '- Axial nodes (handle): %d\n', nx_handle);
fprintf(fileID, '- Total nodes: %d\n', N);
fprintf(fileID, '\nResults Summary:\n');
fprintf(fileID, '1. Air Cooling Scenario:\n');
fprintf(fileID, '   - Maximum temperature: %.1f °C\n', max(T_2D_air(:)));
fprintf(fileID, '   - Heat transfer to hand: %.2f W\n', Q_hand);
fprintf(fileID, '2. Water Cooling Scenario:\n');
fprintf(fileID, '   - Maximum temperature: %.1f °C\n', max(T_2D_water(:)));
fclose(fileID);

%% Pseudo-code documentation
% This creates a separate file with the pseudo-code for the algorithm
fileID = fopen('pseudocode.txt', 'w');
fprintf(fileID, 'PSEUDO-CODE FOR LIGHTSABER THERMAL ANALYSIS\n');
fprintf(fileID, '==========================================\n\n');
fprintf(fileID, '1. INITIALIZATION\n');
fprintf(fileID, '   - Define geometric parameters (L1, L2, Rcore)\n');
fprintf(fileID, '   - Define thermal properties (k_core, k_handle, contact resistances)\n');
fprintf(fileID, '   - Define boundary conditions (T_air, T_hand, h_air, h_water)\n');
fprintf(fileID, '   - Create grid with specified number of nodes\n\n');
fprintf(fileID, '2. NODE NUMBERING\n');
fprintf(fileID, '   - Create 2D array mapping (i,j) position to node number\n');
fprintf(fileID, '   - Number nodes from 1 to N (total nodes)\n\n');
fprintf(fileID, '3. ENERGY BALANCE EQUATIONS\n');
fprintf(fileID, '   FOR each node (i,j):\n');
fprintf(fileID, '      CASE: Symmetry axis (i=1)\n');
fprintf(fileID, '         - Use L''Hopital''s rule for r→0\n');
fprintf(fileID, '         - Special treatment for ∂T/∂r = 0\n');
fprintf(fileID, '      CASE: Outer surface (i=nr)\n');
fprintf(fileID, '         - Apply convection boundary condition\n');
fprintf(fileID, '         - q"_conv = h(T_surface - T_infinity)\n');
fprintf(fileID, '      CASE: Core-handle interface (j=nx_core)\n');
fprintf(fileID, '         - Apply contact resistance\n');
fprintf(fileID, '         - q" = (T_core - T_handle)/R"_tc\n');
fprintf(fileID, '      CASE: Handle base (j=1)\n');
fprintf(fileID, '         - Fixed temperature T_hand\n');
fprintf(fileID, '         - Consider contact resistance with hand\n');
fprintf(fileID, '      CASE: Interior nodes\n');
fprintf(fileID, '         - Standard 2D cylindrical conduction\n');
fprintf(fileID, '         - Include heat generation for core nodes\n\n');
fprintf(fileID, '4. MATRIX ASSEMBLY\n');
fprintf(fileID, '   - Build coefficient matrix A (N×N)\n');
fprintf(fileID, '   - Build right-hand side vector b (N×1)\n');
fprintf(fileID, '   - Each row represents one node equation\n\n');
fprintf(fileID, '5. SOLUTION\n');
fprintf(fileID, '   - Solve linear system: A*T = b\n');
fprintf(fileID, '   - Use direct solver (backslash in MATLAB)\n\n');
fprintf(fileID, '6. POST-PROCESSING\n');
fprintf(fileID, '   - Reshape 1D temperature vector to 2D array\n');
fprintf(fileID, '   - Calculate heat transfer to hand\n');
fprintf(fileID, '   - Create contour plots\n');
fprintf(fileID, '   - Repeat for water cooling scenario\n');
fclose(fileID);

%% Save all figures
saveas(figure(1), 'temperature_contours_comparison.png');
saveas(figure(2), 'temperature_contours_detailed.png');
saveas(figure(3), 'centerline_temperature.png');
saveas(figure(4), 'radial_profiles.png');
saveas(figure(5), 'heat_generation_profile.png');
saveas(figure(6), 'lightsaber_schematic.png');
saveas(figure(7), 'temperature_3D.png');

fprintf('\n=== Analysis Complete ===\n');
fprintf('All results and figures have been generated.\n');

%% Function definitions must be at the end
function check_energy_balance(T_2D, r, x, kcore, khandle, q_gen_0, Rcore, h, T_inf, Q_hand, L1, L2)
    % Get grid parameters
    nr = length(r);
    nx = length(x);
    nx_core = sum(x <= L1);  % Count nodes in core (including interface)
    dr = r(2) - r(1);
    dx_core = L1 / (nx_core - 1);
    dx_handle = L2 / (nx - nx_core);
    
    %% 1. Calculate total heat generation (only in core)
    Q_gen_total = 0;
    
    for j = 1:nx_core
        for i = 1:nr
            % Radial control volume boundaries
            if i == 1
                r_inner = 0;
                r_outer = dr/2;
            elseif i == nr
                r_inner = r(i) - dr/2;
                r_outer = Rcore;
            else
                r_inner = r(i) - dr/2;
                r_outer = r(i) + dr/2;
            end
            
            % Axial control volume size
            if j == 1
                % First node: half CV forward
                dx = dx_core/2;
            elseif j == nx_core
                % Last core node: half CV backward
                dx = dx_core/2;
            else
                % Interior nodes: full CV
                dx = dx_core;
            end
            
            % Volume and heat generation
            vol = pi * (r_outer^2 - r_inner^2) * dx;
            q_gen = q_gen_0 * (1 - (r(i)/Rcore)^2);
            Q_gen_total = Q_gen_total + q_gen * vol;
        end
    end
    
    %% 2. Calculate convection from outer surface (r = Rcore)
    Q_conv_sides = 0;
    
    % For each axial position (skip j=1 which is handle base)
    for j = 2:nx
        % Determine dx based on region
        if j <= nx_core
            dx_local = dx_core;
        else
            dx_local = dx_handle;
        end
        
        % Control volume length for this surface segment
        if j == 2
            % Node 2: half CV backward, full CV forward
            dx_cv = dx_local;
        elseif j == nx
            % Last node: half CV backward only
            dx_cv = dx_local/2;
        elseif j == nx_core && j > 2
            % Interface node (if not node 2): half CV in each direction
            dx_cv = dx_core/2 + dx_handle/2;
        else
            % Interior nodes: full CV
            dx_cv = dx_local;
        end
        
        % Surface area and convection
        area = 2 * pi * Rcore * dx_cv;
        T_surf = T_2D(nr, j);
        Q_conv_sides = Q_conv_sides + h * area * (T_surf - T_inf);
    end
    
    %% 3. Calculate heat transfer through tip
    Q_tip = 0;
    j_tip = nx;
    
    for i = 1:nr
        % Radial boundaries for area calculation
        if i == 1
            r_inner = 0;
            r_outer = dr/2;
        elseif i == nr
            r_inner = r(i) - dr/2;
            r_outer = Rcore;
        else
            r_inner = r(i) - dr/2;
            r_outer = r(i) + dr/2;
        end
        
        % Area and heat transfer
        area = pi * (r_outer^2 - r_inner^2);
        T_tip = T_2D(i, j_tip);
        Q_tip = Q_tip + h * area * (T_tip - T_inf);
    end
    
    %% 4. Energy balance summary
    Q_total_out = Q_hand + Q_conv_sides + Q_tip;
    balance_error = abs(Q_gen_total - Q_total_out);
    percent_error = 100 * balance_error / Q_gen_total;
    
    fprintf('\n=== ENERGY BALANCE CHECK ===\n');
    fprintf('Heat Generation:\n');
    fprintf('  Total generation in core: %.2f W\n', Q_gen_total);
    fprintf('\nHeat Losses:\n');
    fprintf('  Heat to hand: %.2f W (%.1f%%)\n', Q_hand, 100*Q_hand/Q_gen_total);
    fprintf('  Convection from sides: %.2f W (%.1f%%)\n', Q_conv_sides, 100*Q_conv_sides/Q_gen_total);
    fprintf('  Convection from tip: %.2f W (%.1f%%)\n', Q_tip, 100*Q_tip/Q_gen_total);
    fprintf('  Total heat out: %.2f W\n', Q_total_out);
    fprintf('\nBalance:\n');
    fprintf('  Error: %.2f W (%.2f%%)\n', balance_error, percent_error);
    
    if percent_error > 5
        fprintf('  WARNING: Energy balance error exceeds 5%%!\n');
    else
        fprintf('  ✓ Energy balance is acceptable\n');
    end
    
    %% Additional diagnostics
    fprintf('\nDiagnostics:\n');
    fprintf('  Core nodes: %d\n', nx_core);
    fprintf('  Handle nodes: %d\n', nx - nx_core);
    fprintf('  Total axial nodes: %d\n', nx);
    fprintf('  Radial nodes: %d\n', nr);
    [max_temp, max_idx] = max(T_2D(:));
    [i_max, j_max] = ind2sub(size(T_2D), max_idx);
    fprintf('  Max temperature: %.1f°C at (i=%d, j=%d)\n', max_temp, i_max, j_max);
    
    % Debug information
    fprintf('\nDebug Info:\n');
    fprintf('  dx_core = %.4f m\n', dx_core);
    fprintf('  dx_handle = %.4f m\n', dx_handle);
    fprintf('  dr = %.4f m\n', dr);
    fprintf('  Tip temperatures: [');
    fprintf('%.1f ', T_2D(:, nx));
    fprintf('] °C\n');
end