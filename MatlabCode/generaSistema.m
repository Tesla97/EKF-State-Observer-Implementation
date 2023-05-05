function [xp] = generaSistema(t,x,L,m,g,b,u)
xp = [x(2);(-g/L)*sin(x(1))-(b/(m*L))*x(2)+(1/(m*L*L))*u];
end