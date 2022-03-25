%% The following code makes predictions for all 16 models. It drops all
%  FOSD violating individuals. It is dependent on running getparams.m and
%  importing its output. It produces alphastar.csv which includes all model
%  predictions.

clear

%% Preliminaries
tic
% import input variables
data_p = xlsread('../data/Params.xls','Sheet1','A2:I1731');
other_data = csvread('../data/for_predictions.csv');
% data is th concatenated version such that the columns are subject_id,
% GD1, GD2, LD1, LD2, LA, CE, uc_g_p, uc_l_p, pw_g_p, pw_l_p, la_p, ce_p,
% k, fosd_violations
data = [other_data(:,1:7), data_p(:,2:7), other_data(:,8), data_p(:,8)];
% drop all FOSD violating individuals
data = data(data(:,15)==0,:);
% convert all data to matlab variables
Subject_ID = data(:,1);
GD1 = data(:,2);
GD2 = data(:,3);
LD1 = data(:,4);
LD2 = data(:,5);
LA = data(:,6);
CE = data(:,7);
UC_g_p = data(:,8);
UC_l_p = data(:,9);
PW_g_p = data(:,10);
PW_l_p = data(:,11);
LA_p = data(:,12);
CE_p = data(:,13);
k = data(:,14);
% Assumptions on functional forms
type = 'crra';
phi = 1;
norm = 0;

%% Build parameters for reduced models
% For this, we need the choice tables
GD1_x11 = 2.5;
GD1_x12 = 2;
GD1_x22 = 1;
GD1_p1 = 0.2;
GD1_p2 = 0.2;
GD1_X21 = [4.5; 4.75; 5; 5.5; 6; 6.5; 7; 8; 9; 10; 12; 15; 20; 30; 60];
GD2_x11 = 2;
GD2_x12 = 1.5;
GD2_p1 = 0.9;
GD2_p2 = 0.9;
GD2_x22 = 0.5;
GD2_X21 = [2.05; 2.1; 2.15; 2.2; 2.25; 2.3; 2.35; 2.45; 2.55; 2.65; 2.8; 3.0; 3.25; 3.5;3.75];
LD1_p1 = 0.1;
LD1_p2 = 0.1;
LD1_x11 = -0.75;
LD1_x12 = -.5;
LD1_x22 = -.25;
LD1_X21 = [-1.2;-1.25;-1.3;-1.4;-1.5;-1.6;-1.7;-1.85;-2;-2.15;-2.35;-2.65;-3.00;-3.40;-4];
LD2_p1 = 0.8;
LD2_p2 = 0.8;
LD2_x11 = -1.75;
LD2_x12 = -1.25;
LD2_x22 = -0.1;
LD2_X21 = [-1.95;-2;-2.05;-2.1;-2.15;-2.2;-2.3;-2.4;-2.5;-2.6;-2.75;-2.9;-3.05;-3.25;-3.5];
LA_xSh = 0.5;
LA_xSl = -0.2;
LA_xRh = 5;
LA_xRl = -2;
x_sure = 2;
CE_X21 = [2.5; GD1_X21];
CE_x22 = 1;

%% EUT
r = 1.5:-.001:-1.5;
w = 5;

% Gain Domain
Choice1 = zeros(length(GD1_X21)+1,1);
for j=1:length(GD1_X21)+1
    if j == 1
        GD1_x21 = GD1_X21(1) - (GD1_X21(2)-GD1_X21(1))/2;
    elseif j == length(GD1_X21)+1
        GD1_x21 = GD1_X21(length(GD1_X21)) + (GD1_X21(length(GD1_X21))-GD1_X21(length(GD1_X21)-1))/2;
    else
        GD1_x21= (GD1_X21(j)+GD1_X21(j-1))/2;
    end %if
    diff_GD1 = u(w+GD1_x11,type,r,norm,GD1_x22,GD1_x21) .* GD1_p1 + ...
        u(w+GD1_x12,type,r,norm,GD1_x22,GD1_x21) .* (1-GD1_p1) -...
        u(w+GD1_x21,type,r,norm,GD1_x22,GD1_x21) .*GD1_p2 - ...
        u(w+GD1_x22,type,r,norm,GD1_x22,GD1_x21) .* (1-GD1_p2);
    [~,MinInd] = min(abs(diff_GD1));
    Choice1(j) = r(MinInd);
end %j

Choice2 = zeros(length(GD2_X21)+1,1);
for j=1:length(GD2_X21)+1
    if j == 1
        GD2_x21 = GD2_X21(1) - (GD2_X21(2)-GD2_X21(1))/2;
    elseif j == length(GD2_X21)+1
        GD2_x21 = GD2_X21(length(GD2_X21)) + (GD2_X21(length(GD2_X21))-GD2_X21(length(GD2_X21)-1))/2;
    else
        GD2_x21= (GD2_X21(j)+GD2_X21(j-1))/2;
    end %if
    diff_GD2 = u(w+GD2_x11,type,r,norm,GD2_x22,GD2_x21) .* GD2_p1 + ...
        u(w+GD2_x12,type,r,norm,GD2_x22,GD2_x21) .* (1-GD2_p1) -...
        u(w+GD2_x21,type,r,norm,GD2_x22,GD2_x21) .* GD2_p2 - ...
        u(w+GD2_x22,type,r,norm,GD2_x22,GD2_x21) .* (1-GD2_p2);
    [~,MinInd] = min(abs(diff_GD2));
    Choice2(j) = r(MinInd);
end %j

EUT_UC_g =zeros(length(GD1),1);
for i = 1:length(GD1)
    EUT_UC_g(i) = (Choice1(GD1(i)) + Choice2(GD2(i)))./2;
end %i

% Loss Domain
w = 5;
Choice1 = zeros(length(LD1_X21)+1,1);
for j=1:length(LD1_X21)+1
    if j == 1
        LD1_x21 = LD1_X21(1) - (LD1_X21(2)-LD1_X21(1))/2;
    elseif j == length(LD1_X21)+1
        LD1_x21 = LD1_X21(length(LD1_X21)) + (LD1_X21(length(LD1_X21))-LD1_X21(length(LD1_X21)-1))/2;
    else
        LD1_x21= (LD1_X21(j)+LD1_X21(j-1))/2;
    end %if
    diff_LD1 = u(w+LD1_x11,type,r,norm) .* LD1_p1 + ...
        u(w+LD1_x12,type,r,norm) .* (1-LD1_p1) -...
        u(w+LD1_x21,type,r,norm) .* LD1_p2 - ...
        u(w+LD1_x22,type,r,norm) .* (1-LD1_p2);
    [~,MinInd] = min(abs(diff_LD1));
    Choice1(j) = r(MinInd);
end %j

Choice2 = zeros(length(GD2_X21)+1,1);
for j=1:length(LD2_X21)+1
    if j == 1
        LD2_x21 = LD2_X21(1) - (LD2_X21(2)-LD2_X21(1))/2;
    elseif j == length(LD2_X21)+1
        LD2_x21 = LD2_X21(length(LD2_X21)) + (LD2_X21(length(LD2_X21))-LD2_X21(length(LD2_X21)-1))/2;
    else
        LD2_x21= (LD2_X21(j)+LD2_X21(j-1))/2;
    end %if
    diff_LD2 = u(w+LD2_x11,type,r,norm) .* LD2_p1 + ...
        u(w+LD2_x12,type,r,norm) .* (1-LD2_p1) -...
        u(w+LD2_x21,type,r,norm) .* LD2_p2 - ...
        u(w+LD2_x22,type,r,norm) .* (1-LD2_p2);
    [~,MinInd] = min(abs(diff_LD2));
    Choice2(j) = r(MinInd);
end %j

EUT_UC_l =zeros(length(LD1),1);
for i = 1:length(LD1)
    EUT_UC_l(i) = (Choice1(16-LD1(i)) + Choice2(16-LD2(i)))./2;
end %i

% Certainty Effect

EUT_k = zeros(length(CE),1);
for i = 1:length(CE)
    if CE(i) == 0
        CE_x21 = 2.25;
    elseif CE(i) == 16
        CE_x21 = 75;
    else
        CE_x21 = CE_X21(CE(i)) + (CE_X21(CE(i)+1)-CE_X21(CE(i)))./2;
    end %if
    vx = GD1_p1.*u(CE_x21,type,EUT_UC_g(i),norm) + ...
        (1-GD1_p1).*u(CE_x22,type,EUT_UC_g(i),norm);
    if EUT_UC_g(i) == 1
        EUT_k(i) = exp(vx-u(x_sure,type,UC_g_p(i),norm));
    else
        aux = vx./u(x_sure,type,EUT_UC_g(i),norm);
        EUT_k(i) = aux.^(1/(1-EUT_UC_g(i)));
    end
    clear vx aux CE_x21
end %i

%% KR

LA_indp = (LA-1).*.05 + .025;
% loss aversion without curvature
KR_LA = zeros(length(LA),1);
for i = 1:length(LA)
    KR_LA(i) = ((2.*LA_indp(i).*(u(LA_xRh,type,0,norm)-u(LA_xSh,type,0,norm)))...
        ./((1-LA_indp(i)).*(u_loss(LA_xSl,type,0,norm)-u_loss(LA_xRl,type,0,norm))))-1;
end %i

%% DT
I = .01:.01:2;

% Gain Domain
Choice1 = zeros(length(GD1_X21)+1,1);
for j=1:length(GD1_X21)+1
    if j == 1
        GD1_x21 = GD1_X21(1) - (GD1_X21(2)-GD1_X21(1))/2;
    elseif j == length(GD1_X21)+1
        GD1_x21 = GD1_X21(length(GD1_X21)) + (GD1_X21(length(GD1_X21))-GD1_X21(length(GD1_X21)-1))/2;
    else
        GD1_x21= (GD1_X21(j)+GD1_X21(j-1))/2;
    end %if
    diff_GD1 = u(w+GD1_x11,type,0,norm,GD1_x22,GD1_x21) .* weightp2(GD1_p1,I,phi) + ...
        u(w+GD1_x12,type,0,norm,GD1_x22,GD1_x21) .* (1-weightp2(GD1_p1,I,phi)) -...
        u(w+GD1_x21,type,0,norm,GD1_x22,GD1_x21) .*weightp2(GD1_p2,I,phi) - ...
        u(w+GD1_x22,type,0,norm,GD1_x22,GD1_x21) .* (1-weightp2(GD1_p2,I,phi));
    [~,MinInd] = min(abs(diff_GD1));
    Choice1(j) = I(MinInd);
end %j

Choice2 = zeros(length(GD2_X21)+1,1);
for j=1:length(GD2_X21)+1
    if j == 1
        GD2_x21 = GD2_X21(1) - (GD2_X21(2)-GD2_X21(1))/2;
    elseif j == length(GD2_X21)+1
        GD2_x21 = GD2_X21(length(GD2_X21)) + (GD2_X21(length(GD2_X21))-GD2_X21(length(GD2_X21)-1))/2;
    else
        GD2_x21= (GD2_X21(j)+GD2_X21(j-1))/2;
    end %if
    diff_GD2 = u(w+GD2_x11,type,0,norm,GD2_x22,GD2_x21) .* weightp2(GD2_p1,I,phi) + ...
        u(w+GD2_x12,type,0,norm,GD2_x22,GD2_x21) .* (1-weightp2(GD2_p1,I,phi)) -...
        u(w+GD2_x21,type,0,norm,GD2_x22,GD2_x21) .* weightp2(GD2_p2,I,phi) - ...
        u(w+GD2_x22,type,0,norm,GD2_x22,GD2_x21) .* (1-weightp2(GD2_p2,I,phi));
    [~,MinInd] = min(abs(diff_GD2));
    Choice2(j) = I(MinInd);
end %j

DT_PW_g =zeros(length(GD1),1);
for i = 1:length(GD1)
    DT_PW_g(i) = (Choice1(GD1(i)) + Choice2(GD2(i)))./2;
end %i

% Loss Domain

Choice1 = zeros(length(LD1_X21)+1,1);
for j=1:length(LD1_X21)+1
    if j == 1
        LD1_x21 = LD1_X21(1) - (LD1_X21(2)-LD1_X21(1))/2;
    elseif j == length(LD1_X21)+1
        LD1_x21 = LD1_X21(length(LD1_X21)) + (LD1_X21(length(LD1_X21))-LD1_X21(length(LD1_X21)-1))/2;
    else
        LD1_x21= (LD1_X21(j)+LD1_X21(j-1))/2;
    end %if
    diff_LD1 = u(w+LD1_x11,type,0,norm) .* weightp2(LD1_p1,I,phi) + ...
        u(w+LD1_x12,type,0,norm) .* (1-weightp2(LD1_p1,I,phi)) -...
        u(w+LD1_x21,type,0,norm) .* weightp2(LD1_p2,I,phi) - ...
        u(w+LD1_x22,type,0,norm) .* (1-weightp2(LD1_p2,I,phi));
    [~,MinInd] = min(abs(diff_LD1));
    Choice1(j) = I(MinInd);
end %j

Choice2 = zeros(length(GD2_X21)+1,1);
for j=1:length(LD2_X21)+1
    if j == 1
        LD2_x21 = LD2_X21(1) - (LD2_X21(2)-LD2_X21(1))/2;
    elseif j == length(LD2_X21)+1
        LD2_x21 = LD2_X21(length(LD2_X21)) + (LD2_X21(length(LD2_X21))-LD2_X21(length(LD2_X21)-1))/2;
    else
        LD2_x21= (LD2_X21(j)+LD2_X21(j-1))/2;
    end %if
    diff_LD2 = u(w+LD2_x11,type,0,norm) .* weightp2(LD2_p1,I,phi) + ...
        u(w+LD2_x12,type,0,norm) .* (1-weightp2(LD2_p1,I,phi)) -...
        u(w+LD2_x21,type,0,norm) .* weightp2(LD2_p2,I,phi) - ...
        u(w+LD2_x22,type,0,norm) .* (1-weightp2(LD2_p2,I,phi));
    [~,MinInd] = min(abs(diff_LD2));
    Choice2(j) = I(MinInd);
end %j

DT_PW_l =zeros(length(LD1),1);
for i = 1:length(LD1)
    DT_PW_l(i) = (Choice1(16-LD1(i)) + Choice2(16-LD2(i)))./2;
end %i

% Certainty Effect
DT_k = zeros(length(CE),1);
for i = 1:length(CE)
    if CE(i) == 0
        CE_x21 = 2.25;
    elseif CE(i) == 16
        CE_x21 = 75;
    else
        CE_x21 = CE_X21(CE(i)) + (CE_X21(CE(i)+1)-CE_X21(CE(i)))./2;
    end %if
    vx = weightp2(GD1_p1,DT_PW_g(i),phi).*u(CE_x21,type,0,norm) + ...
        (1-weightp2(GD1_p1,DT_PW_g(i),phi)).*u(CE_x22,type,0,norm);
    DT_k(i) = vx./u(x_sure,type,0,norm);
    clear vx aux CE_x21
end %i

%% EV

EV_k = zeros(length(CE),1);
for i = 1:length(CE)
    if CE(i) == 0
        CE_x21 = 2.25;
    elseif CE(i) == 16
        CE_x21 = 75;
    else
        CE_x21 = CE_X21(CE(i)) + (CE_X21(CE(i)+1)-CE_X21(CE(i)))./2;
    end %if
    vx = GD1_p1.*u(CE_x21,type,0,norm) + ...
        (1-GD1_p1).*u(CE_x22,type,0,norm);
    EV_k(i) = vx./u(x_sure,type,0,norm);
    clear vx aux CE_x21
end %i

%% Insurance Predictions for all models
w = 5;
loss = 3;
alphas = 0:0.01:1;
No_Ins_Decisions = 12;
p = [0.05, 0.05, 0.1, 0.1, 0.1, 0.1, 0.2, 0.2, 0.4, 0.7, 0.7, 0.7];
lambda = [1.5, 2.5, 1, 1.25, 1.5, 2.5, 1.25, 1.5, 1.5, 1, 1.25, 0.8];
% next matrix is coded as Subject_ID, Ins_Decision_No, p, lambda, CPT1 (no loss in buying), CPT2 (all loss domain), EUT1, EUT2, RDEU1, RDEU2, KR, DT1, DT2
% and then models EV, EUT1, EUT2, RDEU1, RDEU2, DT1 and DT2 with a certainty effect.
Alpha_Star = zeros(length(GD1).*No_Ins_Decisions,20);
Alpha_Star_01 = zeros(length(GD1).*No_Ins_Decisions,20);
index = 1;
for j = 1:length(GD1)
    for i = 1:No_Ins_Decisions
        Alpha_Star(index,1:4) = [Subject_ID(j), i, p(i), lambda(i)];
        Alpha_Star_01(index,1:4) = [Subject_ID(j), i, p(i), lambda(i)];
        % Vector of premiums for the varying degrees of insurance demand
        Premiums = alphas.*loss.*lambda(i).*p(i);
        % CPT
        CPT_NLIB = weightp2(p(i),PW_l_p(j),phi).*LA_p(j).*u_loss((alphas-1).*loss + Premiums(length(Premiums))-Premiums,type,UC_l_p(j),norm)...
            + weightp2(1-p(i),PW_g_p(j),phi).*u(Premiums(length(Premiums))-Premiums,type,UC_g_p(j),norm);
        [~,AlphaInd] = max(CPT_NLIB);
        Alpha_Star(index,5) = (AlphaInd-1)/100;
        Alpha_Star_01(index,5) = (CPT_NLIB(101)>=CPT_NLIB(1));
        CPT_AL = weightp2(p(i),PW_l_p(j),phi).*u_loss(-(1-alphas).*loss-Premiums,type,UC_l_p(j),norm) ...
            + (1-weightp2(p(i),PW_l_p(j),phi)).*u_loss(-Premiums,type,UC_l_p(j),norm);
        [~,AlphaInd] = max(CPT_AL);
        Alpha_Star(index,6) = (AlphaInd-1)/100;
        Alpha_Star_01(index,6) = (CPT_AL(101)>=CPT_AL(1));
        % EUT
        EUT1 = p(i).*u(w-loss+alphas.*loss-Premiums,type,EUT_UC_g(j),norm)...
            + (1-p(i)).*u(w-Premiums,type,EUT_UC_g(j),norm);
        [~,AlphaInd] = max(EUT1);
        Alpha_Star(index,7) = (AlphaInd-1)/100;
        Alpha_Star_01(index,7) = (EUT1(101)>=EUT1(1));
        EUT2 = p(i).*u(w-loss+alphas.*loss-Premiums,type,EUT_UC_l(j),norm)...
            + (1-p(i)).*u(w-Premiums,type,EUT_UC_l(j),norm);
        [~,AlphaInd] = max(EUT2);
        Alpha_Star(index,8) = (AlphaInd-1)/100;
        Alpha_Star_01(index,8) = (EUT2(101)>=EUT2(1));
        % RDEU
        RDEU1 = weightp2(p(i),PW_g_p(j),phi).*u(w-loss+alphas.*loss-Premiums,type,UC_g_p(j),norm)...
            + (1-weightp2(p(i),PW_g_p(j),phi)).*u(w-Premiums,type,UC_g_p(j),norm);
        [~,AlphaInd] = max(RDEU1);
        Alpha_Star(index,9) = (AlphaInd-1)/100;
        Alpha_Star_01(index,9) = (RDEU1(101)>=RDEU1(1));
        RDEU2 = weightp2(p(i),PW_l_p(j),phi).*u(w-loss+alphas.*loss-Premiums,type,-1.*UC_l_p(j),norm)...
            + (1-weightp2(p(i),PW_l_p(j),phi)).*u(w-Premiums,type,-1.*UC_l_p(j),norm);
        [~,AlphaInd] = max(RDEU2);
        Alpha_Star(index,10) = (AlphaInd-1)/100;
        Alpha_Star_01(index,10) = (RDEU2(101)>=RDEU2(1));
        % KR
        KR = w-(lambda(i)-1).*p(i).*alphas.*loss - p(i).*loss...
            + p(i).*(1-p(i)).*u((1-alphas).*loss,type,0,norm)...
            + p(i).*(1-p(i)).*KR_LA(j).*u_loss(-1.*(1-alphas).*loss,type,0,norm);
        [~,AlphaInd] = max(KR);
        Alpha_Star(index,11) = (AlphaInd-1)/100;
        Alpha_Star_01(index,11) = (KR(101)>=KR(1));
        % Dual Theory
        DT1 = weightp2(p(i),DT_PW_g(j),phi).*u(w-loss+alphas.*loss-Premiums,type,0,norm)...
            + (1-weightp2(p(i),DT_PW_g(j),phi)).*u(w-Premiums,type,0,norm);
        [~,AlphaInd] = max(DT1);
        Alpha_Star(index,12) = (AlphaInd-1)/100;
        Alpha_Star_01(index,12) = (DT1(101)>=DT1(1));
        DT2 = weightp2(p(i),DT_PW_l(j),phi).*u(w-loss+alphas.*loss-Premiums,type,0,norm)...
            + (1-weightp2(p(i),DT_PW_l(j),phi)).*u(w-Premiums,type,0,norm);
        [~,AlphaInd] = max(DT2);
        Alpha_Star(index,13) = (AlphaInd-1)/100;
        Alpha_Star_01(index,13) = (DT2(101)>=DT2(1));
        % EV_CE including Certainty Effect
        EV_CE = p(i).*u(w-loss+alphas.*loss-Premiums,type,0,norm)...
            + (1-p(i)).*u(w-Premiums,type,0,norm);
        EV_CE(101) = u(w-Premiums(101),type,0,norm).*EV_k(j);
        [~,AlphaInd] = max(EV_CE);
        Alpha_Star(index,14) = (AlphaInd-1)/100;
        Alpha_Star_01(index,14) = (EV_CE(101)>=EV_CE(1));
        % EUT including Certainty Effect
        EUT1_CE = EUT1;
        EUT1_CE(101) = u((w-Premiums(101)).*EUT_k(j),type,EUT_UC_g(j),norm);
        [~,AlphaInd] = max(EUT1_CE);
        Alpha_Star(index,15) = (AlphaInd-1)/100;
        Alpha_Star_01(index,15) = (EUT1_CE(101)>=EUT1_CE(1));
        EUT2_CE = EUT2;
        EUT2_CE(101) = u((w-Premiums(101)).*EUT_k(j),type,EUT_UC_l(j),norm);
        [~,AlphaInd] = max(EUT2_CE);
        Alpha_Star(index,16) = (AlphaInd-1)/100;
        Alpha_Star_01(index,16) = (EUT2_CE(101)>=EUT2_CE(1));
        % RDEU including Certainty Effect
        RDEU1_CE = RDEU1;
        RDEU1_CE(101) = u((w-Premiums(101)).*k(j),type,UC_g_p(j),norm);
        [~,AlphaInd] = max(RDEU1_CE);
        Alpha_Star(index,17) = (AlphaInd-1)/100;
        Alpha_Star_01(index,17) = (RDEU1_CE(101)>=RDEU1_CE(1));
        RDEU2_CE = RDEU2;
        RDEU2_CE(101) = u((w-Premiums(101)).*k(j),type,-1.*UC_l_p(j),norm);
        [~,AlphaInd] = max(RDEU2_CE);
        Alpha_Star(index,18) = (AlphaInd-1)/100;
        Alpha_Star_01(index,18) = (RDEU2_CE(101)>=RDEU2_CE(1));
        % DT including Certainty Effect
        DT1_CE = DT1;
        DT1_CE(101) = u(w-Premiums(101),type,0,norm).*DT_k(j);
        [~,AlphaInd] = max(DT1_CE);
        Alpha_Star(index,19) = (AlphaInd-1)/100;
        Alpha_Star_01(index,19) = (DT1_CE(101)>=DT1_CE(1));
        DT2_CE = DT2;
        DT2_CE(101) = u(w-Premiums(101),type,0,norm).*DT_k(j);
        [~,AlphaInd] = max(DT2_CE);
        Alpha_Star(index,20) = (AlphaInd-1)/100;
        Alpha_Star_01(index,20) = (DT2_CE(101)>=DT2_CE(1));
        index = index + 1;
    end
end

%% Create Output
% matrix is coded as Subject_ID, Ins_Decision_No, p, lambda, CPT1 (no loss in buying), 
% CPT2 (all loss domain), EUT1, EUT2, RDEU1, RDEU2, KR, DT1, DT2
% and then models EV, EUT1, EUT2, RDEU1, RDEU2, DT1 and DT2 with a certainty effect.
AlphaStarTable = array2table(Alpha_Star);
%AlphaStarTable01 = array2table(Alpha_Star_01);

AlphaStarTable.Properties.VariableNames = {'Subject_ID', 'Ins_Decision_No', 'p', 'lambda', 'CPT1_NLIB', 'CPT2_all_loss', 'EUT1', 'EUT2', 'RDEU1', 'RDEU2', 'KR', 'DT1', 'DT2', 'EV_ce', 'EUT_g_ce', 'EUT_l_ce', 'RDEU_g_ce', 'RDEU_l_ce', 'DT_g_ce', 'DT_l_ce'}
%AlphaStarTable01.Properties.VariableNames = {'Subject_ID', 'Ins_Decision_No', 'p', 'lambda', 'CPT1_NLIB', 'CPT2_all_loss', 'EUT1', 'EUT2', 'RDEU1', 'RDEU2', 'KR', 'DT1', 'DT2', 'EV_ce', 'EUT_g_ce', 'EUT_l_ce', 'RDEU_g_ce', 'RDEU_l_ce', 'DT_g_ce', 'DT_l_ce'}

writetable(AlphaStarTable, '../data/coins_predictions.xls');
%writetable(AlphaStarTable01, 'coins_predictions01.xls');
toc