# Fatigue-Damage-Accumulation
### By Carlos Daniel Santos Souto (csouto@fe.up.pt)

Fatigue damage accumulation for variable amplitude stress-time histories using the Palmgren-Miner rule coded in Matlab. Code is well documented and easy to use.
The design fatigue strength curve (S-N or stress-life curve) is specified using the standardized parameters from Eurocode 3 EN 1993-1-9. The cycle counts are done using a rainflow counting algorithm based on ASTM E1049-85.

### Usage Examples

```
% generate a random stress-time history
history = rand(250, 1)*500;

% basic example (uses default values)
% the first input is the stress-time history
% the second input is the detail category (see EN 1993-1-9)
damage = fatdamage(history, 160)

% specify the number of times the stress-time history sample is repeated
damage = fatdamage(history, 160, 'Repetitions', 75)

% specify a custom direct stress S-N curve
damage = fatdamage(history, 160, 'FirstSlope', 4, 'SecondSlope', 8)

% specify a custom shear stress S-N curve
damage = fatdamage(history, 112, 'StressType', 'shear', 'ShearSlope', 6)

% specify safety factors
damage = fatdamage(history, 160, 'ConstantAmplitudeFactor', 1.25, 'FatigueStrengthFactor', 1.35)

% specify number of bins in the rainflow histogram and number of colors in the colormap
damage = fatdamage(history, 160, 'NumberOfBins', [10, 20], 'NumberOfColors', 8)
```

### Example Output

A plot of the provided stress-time history:
![image](https://user-images.githubusercontent.com/83190503/121784062-a69ab380-cba9-11eb-9f47-01c8bfc22f53.png)

A plot of the load reversals (local extrema, i.e., peaks and valleys):
![image](https://user-images.githubusercontent.com/83190503/121784092-d8137f00-cba9-11eb-9318-8cd927080415.png)

The 2D rainflow histogram, where one can see the cycle counts joined in "buckets" of similar stress ranges and mean stresses:
![image](https://user-images.githubusercontent.com/83190503/121784129-0f822b80-cbaa-11eb-92a6-fb93ecb16afd.png)

The generated fatigue strength curve:
![image](https://user-images.githubusercontent.com/83190503/121784181-70116880-cbaa-11eb-861b-0b9eefd7dc68.png)

The linearly accumulated fatigue damage, failure is expected to occur if damage equals (or is greater than) 1. If damage is less than 1, the bar is shown in green, otherwise it is shown in red:
![image](https://user-images.githubusercontent.com/83190503/121784204-93d4ae80-cbaa-11eb-8ad1-1e7f019b1473.png)
