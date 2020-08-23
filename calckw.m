function [kw, alfa_u] = calckw( Q, p, layer, h )
%Thales A. C. Maia
% Known bugs
% Q = 3 p = 2
kw = NaN;
m = 3; % Trifásica
q = Q / (2*m*p);
alfa_u = pi*2*p/Q; % pg 59

if (layer > 2 || layer < 1)
    disp('A máquina só pode ser camada simples ou dupla.');
end

% Fractional slot
if (q ~= round(q))
    disp('Ranhura fracionada');
    
    % Angulo entre os fasores de tensão
    % Para a máquina simétrica e equilibrada, será sempre igual a 60
    alfa_u = alfa_u * q /2;
    

    if ( mod(Q,3) ~= 0 )
        % Valor de slots inválido
        disp('Número de slots deve ser múltiplo de 3.');
        return;
    end

    if ( 2*p == Q )
        % Valor de slots inválido
        disp('Número de slots e polos deve ser diferente.');
        disp('Torque pulsante muito elevado.');
        return;
    end

    if (q < .25)
        disp('Topologia não factivel.');
        return;
    end

    if (q >= .5)
        disp('Considere trocar seu projeto por bobinas distribuidas.');
        return;
    end

    bal = Q / (3 * gcd(Q, p) );
    if ( bal ~= round(bal) )
        disp('Bobinamento desbalanceado.');
    end

    fprintf('Frequencia do torque pulsante %d.\n', lcm(Q, 2*p));


    if (layer ==  2)
        z = Q / gcd (Q, 2*p*m);
    else
        z = Q/2 / gcd (Q, 2*p*m);
    end
    
    if z < 1
        disp('Topologia funciona apenas em dupla-camada.')
        return;
    end
    % Fator de distribuição
    kd = sin(h * pi/3 / 2) ./ (z * sin(h*pi/3 / 2 / z) );

    % Fator de passo
    kp = sin(1/2 * h * (2*p)/Q * pi );
    

    kw = kd .* kp;
    fprintf('Método artigo - kw(%d) %.5f\n', h, kw);
    q = q*p;
else
    
    disp('Ranhura inteira');
    kd = sin(h* q * alfa_u/2) ./ (q * sin(h* alfa_u/2) );
    kw = kd; 
    %fprintf('Método livro - kw(%d) %.5f\n', h, kw);
    
    layer = 1;
end

%% Metodo dos fasores

q = q+layer-1;

fasor = 0;
for i = 1:q
    if (i == 1 || i == q)
        fasor = fasor + exp(1j*alfa_u*(i-1)*h);
    else
        fasor = fasor + exp(1j*alfa_u*(i-1)*h)*layer;
    end
end

kw_f = abs(fasor / (q+layer-1) ) ;

fprintf('Método dos fasores - kw(%d) %.5f\n', h, kw_f);

%% Metodo dos cossenos
cos_sum = 0;

% Calcula os angulos pela linha de simetria
qi = (0:q-1)-(q-1)/2;
for i = qi
    if (i == qi(1)|| i == qi(end))
        cos_sum = cos_sum + cos(i*h*alfa_u);
    else
        cos_sum = cos_sum + cos(i*h*alfa_u)*layer;
    end
end
kw_c = cos_sum /(q+layer-1);

fprintf('Método dos cossenos - kw(%d) %.5f\n', h, kw_c);

%% Verifica insanidade

if ( abs( round(kw, 5) ) ~= abs( round(kw_f,5) ) )
    disp('Valor que kw_f não bate.');
    kw = -1;
elseif ( abs( round(kw, 5) ) ~= abs( round(kw_c, 5)) )
    disp('Valor de kw_c não bate.');
    kw = -1;
end