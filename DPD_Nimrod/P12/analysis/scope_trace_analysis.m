function [ ] = scope_trace_analysis( DATA, time )

plot(time/1e-12, DATA)
xlabel(' time (pSec)');
ylabel('(V)');
grid on

end

