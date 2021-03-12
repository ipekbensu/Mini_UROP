function [Weibull] = estimate_Weibull(peak_gusts)

% define T
% units: yr

T = [10, 20, 50, 100, 200, 500, 1000];

% initialize Weibull
% columns (2): a, b (parameters)
% units: parameters

Weibull = zeros(size(peak_gusts,1),2);

% estimate Weibull (fit peak_gusts)

xT = -log(1./T);

for i=1:size(peak_gusts,1)
    
    m_b = polyfit(log(xT),log(peak_gusts(i,:)),1);
    
    Weibull(i,:) = [...
        exp(m_b(2)),...
        1/m_b(1)...
        ];
    
end
clear i

end
