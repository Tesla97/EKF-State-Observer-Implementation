function [xp] = f(x,k,L,Ts,m,g,b,u)
a  = x(1,k)+Ts*x(2,k);
b  = x(2,k)-((g*Ts)/L)*sin(x(1,k))-((b*Ts)/(m*L))*x(2,k)+(Ts/(m*L*L))*u;
xp = [a;b]; 
end