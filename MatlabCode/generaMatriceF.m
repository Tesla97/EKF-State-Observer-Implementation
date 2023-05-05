function [F] = generaMatriceF(x,k,L,Ts,m,g,b)
a = ((g*Ts)/L)*cos(x(1,k));
b = 1-((b*Ts)/(m*L));
F = [1,Ts;-a,b];
end