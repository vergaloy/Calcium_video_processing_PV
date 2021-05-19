function test()
fontSize=12;
[D, S] = xlsread('Book1GA.xls');
Tcl = regexp(S, '(\d\.\d+)', 'match');                              % Time Values (Cell Array)
Tch = cell2mat([Tcl{:}]');                                          % Time Values (Character Array)
Tv = str2num(Tch);   % Thanks to Star for figuring out how to get the time!
plot(Tv, D, 'b-')
grid on;
erodedSignal = imerode(D, ones(51, 1));
hold on;
plot(Tv, erodedSignal, 'r-', 'LineWidth', 2);
X = Tv;
Y = erodedSignal;
% Convert X and Y into a table, which is the form fitnlm() likes the input data to be in.
tbl = table(X, Y);
% Define the model as Y = a + exp(-b*x)
% Note how this "x" of modelfun is related to big X and big Y.
% x((:, 1) is actually X and x(:, 2) is actually Y - the first and second columns of the table.
modelfun = @(b,x) b(1) + b(2) * exp(-b(3)*x(:, 1));  
beta0 = [10000, 300, 1]; % Guess values to start with.  Just make your best guess.
% Now the next line is where the actual model computation is done.
mdl = fitnlm(tbl, modelfun, beta0);
% Now the model creation is done and the coefficients have been determined.
% YAY!!!!
% Extract the coefficient values from the the model object.
% The actual coefficients are in the "Estimate" column of the "Coefficients" table that's part of the mode.
coefficients = mdl.Coefficients{:, 'Estimate'}
% Create smoothed/regressed data using the model:
yFitted = coefficients(1) + coefficients(2) * exp(-coefficients(3)*X);
% Now we're done and we can plot the smooth model as a red line going through the noisy blue markers.
hold on;
plot(X, yFitted, 'k-', 'LineWidth', 3);
grid on;
title('Exponential Regression with fitnlm()', 'FontSize', fontSize);
xlabel('X', 'FontSize', fontSize);
ylabel('Y', 'FontSize', fontSize);
legendHandle = legend('Original Signal', 'Baseline', 'Fitted Y', 'Location', 'north');
legendHandle.FontSize = 25;
% Set up figure properties:
% Enlarge figure to full screen.
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
% Get rid of tool bar and pulldown menus that are along top of figure.
% set(gcf, 'Toolbar', 'none', 'Menu', 'none');
% Give a name to the title bar.
set(gcf, 'Name', 'Demo by ImageAnalyst', 'NumberTitle', 'Off')
end