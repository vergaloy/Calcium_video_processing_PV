function coefficients=fit_two_Gaussians_PV(X,Y,plotme)
if ~exist('plotme','var')
    plotme = 0;
end

% Define the model as Y =  c*exp(-(x-d)^2/e) + d * exp(-(x-f)^2/g)
modelfun = @(b,x) b(1) * exp(-(x(:, 1) - b(2)).^2/b(3)) + b(4) * exp(-(x(:, 1) - b(5)).^2/b(6));  
beta0 = [0.01, 0.2, 0.03, 0.01, 0.8, 0.06]; % Guess values to start with.  Just make your best guess.

coefficients = lsqcurvefit(modelfun,beta0 ,double(X),double(Y),zeros(length(X),1),ones(length(X),1));
%
if plotme
ls = linspace(min(X), max(X), 1920); % Let's use 1920 points, which will fit across an HDTV screen about one sample per pixel.
yFitted = coefficients(1) * exp(-(ls - coefficients(2)).^2 / coefficients(3));
% Now we're done and we can plot the smooth model as a red line going through the noisy blue markers.
plot(X,Y);
hold on;
plot(ls, yFitted, 'r-', 'LineWidth', 2);
grid on;
title('Exponential Regression with fitnlm()', 'FontSize', 12);
xlabel('X', 'FontSize', 8);
ylabel('Y', 'FontSize', 8);
legendHandle = legend('Noisy Y', 'Fitted Y', 'Location', 'northeast');
legendHandle.FontSize = 8;
end




