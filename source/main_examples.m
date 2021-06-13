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
