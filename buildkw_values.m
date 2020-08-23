% Slot and poles
Q = 1:60;
p = 1:50;

for Qi = 1:length(Q)
    for pi = 1:length(p)
        fprintf('Q = %d, p = %d\n', Q(Qi), p(pi) );
        kw_matrix_simples(Qi, pi) = calckw(Q(Qi), p(pi), 1, 1);
        kw_matrix_dupla(Qi, pi) = calckw(Q(Qi), p(pi), 2, 1);
    end
end

