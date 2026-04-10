using System;
using System.Collections.Generic;
using System.Linq;

namespace IndustrialElectricalDesignCalculator
{
    class Program
    {
        static void Main(string[] args)
        {
            ElectricalDesignCalculator calculator = new ElectricalDesignCalculator();
            calculator.Run();
        }
    }

    public class ElectricalDesignCalculator
    {
        private List<ElectricalLoad> loads;
        private double totalPower;
        private double totalCurrent;
        private double estimatedCost;

        public ElectricalDesignCalculator()
        {
            loads = new List<ElectricalLoad>();
        }

        public void Run()
        {
            Console.WriteLine("===============================================");
            Console.WriteLine("  INDUSTRIAL ELECTRICAL POWER SYSTEM DESIGNER");
            Console.WriteLine("===============================================");
            Console.WriteLine();

            bool continueProgram = true;

            // Main program loop (do-while implementation)
            do
            {
                DisplayMainMenu();
                int choice = GetValidMenuChoice();

                // Switch statement for menu navigation
                switch (choice)
                {
                    case 1:
                        AddElectricalLoads();
                        break;
                    case 2:
                        DisplayLoadSummary();
                        break;
                    case 3:
                        CalculateTransformerSizing();
                        break;
                    case 4:
                        CalculateConductorSizing();
                        break;
                    case 5:
                        EstimateProjectCost();
                        break;
                    case 6:
                        GenerateDesignReport();
                        break;
                    case 7:
                        continueProgram = false;
                        Console.WriteLine("Thank you for using Industrial Electrical Design Calculator!");
                        break;
                    default:
                        Console.WriteLine("Invalid choice. Please try again.");
                        break;
                }

                if (continueProgram)
                {
                    Console.WriteLine("\nPress any key to continue...");
                    Console.ReadKey();
                    Console.Clear();
                }

            } while (continueProgram);
        }

        private void DisplayMainMenu()
        {
            Console.WriteLine("MAIN MENU:");
            Console.WriteLine("1. Add Electrical Loads");
            Console.WriteLine("2. Display Load Summary");
            Console.WriteLine("3. Calculate Transformer Sizing");
            Console.WriteLine("4. Calculate Conductor Sizing");
            Console.WriteLine("5. Estimate Project Cost");
            Console.WriteLine("6. Generate Design Report");
            Console.WriteLine("7. Exit");
            Console.Write("\nSelect an option (1-7): ");
        }

        private int GetValidMenuChoice()
        {
            int choice;

            // Input validation using while loop
            while (!int.TryParse(Console.ReadLine(), out choice) || choice < 1 || choice > 7)
            {
                Console.Write("Invalid input! Please enter a number between 1 and 7: ");
            }

            return choice;
        }

        private void AddElectricalLoads()
        {
            Console.Clear();
            Console.WriteLine("ADD ELECTRICAL LOADS");
            Console.WriteLine("===================");

            int numberOfLoads = GetValidIntInput("Enter number of loads to add: ", 1, 50);

            // For loop to add multiple loads
            for (int i = 1; i <= numberOfLoads; i++)
            {
                Console.WriteLine($"\nLoad #{i}:");

                string loadName = GetValidStringInput("Enter load name: ");
                double power = GetValidDoubleInput("Enter power (kW): ", 0.1, 10000);
                double voltage = GetValidVoltageInput("Enter voltage (V): ");
                double powerFactor = GetValidPowerFactorInput("Enter power factor (0.1-1.0): ");
                string loadType = GetValidLoadTypeInput("Enter load type (Motor/Lighting/HVAC/Other): ");

                ElectricalLoad load = new ElectricalLoad(loadName, power, voltage, powerFactor, loadType);
                loads.Add(load);

                Console.WriteLine($"Load '{loadName}' added successfully!");
            }

            Console.WriteLine($"\nTotal {numberOfLoads} load(s) added to the system.");
        }

        private void DisplayLoadSummary()
        {
            Console.Clear();
            Console.WriteLine("ELECTRICAL LOADS SUMMARY");
            Console.WriteLine("========================");

            // Validation using if statement
            if (loads.Count == 0)
            {
                Console.WriteLine("No loads have been added to the system yet.");
                return;
            }

            Console.WriteLine($"{"Load Name",-20} {"Power (kW)",-12} {"Voltage (V)",-12} {"PF",-8} {"Current (A)",-12} {"Type",-10}");
            Console.WriteLine(new string('-', 80));

            totalPower = 0;
            totalCurrent = 0;

            // Enhanced for loop with index
            for (int i = 0; i < loads.Count; i++)
            {
                var load = loads[i];
                double current = (load.Power * 1000) / (load.Voltage * load.PowerFactor);

                Console.WriteLine($"{load.Name,-20} {load.Power,-12:F2} {load.Voltage,-12:F0} {load.PowerFactor,-8:F2} {current,-12:F2} {load.LoadType,-10}");

                totalPower += load.Power;
                totalCurrent += current;
            }

            Console.WriteLine(new string('-', 80));
            Console.WriteLine($"{"TOTAL:",-20} {totalPower,-12:F2} {"",-12} {"",-8} {totalCurrent,-12:F2}");
        }

        private void CalculateTransformerSizing()
        {
            Console.Clear();
            Console.WriteLine("TRANSFORMER SIZING CALCULATION");
            Console.WriteLine("==============================");

            if (loads.Count == 0)
            {
                Console.WriteLine("Please add electrical loads first.");
                return;
            }

            // Calculate total apparent power
            double totalApparentPower = 0;

            foreach (var load in loads)
            {
                totalApparentPower += load.Power / load.PowerFactor;
            }

            // Apply safety factor using if-else statements
            double safetyFactor;
            if (totalApparentPower < 100)
            {
                safetyFactor = 1.25; // 25% safety margin for small systems
            }
            else if (totalApparentPower < 500)
            {
                safetyFactor = 1.20; // 20% safety margin for medium systems
            }
            else
            {
                safetyFactor = 1.15; // 15% safety margin for large systems
            }

            double requiredTransformerSize = totalApparentPower * safetyFactor;

            // Determine standard transformer sizes using switch
            int standardSize = GetStandardTransformerSize(requiredTransformerSize);

            Console.WriteLine($"Total Connected Load: {totalPower:F2} kW");
            Console.WriteLine($"Total Apparent Power: {totalApparentPower:F2} kVA");
            Console.WriteLine($"Safety Factor Applied: {safetyFactor:F2}");
            Console.WriteLine($"Required Transformer Size: {requiredTransformerSize:F2} kVA");
            Console.WriteLine($"Recommended Standard Size: {standardSize} kVA");

            // Efficiency analysis
            double efficiency = (requiredTransformerSize / standardSize) * 100;

            if (efficiency > 90)
            {
                Console.WriteLine($"Efficiency: {efficiency:F1}% - Excellent sizing");
            }
            else if (efficiency > 80)
            {
                Console.WriteLine($"Efficiency: {efficiency:F1}% - Good sizing");
            }
            else if (efficiency > 70)
            {
                Console.WriteLine($"Efficiency: {efficiency:F1}% - Fair sizing, consider next smaller size");
            }
            else
            {
                Console.WriteLine($"Efficiency: {efficiency:F1}% - Poor sizing, transformer oversized");
            }
        }

        private int GetStandardTransformerSize(double requiredSize)
        {
            int[] standardSizes = { 15, 25, 37, 50, 75, 100, 150, 225, 300, 500, 750, 1000, 1500, 2000, 2500 };

            // Find appropriate standard size using for loop
            for (int i = 0; i < standardSizes.Length; i++)
            {
                if (requiredSize <= standardSizes[i])
                {
                    return standardSizes[i];
                }
            }

            // If larger than standard sizes, calculate custom size
            return (int)Math.Ceiling(requiredSize / 100) * 100;
        }

        private void CalculateConductorSizing()
        {
            Console.Clear();
            Console.WriteLine("CONDUCTOR SIZING CALCULATION");
            Console.WriteLine("============================");

            if (loads.Count == 0)
            {
                Console.WriteLine("Please add electrical loads first.");
                return;
            }

            Console.WriteLine($"{"Load Name",-20} {"Current (A)",-12} {"Cable Size (mm²)",-16} {"Voltage Drop (%)",-15}");
            Console.WriteLine(new string('-', 70));

            // Calculate conductor sizing for each load using enhanced for loop
            for (int i = 0; i < loads.Count; i++)
            {
                var load = loads[i];
                double current = (load.Power * 1000) / (load.Voltage * load.PowerFactor);

                // Determine cable size based on current
                double cableSize = CalculateCableSize(current);

                // Calculate voltage drop (assuming 100m cable length)
                double voltageDropPercent = CalculateVoltageDrop(current, 100, cableSize, load.Voltage);

                Console.WriteLine($"{load.Name,-20} {current,-12:F2} {cableSize,-16:F1} {voltageDropPercent,-15:F2}");

                // Validation for voltage drop using if statement
                if (voltageDropPercent > 3.0)
                {
                    Console.WriteLine($"    WARNING: Voltage drop exceeds 3% limit!");
                }
            }
        }

        private double CalculateCableSize(double current)
        {
            // Apply safety factor
            double designCurrent = current * 1.25;

            // Standard cable sizes and current ratings
            var cableSizes = new Dictionary<double, double>
            {
                { 1.5, 18 }, { 2.5, 25 }, { 4, 32 }, { 6, 41 }, { 10, 57 },
                { 16, 76 }, { 25, 101 }, { 35, 125 }, { 50, 151 }, { 70, 192 },
                { 95, 232 }, { 120, 269 }, { 150, 309 }, { 185, 353 }, { 240, 415 }
            };

            // Find appropriate cable size using foreach loop
            foreach (var cable in cableSizes)
            {
                if (designCurrent <= cable.Value)
                {
                    return cable.Key;
                }
            }

            return 300; // Default for very high currents
        }

        private double CalculateVoltageDrop(double current, double length, double cableSize, double voltage)
        {
            // Copper resistivity at 70°C
            double resistivity = 0.0234; // ohm.mm²/m
            double resistance = (resistivity * length * 2) / cableSize; // 2 for single phase
            double voltageDrop = current * resistance;

            return (voltageDrop / voltage) * 100;
        }

        private void EstimateProjectCost()
        {
            Console.Clear();
            Console.WriteLine("PROJECT COST ESTIMATION");
            Console.WriteLine("=======================");

            if (loads.Count == 0)
            {
                Console.WriteLine("Please add electrical loads first.");
                return;
            }

            double materialCost = 0;
            double laborCost = 0;
            double equipmentCost = 0;

            // Calculate costs using while loop and counters
            int loadCounter = 0;
            while (loadCounter < loads.Count)
            {
                var load = loads[loadCounter];

                // Material cost based on load type using switch
                double loadMaterialCost = 0;
                switch (load.LoadType.ToUpper())
                {
                    case "MOTOR":
                        loadMaterialCost = load.Power * 150; // $150 per kW for motors
                        break;
                    case "LIGHTING":
                        loadMaterialCost = load.Power * 80; // $80 per kW for lighting
                        break;
                    case "HVAC":
                        loadMaterialCost = load.Power * 120; // $120 per kW for HVAC
                        break;
                    default:
                        loadMaterialCost = load.Power * 100; // $100 per kW for other loads
                        break;
                }

                materialCost += loadMaterialCost;
                laborCost += load.Power * 50; // $50 per kW labor
                equipmentCost += load.Power * 25; // $25 per kW equipment

                loadCounter++;
            }

            // Add transformer cost
            double totalApparentPower = loads.Sum(l => l.Power / l.PowerFactor);
            int transformerSize = GetStandardTransformerSize(totalApparentPower * 1.2);
            double transformerCost = transformerSize * 8; // $8 per kVA

            // Add panel and protection costs
            double panelCost = loads.Count * 500; // $500 per load for panels and protection

            double subtotal = materialCost + laborCost + equipmentCost + transformerCost + panelCost;
            double contingency = subtotal * 0.15; // 15% contingency
            double tax = subtotal * 0.08; // 8% tax

            estimatedCost = subtotal + contingency + tax;

            Console.WriteLine($"Material Cost:        ${materialCost:F2}");
            Console.WriteLine($"Labor Cost:           ${laborCost:F2}");
            Console.WriteLine($"Equipment Cost:       ${equipmentCost:F2}");
            Console.WriteLine($"Transformer Cost:     ${transformerCost:F2}");
            Console.WriteLine($"Panel & Protection:   ${panelCost:F2}");
            Console.WriteLine($"Subtotal:            ${subtotal:F2}");
            Console.WriteLine($"Contingency (15%):    ${contingency:F2}");
            Console.WriteLine($"Tax (8%):            ${tax:F2}");
            Console.WriteLine(new string('-', 40));
            Console.WriteLine($"TOTAL PROJECT COST:   ${estimatedCost:F2}");

            // Cost analysis using if-else statements
            if (estimatedCost < 10000)
            {
                Console.WriteLine("\nProject Classification: Small Industrial Installation");
            }
            else if (estimatedCost < 50000)
            {
                Console.WriteLine("\nProject Classification: Medium Industrial Installation");
            }
            else if (estimatedCost < 200000)
            {
                Console.WriteLine("\nProject Classification: Large Industrial Installation");
            }
            else
            {
                Console.WriteLine("\nProject Classification: Major Industrial Complex");
            }
        }

        private void GenerateDesignReport()
        {
            Console.Clear();
            Console.WriteLine("ELECTRICAL DESIGN REPORT");
            Console.WriteLine("========================");

            if (loads.Count == 0)
            {
                Console.WriteLine("No data available. Please add loads first.");
                return;
            }

            Console.WriteLine($"Report Generated: {DateTime.Now:yyyy-MM-dd HH:mm:ss}");
            Console.WriteLine($"Total Number of Loads: {loads.Count}");
            Console.WriteLine($"Total Connected Load: {totalPower:F2} kW");
            Console.WriteLine();

            Console.WriteLine("LOAD DISTRIBUTION ANALYSIS:");
            Console.WriteLine("---------------------------");

            // Analyze load distribution by type using foreach and dictionary
            var loadsByType = new Dictionary<string, (int count, double power)>();

            foreach (var load in loads)
            {
                if (loadsByType.ContainsKey(load.LoadType))
                {
                    loadsByType[load.LoadType] = (
                        loadsByType[load.LoadType].count + 1,
                        loadsByType[load.LoadType].power + load.Power
                    );
                }
                else
                {
                    loadsByType[load.LoadType] = (1, load.Power);
                }
            }

            foreach (var loadType in loadsByType)
            {
                double percentage = (loadType.Value.power / totalPower) * 100;
                Console.WriteLine($"{loadType.Key}: {loadType.Value.count} loads, {loadType.Value.power:F2} kW ({percentage:F1}%)");
            }

            Console.WriteLine();
            Console.WriteLine("RECOMMENDATIONS:");
            Console.WriteLine("---------------");

            // Generate recommendations using multiple if statements
            if (totalPower > 500)
            {
                Console.WriteLine("• Consider implementing load management system for large installation");
            }

            if (loads.Any(l => l.PowerFactor < 0.85))
            {
                Console.WriteLine("• Power factor correction recommended for improved efficiency");
            }

            if (totalCurrent > 400)
            {
                Console.WriteLine("• High current installation - ensure adequate ventilation and safety measures");
            }

            if (estimatedCost > 100000)
            {
                Console.WriteLine("• Major project - consider phased implementation approach");
            }

            Console.WriteLine("• Regular maintenance schedule recommended for optimal performance");
            Console.WriteLine("• Compliance with local electrical codes and standards required");
        }

        // Input validation methods
        private string GetValidStringInput(string prompt)
        {
            string input;
            do
            {
                Console.Write(prompt);
                input = Console.ReadLine()?.Trim();

                if (string.IsNullOrWhiteSpace(input))
                {
                    Console.WriteLine("Input cannot be empty. Please try again.");
                }

            } while (string.IsNullOrWhiteSpace(input));

            return input;
        }

        private int GetValidIntInput(string prompt, int min, int max)
        {
            int value;

            do
            {
                Console.Write(prompt);
                if (!int.TryParse(Console.ReadLine(), out value))
                {
                    Console.WriteLine("Invalid input! Please enter a valid number.");
                    continue;
                }

                if (value < min || value > max)
                {
                    Console.WriteLine($"Value must be between {min} and {max}.");
                    continue;
                }

                break;

            } while (true);

            return value;
        }

        private double GetValidDoubleInput(string prompt, double min, double max)
        {
            double value;

            do
            {
                Console.Write(prompt);
                if (!double.TryParse(Console.ReadLine(), out value))
                {
                    Console.WriteLine("Invalid input! Please enter a valid number.");
                    continue;
                }

                if (value < min || value > max)
                {
                    Console.WriteLine($"Value must be between {min:F1} and {max:F1}.");
                    continue;
                }

                break;

            } while (true);

            return value;
        }

        private double GetValidVoltageInput(string prompt)
        {
            double voltage;
            double[] standardVoltages = { 110, 120, 208, 220, 240, 277, 380, 400, 415, 480, 600, 690, 4160, 11000, 13800 };

            do
            {
                Console.Write(prompt);
                if (!double.TryParse(Console.ReadLine(), out voltage))
                {
                    Console.WriteLine("Invalid input! Please enter a valid voltage.");
                    continue;
                }

                // Check if voltage is a standard value using LINQ and if statement
                if (standardVoltages.Any(v => Math.Abs(v - voltage) < 1))
                {
                    break;
                }
                else
                {
                    Console.WriteLine("Warning: Non-standard voltage entered.");
                    Console.Write("Continue with this voltage? (y/n): ");

                    string confirm = Console.ReadLine()?.ToLower();
                    if (confirm == "y" || confirm == "yes")
                    {
                        break;
                    }
                }

            } while (true);

            return voltage;
        }

        private double GetValidPowerFactorInput(string prompt)
        {
            double powerFactor;

            do
            {
                Console.Write(prompt);
                if (!double.TryParse(Console.ReadLine(), out powerFactor))
                {
                    Console.WriteLine("Invalid input! Please enter a valid power factor.");
                    continue;
                }

                if (powerFactor < 0.1 || powerFactor > 1.0)
                {
                    Console.WriteLine("Power factor must be between 0.1 and 1.0.");
                    continue;
                }

                // Warning for low power factor using if statement
                if (powerFactor < 0.85)
                {
                    Console.WriteLine("Warning: Low power factor detected. Consider power factor correction.");
                }

                break;

            } while (true);

            return powerFactor;
        }

        private string GetValidLoadTypeInput(string prompt)
        {
            string[] validTypes = { "MOTOR", "LIGHTING", "HVAC", "OTHER" };
            string loadType;

            do
            {
                Console.Write(prompt);
                loadType = Console.ReadLine()?.ToUpper().Trim();

                if (string.IsNullOrWhiteSpace(loadType))
                {
                    Console.WriteLine("Load type cannot be empty.");
                    continue;
                }

                // Validate load type using if statement and LINQ
                if (validTypes.Contains(loadType))
                {
                    break;
                }
                else
                {
                    Console.WriteLine($"Valid types are: {string.Join(", ", validTypes)}");
                }

            } while (true);

            return loadType;
        }
    }

    public class ElectricalLoad
    {
        public string Name { get; set; }
        public double Power { get; set; } // kW
        public double Voltage { get; set; } // V
        public double PowerFactor { get; set; }
        public string LoadType { get; set; }

        public ElectricalLoad(string name, double power, double voltage, double powerFactor, string loadType)
        {
            Name = name;
            Power = power;
            Voltage = voltage;
            PowerFactor = powerFactor;
            LoadType = loadType;
        }
    }
}