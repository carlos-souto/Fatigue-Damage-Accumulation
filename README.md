# Fatigue-Damage-Accumulation
### By Carlos Daniel Santos Souto (csouto@fe.up.pt)

Fatigue damage accumulation for variable amplitude stress-time histories using the Palmgren-Miner rule coded in Matlab. Code is documented and easy to use.
The design fatigue strength curve (S-N or stress-life curve) is specified using the standardized parameters from Eurocode 3 EN 1993-1-9. The cycle counts are done using a rainflow counting algorithm based on ASTM E1049-85.

### Usage Examples

```
% reset workspace
clear all; close all; clc;

% generate a random stress-time history
% (250 random numbers between 100 and 600)
history = 100 + (600 - 100)*rand(250, 1);

% basic example (uses default values)
% the first input is the stress-time history
% the second input is the detail category (see EN 1993-1-9)
damage = fatdamage(history, 160)

% specify the number of times the stress-time history sample is repeated
damage = fatdamage(history, 160, 'Repetitions', 7500)

% specify a custom direct stress S-N curve
damage = fatdamage(history, 160, 'FirstSlope', 4, 'SecondSlope', 8)

% specify a custom shear stress S-N curve
damage = fatdamage(history, 112, 'StressType', 'shear', 'ShearSlope', 6)

% specify safety factors
damage = fatdamage(history, 160, 'ConstantAmplitudeFactor', 1.25, 'FatigueStrengthFactor', 1.35)

% specify number of bins in the rainflow histogram and number of colors in the colormap
damage = fatdamage(history, 160, 'Bins', [10, 20], 'Colors', 8)

% if no plot is required
damage = fatdamage(history, 160, 'Plot', false)
```

### Example Output

#### After execution, the following plots are shown, summarizing the fatigue analysis

A plot of the provided stress-time history:

![a](https://user-images.githubusercontent.com/83190503/121819217-c43c4b80-cc83-11eb-8f49-37bc0bad5bc9.png)

A plot of the load reversals (local extrema, i.e., peaks and valleys):

![b](https://user-images.githubusercontent.com/83190503/121819220-c7cfd280-cc83-11eb-8b72-b8d52ea91299.png)

The 2D rainflow histogram, where one can see the cycle counts joined in "buckets" of similar stress ranges and mean stresses:

![c](https://user-images.githubusercontent.com/83190503/121819221-ca322c80-cc83-11eb-8341-1d57c09f4420.png)

The generated fatigue strength curve:

![d](https://user-images.githubusercontent.com/83190503/121819226-cd2d1d00-cc83-11eb-870d-6db01bcce8d8.png)

The linearly accumulated fatigue damage, failure is expected to occur if damage equals (or is greater than) 1. If damage is less than 1, the bar is shown in green, otherwise it is shown in red:

![e](https://user-images.githubusercontent.com/83190503/121819227-cf8f7700-cc83-11eb-871f-f45cd80a5af4.png)

### The Rainflow Counting Algorithm

The rainflow counting algorithm was implemented based on ASTM E1049-85 and its implementation was tested and validated by comparing its results with the ones obtained from Matlab’s ``rainflow`` function (from Signal Processing Toolbox). This implementation shows the same results while surpassing the efficiency of the Matlab’s solution.

![b](https://user-images.githubusercontent.com/83190503/121784425-d2b73400-cbab-11eb-837f-22d1439ece6c.png)
