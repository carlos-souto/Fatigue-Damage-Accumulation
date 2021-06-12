% reset workspace
clear all; close all; clc;

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
