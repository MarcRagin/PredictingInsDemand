clear
%% Data Prep
tic
data = xlsread('../data/MainAll_long.xlsx');
save('mainAll.mat');
load('mainAll.mat');

rng('default');

Subject_ID = data(:,1);
No_Ins_Decisions = length(data)./length(unique((Subject_ID)));

newdata = zeros(length(unique((Subject_ID))),length(data(1,:)));
for i = 1:length(newdata)
    newdata(i,:) = data(1 + (i-1).*No_Ins_Decisions,:);
end

data = newdata;
Subject_ID = data(:,1);

% Insurance Choices
CoinsDemand = data(:,2);
p = data(:,3);
lambda = data(:,4);
FOSD_data = data(:,5);
FOSD = zeros(length(data),1);

% Preferences Choices
GD1 = data(:,6);
GD2 = data(:,7);
LD1 = data(:,8);
LD2 = data(:,9);
LA = data(:,10);
CE = data(:,11);

%% Nonparametric preferences
% MR: These are already in columns F-J
UC_g_np = GD1 + GD2;
UC_l_np = LD1 + LD2;
PW_g_np = GD2 - GD1;
PW_l_np = LD1 - LD2;
LA_np = LA;
CE_np = CE - GD1;

%% Parametric Analysis
%% Major Assumptions
type = 'crra';
w = 0;
phi = 1;

%% Technical preliminaries
I = .01:.01:2;
r = 2:-.001:-2;
norm = 0; % if this is set to 1, the entire code stops working

%% Build the preference parameters from scratch
%% Gain Domain
% Series 1
GD1_x11 = 2.5;
GD1_x12 = 2;
GD1_x22 = 1;
GD1_p1 = 0.2;
GD1_p2 = 0.2;
GD1_X21 = [4.5; 4.75; 5; 5.5; 6; 6.5; 7; 8; 9; 10; 12; 15; 20; 30; 60];
GD1_Rs = zeros(length(I),length(GD1_X21)+1);
diff_GD1 = zeros(length(GD1_X21),length(r));
for j=1:length(GD1_X21)+1
    if j == 1
        GD1_x21 = GD1_X21(1) - (GD1_X21(2)-GD1_X21(1))/2;
    elseif j == length(GD1_X21)+1
        GD1_x21 = GD1_X21(length(GD1_X21)) + (GD1_X21(length(GD1_X21))-GD1_X21(length(GD1_X21)-1))/2;
    else
        GD1_x21= (GD1_X21(j)+GD1_X21(j-1))/2;
    end %if
    for i = 1:length(I)
        omega = I(i);
        diff_GD1(j,:) = u(w+GD1_x11,type,r,norm,GD1_x22,GD1_x21) .* weightp2(GD1_p1,omega,phi) + u(w+GD1_x12,type,r,norm,GD1_x22,GD1_x21) ...
            .* (1-weightp2(GD1_p1,omega,phi)) - u(w+GD1_x21,type,r,norm,GD1_x22,GD1_x21) .* weightp2(GD1_p2,omega,phi)...
            - u(w+GD1_x22,type,r,norm,GD1_x22,GD1_x21) .* (1-weightp2(GD1_p2,omega,phi));
        [~, Ind] = min(abs(diff_GD1(j,:)));
        if sum(diff_GD1(j,:)>0) == (length(diff_GD1(j,:))-sum(isnan(diff_GD1(j,:)))) || sum(diff_GD1(j,:)<0) == (length(diff_GD1(j,:))-sum(isnan(diff_GD1(j,:))))
            GD1_Rs(i,j) = NaN;
        else
            GD1_Rs(i,j) = r(Ind);
        end %if
    end %i
end %j

% Series 2
GD2_x11 = 2;
GD2_x12 = 1.5;
GD2_p1 = 0.9;
GD2_p2 = 0.9;
GD2_x22 = 0.5;
GD2_X21 = [2.05; 2.1; 2.15; 2.2; 2.25; 2.3; 2.35; 2.45; 2.55; 2.65; 2.8; 3.0; 3.25; 3.5;3.75];
GD2_Rs = zeros(length(I),length(GD1_X21)+1);
diff_GD2 = zeros(length(GD2_X21),length(r));
for j=1:length(GD2_X21)+1
    if j == 1
        GD2_x21 = GD2_X21(1) - (GD2_X21(2)-GD2_X21(1))/2;
    elseif j == length(GD2_X21)+1
        GD2_x21 = GD2_X21(length(GD2_X21)) + (GD2_X21(length(GD2_X21))-GD2_X21(length(GD2_X21)-1))/2;
    else
        GD2_x21= (GD2_X21(j)+GD2_X21(j-1))/2;
    end %if
    for i = 1:length(I)
        omega = I(i);
        diff_GD2(j,:) = u(w+GD2_x11,type,r,norm,GD2_x22,GD2_x21) .* weightp2(GD2_p1,omega,phi) + u(w+GD2_x12,type,r,norm,GD2_x22,GD2_x21) ...
            .* (1-weightp2(GD2_p1,omega,phi)) - u(w+GD2_x21,type,r,norm,GD2_x22,GD2_x21) .* weightp2(GD2_p2,omega,phi)...
            - u(w+GD2_x22,type,r,norm,GD2_x22,GD2_x21) .* (1-weightp2(GD2_p2,omega,phi));
        [~, Ind] = min(abs(diff_GD2(j,:)));
        if sum(diff_GD2(j,:)>0) == (length(diff_GD2(j,:))-sum(isnan(diff_GD2(j,:)))) || sum(diff_GD2(j,:)<0) == (length(diff_GD2(j,:))-sum(isnan(diff_GD2(j,:))))
            GD2_Rs(i,j) = NaN;
        else
            GD2_Rs(i,j) = r(Ind);
        end %if
    end %i
end %j

omega_gain_intersections = zeros(length(GD1_Rs(1,:)),length(GD2_Rs(1,:)));
r_gain_intersections = zeros(length(GD1_Rs(1,:)),length(GD2_Rs(1,:)));
for c1 = 1:length(GD1_Rs(1,:))
    for c2 = 1:length(GD2_Rs(1,:))
        A=abs(GD1_Rs(:,c1)-GD2_Rs(:,c2));
        A(isnan(A))=1;
        [~, ind] = min(A);
        r_gain_intersections(c1,c2) = (GD1_Rs(ind,c1)+GD2_Rs(ind,c2))/2;
        omega_gain_intersections(c1,c2) = I(ind);
    end %c2
end %c1
r_gain_intersections = round(100.*r_gain_intersections)/100;
omega_gain_intersections = round(100.*omega_gain_intersections)/100;

UC_g_p = zeros(length(GD1),1);
PW_g_p = zeros(length(GD1),1);
for i = 1:length(GD1)
    if GD1(i) == 0 || GD2(i) == 0
        FOSD(i) = 1;
        UC_g_p(i) = 99;
        PW_g_p(i) = 99;
    else
        UC_g_p(i) = r_gain_intersections(GD1(i),GD2(i));
        PW_g_p(i) = omega_gain_intersections(GD1(i),GD2(i));
    end %if
end %i

%% Loss Domain
% Change in technical assumptions
r = 1.5:-.001:-2.5;

LD1_p1 = 0.1;
LD1_p2 = 0.1;
LD1_x11 = -0.75;
LD1_x12 = -.5;
LD1_x22 = -.25;
LD1_X21 = [-1.2;-1.25;-1.3;-1.4;-1.5;-1.6;-1.7;-1.85;-2;-2.15;-2.35;-2.65;-3.00;-3.40;-4];

diff_LD1 = zeros(length(LD1_X21),length(r));
LD1_Rs = zeros(length(I),length(GD1_X21)+1);
for j=1:length(LD1_X21)+1
    if j == 1
        LD1_x21 = LD1_X21(1) - (LD1_X21(2)-LD1_X21(1))/2;
    elseif j == length(LD1_X21)+1
        LD1_x21 = LD1_X21(length(LD1_X21)) + (LD1_X21(length(LD1_X21))-LD1_X21(length(LD1_X21)-1))/2;
    else
        LD1_x21= (LD1_X21(j)+LD1_X21(j-1))/2;
    end %if
    for i = 1:length(I)
        omega = I(i);
        diff_LD1(j,:) = u_loss(w+LD1_x11,type,r,norm,LD1_x22,LD1_x21) .* weightp2(LD1_p1,omega,phi) + u_loss(w+LD1_x12,type,r,norm,LD1_x22,LD1_x21) ...
            .* (1-weightp2(LD1_p1,omega,phi)) - u_loss(w+LD1_x21,type,r,norm,LD1_x22,LD1_x21) .* weightp2(LD1_p2,omega,phi)...
            - u_loss(w+LD1_x22,type,r,norm,LD1_x22,LD1_x21) .* (1-weightp2(LD1_p2,omega,phi));
        [~, Ind] = min(abs(diff_LD1(j,:)));
        if sum(diff_LD1(j,:)>0) == (length(diff_LD1(j,:))-sum(isnan(diff_LD1(j,:)))) || sum(diff_LD1(j,:)<0) == (length(diff_LD1(j,:))-sum(isnan(diff_LD1(j,:))))
            LD1_Rs(i,j) = NaN;
        else
            LD1_Rs(i,j) = r(Ind);
        end %if
    end %i
end %j

LD2_p1 = 0.8;
LD2_p2 = 0.8;
LD2_x11 = -1.75;
LD2_x12 = -1.25;
LD2_x22 = -0.1;
LD2_X21 = [-1.95;-2;-2.05;-2.1;-2.15;-2.2;-2.3;-2.4;-2.5;-2.6;-2.75;-2.9;-3.05;-3.25;-3.5];

diff_LD2 = zeros(length(LD2_X21),length(r));
LD2_Rs = zeros(length(I),length(GD1_X21)+1);
for j=1:length(LD2_X21)+1
    if j == 1
        LD2_x21 = LD2_X21(1) - (LD2_X21(2)-LD2_X21(1))/2;
    elseif j == length(LD2_X21)+1
        LD2_x21 = LD2_X21(length(LD2_X21)) + (LD2_X21(length(LD2_X21))-LD2_X21(length(LD2_X21)-1))/2;
    else
        LD2_x21= (LD2_X21(j)+LD2_X21(j-1))/2;
    end %if
    for i = 1:length(I)
        omega = I(i);
        diff_LD2(j,:) = u_loss(w+LD2_x11,type,r,norm,LD2_x22,LD2_x21) .* weightp2(LD2_p1,omega,phi) + u_loss(w+LD2_x12,type,r,norm,LD2_x22,LD2_x21) ...
            .* (1-weightp2(LD2_p1,omega,phi)) - u_loss(w+LD2_x21,type,r,norm,LD2_x22,LD2_x21) .* weightp2(LD2_p2,omega,phi)...
            - u_loss(w+LD2_x22,type,r,norm,LD2_x22,LD2_x21) .* (1-weightp2(LD2_p2,omega,phi));
        [~, Ind] = min(abs(diff_LD2(j,:)));
        if sum(diff_LD2(j,:)>0) == (length(diff_LD2(j,:))-sum(isnan(diff_LD2(j,:)))) || sum(diff_LD2(j,:)<0) == (length(diff_LD2(j,:))-sum(isnan(diff_LD2(j,:))))
            LD2_Rs(i,j) = NaN;
        else
            LD2_Rs(i,j) = r(Ind);
        end %if
    end %i
end %j

r_loss_intersections = zeros(length(LD1_Rs(1,:)),length(LD2_Rs(1,:)));
omega_loss_intersections = zeros(length(LD1_Rs(1,:)),length(LD2_Rs(1,:)));
for c1 = 1:length(LD1_Rs(1,:))
    for c2 = 1:length(LD2_Rs(1,:))
        A=abs(LD1_Rs(:,c1)-LD2_Rs(:,c2));
        A(isnan(A))=1;
        [~, ind] = min(A);
        r_loss_intersections(c1,c2) = (LD1_Rs(ind,c1)+LD2_Rs(ind,c2))/2;
        omega_loss_intersections(c1,c2) = I(ind);
    end %c2
end %c1
r_loss_intersections = round(100.*r_loss_intersections)/100;
omega_loss_intersections = round(100.*omega_loss_intersections)/100;

UC_l_p = zeros(length(GD1),1);
PW_l_p = zeros(length(GD1),1);
for i = 1:length(GD1)
    if LD1(i) == 16 || LD2(i) == 16 || FOSD(i) == 1
        FOSD(i) = 1;
        UC_l_p(i) = 99;
        PW_l_p(i) = 99;
    else
        UC_l_p(i) = r_loss_intersections(16-LD1(i),16-LD2(i));
        PW_l_p(i) = omega_loss_intersections(16-LD1(i),16-LD2(i));
    end %if
end %i

%% Loss Aversion
LA_p = zeros(length(GD1),1);
LA_indp = zeros(length(GD1),1);
LA_index1 = zeros(length(GD1),1);
LA_index2 = zeros(length(GD1),1);
LA_index3 = zeros(length(GD1),1);

LA_xSh = 0.5;
LA_xSl = -0.2;
LA_xRh = 5;
LA_xRl = -2;
for i = 1:length(GD1)
    if LA(i) == 0 || LA(i) == 21 || FOSD(i) == 1
        FOSD(i) = 1;
        LA_p(i) = 99;
    else
        LA_indp(i) = (LA(i)-1).*.05 + .025;
        LA_p(i) = (weightp2(LA_indp(i),PW_g_p(i),phi).*(u(LA_xRh,type,UC_g_p(i),norm)-u(LA_xSh,type,UC_g_p(i),norm)))...
            ./(weightp2(1-LA_indp(i),PW_l_p(i),phi).*(u_loss(LA_xSl,type,UC_l_p(i),norm)-u_loss(LA_xRl,type,UC_l_p(i),norm)));
        %LA_index_p(i) = -1.*LA_p(i).*u_loss(-1,type,UC_l_p(i),norm)./u(1,type,UC_g_p(i),norm);
        vec = 0.01:0.01:5;
        aux = -1.*LA_p(i).*u_loss(-1.*vec,type,UC_l_p(i),norm)./u(vec,type,UC_g_p(i),norm);
        LA_index1(i) = mean(aux);
        aux = (LA_p(i).*(vec+1).^(-1.*UC_l_p(i)))./((vec+1).^(-1.*UC_g_p(i)));
        LA_index2(i) = mean(aux);
        LA_index3(i) = (LA_indp(i).*(LA_xRh-LA_xSh))./((1-LA_indp(i)).*(LA_xSl-LA_xRl));
    end %if
end %i

%% Certainty Effect
% We assume functional form v(x) = k^{1-r}u(x) or v(x) = \frac{k^{1-r}*x^{1-r}}{1-r}
% Then we calculate the MCP by Schmidt (1998) as MCP =
% \frac{v(x)-u(x)}{u'(x)} = \frac{k^{1-r}-1}{1-r}x and drop the
% multiplicative wealth factor as that is assumed equal for all subjects
% the remaining measure \frac{k^{1-r}-1}{1-r} is taken as our parametric
% measure of the certainty effect. We need the k factor for applying the
% certainty effect to other models
x_sure = 2;
CE_X21 = [2.5; GD1_X21];
CE_x22 = 1;
CE_p = zeros(length(CE),1); % this is the MCP
k = zeros(length(CE),1);
for i = 1:length(CE)
    if CE(i) == 0
        CE_x21 = 2.25;
    elseif CE(i) == 16
        CE_x21 = 75;
    else
        CE_x21 = CE_X21(CE(i)) + (CE_X21(CE(i)+1)-CE_X21(CE(i)))./2;
    end %if
    if FOSD(i) == 1
        CE_p(i) = 99;
    else
        vx = weightp2(GD1_p1,PW_g_p(i),phi).*u(CE_x21,type,UC_g_p(i),norm) + ...
            (1-weightp2(GD1_p1,PW_g_p(i),phi)).*u(CE_x22,type,UC_g_p(i),norm);
        aux = vx./u(x_sure,type,UC_g_p(i),norm);
        if UC_g_p(i) == 1
            k(i) = exp(vx-u(x_sure,type,UC_g_p(i),norm));
            CE_p(i) = log(k(i));
        else
            k(i) = aux.^(1/(1-UC_g_p(i)));
            CE_p(i) = (aux-1)./(1-UC_g_p(i));
        end
        clear vx aux CE_x21
    end %if
end %i

%% Data output
% this is an auxiliary vector storing a bunch of things for the predictions
% algorithm.
for_predictions = [Subject_ID, GD1, GD2, LD1, LD2, LA, CE, k];
params = table(Subject_ID, UC_g_p, UC_l_p, PW_g_p, PW_l_p, LA_p, CE_p, FOSD, FOSD_data, LA_index1, LA_index2, LA_index3);
%params_names = ['Subject_ID', 'UC_g_p', 'UC_l_p', 'PW_g_p', 'PW_l_p', 'LA_p', 'CE_p', 'FOSD', 'FOSD_data'];
nonparams = table(Subject_ID, UC_g_np, UC_l_np, PW_g_np, PW_l_np, LA_np, CE_np, FOSD, FOSD_data);

% For debugging purposes
%xlswrite('Params_final.xls', params);
%xlswrite('NonParams_final.xls', nonparams);

csvwrite('../data/for_predictions.csv', for_predictions)
writetable(params, '../data/Params.xls')
writetable(nonparams, '../data/NonParams.xls');
toc