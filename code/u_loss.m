function utility = u_loss(x,type,par,norm,x_min,x_max)

if nargin<=3
    norm = 0;
end    

if ischar(type)
    switch(type)
        case 'crra'
            type_num = 1;
        case 'cara'
            type_num = 2;
%         case 'quadratic'
%             type_num = 3;
        otherwise
            error('Specify utility function (crra, cara, or quadratic)');
    end
else
    error('Specify utility function (crra, cara, or quadratic)');
end

if type_num == 1
    aux = (-1).*(((1-x).^(1-par))./(1-par) - 1./(1-par));
%    aux = (-1).*((-x).^(1-par))./(1-par);
    if norm == 1
        aux_min = (-1).*((-x_min).^(1-par))./(1-par);
        aux_max = (-1).*((-x_max).^(1-par))./(1-par);
        utility = (aux-aux_min)./(aux_max-aux_min);
    else
        utility = aux;
    end
    if par == 1
        aux = (-1).*(log(1-x));
        if norm == 1
            aux_min = (-1).*(log(-x_min));
            aux_max = (-1).*(log(-x_max));
            utility = (aux-aux_min)./(aux_max-aux_min);
        else
            utility = aux;
        end
    end 
elseif type_num == 2
    aux = (exp(par.*x)-1)./par;
    if norm == 1
        aux_min = (exp(par.*x_min)-1)./par;
        aux_max = (exp(par.*x_max)-1)./par;
        utility = (aux-aux_min)./(aux_max-aux_min);
    else
        utility = aux;
    end
    if par == 0
        aux = x;
        if norm == 1
            aux_min = x_min;
            aux_max = x_max;
            utility = (aux-aux_min)./(aux_max-aux_min);
        else
            utility = aux;
        end
    end
elseif type_num == 3
    aux = x-par.*x.^2;
    if norm == 1
        aux_min = x_min-par.*x_min.^2;
        aux_max = x_max-par.*x_max.^2;
        utility = (aux-aux_min)./(aux_max-aux_min);
    else
        utility = aux;
    end
    if par > (1/2.*max(x))
        error('Quadr. utility function has non-increasing segment');
    end
end