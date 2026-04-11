%% Debug Section - Add after solving
fprintf('\n=== DEBUGGING INFO ===\n');

% Check heat generation
total_heat_gen = 0;
for j = nx_handle+1:nx_total
    for i = 1:nr
        if i == 1
            vol = pi * (dr/2)^2 * dx_core;
        else
            vol = 2 * pi * r(i) * dr * dx_core;
        end
        total_heat_gen = total_heat_gen + q_gen(r(i)) * vol;
    end
end
fprintf('Total heat generation: %.2f W\n', total_heat_gen);

% Check matrix properties
fprintf('Matrix condition number: %.2e\n', condest(A));
fprintf('Matrix rank: %d (should be %d)\n', rank(full(A)), n_total);

% Check energy balance
heat_to_hand = q_hand_air;
heat_conv_core = 0;
heat_conv_handle = 0;

% Convection from core surface
for j = nx_handle+1:nx_total
    if j == nx_total
        area = 2*pi*Rcore*dx_core/2;
    else
        area = 2*pi*Rcore*dx_core;
    end
    heat_conv_core = heat_conv_core + h_air*(T_air_case(nr,j) - T_air)*area;
end

% Convection from handle surface
for j = 1:nx_handle-1
    if j == 1
        area = 2*pi*Rcore*dx_handle/2;
    else
        area = 2*pi*Rcore*dx_handle;
    end
    heat_conv_handle = heat_conv_handle + h_air*(T_air_case(nr,j) - T_air)*area;
end

fprintf('\nEnergy Balance Check:\n');
fprintf('Heat generated: %.2f W\n', total_heat_gen);
fprintf('Heat to hand: %.2f W\n', heat_to_hand);
fprintf('Heat conv from core: %.2f W\n', heat_conv_core);
fprintf('Heat conv from handle: %.2f W\n', heat_conv_handle);
fprintf('Total heat out: %.2f W\n', heat_to_hand + heat_conv_core + heat_conv_handle);
fprintf('Imbalance: %.2f W (%.2f%%)\n', ...
    total_heat_gen - (heat_to_hand + heat_conv_core + heat_conv_handle), ...
    100*abs(total_heat_gen - (heat_to_hand + heat_conv_core + heat_conv_handle))/total_heat_gen);