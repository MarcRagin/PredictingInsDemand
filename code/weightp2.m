function pi = weightp2(p,omega,phi)
    pi = 1./(exp(phi.*((-1.*log(p)).^omega)));
end
