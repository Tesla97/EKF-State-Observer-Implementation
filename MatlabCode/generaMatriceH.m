function [H] = generaMatriceH(x,k,L)
H = [L*cos(x(1,k)),0];
end