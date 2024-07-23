function y = memory_PA_model(x, memorylen, degree, coef)

x_terms = zeros(1,degree*memorylen);

for deg = 1:degree
        
        x_terms(1,(deg-1)*memorylen+(1:memorylen)) = (x.*(abs(x).^(deg-1))).';
        
    end
    
    y = x_terms*coef;