%% File name: Curvature based Speed model
clear all;
close all;
%  Description: Design curvature based speed model
%  Authors: Kyuhwan Yeon (kyuhwanyeon@gmail.com)
%  Copyright(C) 2018 ACE Lab, All Right Reserved.
% *************************************************************************
%% Load B_spline road model & Vehicle driving data
% load('../004_Data/CarmakerLogging/0317/RoadMdl/CM_RdlMdl_Ang30.mat') % RoadModel
% Dataset = load('../004_Data/CarmakerLogging/0317/CM_CANformat_Ang30.mat'); % Vehicle driving data
ColorCode();
load('../003_Data/RoadMdl/CM_RdMdl_Ang30_v30.mat') % RoadModel
Dataset = load('../003_Data/DrivingData/CM_CANformat_Ang30_v100.mat'); % Vehicle driving data
%% 1. Data Preprocess
%%    1.1 Vehicle Data
%%      1.1.1 Filtering Steering angle
Temp_StrAng = Dataset.SAS_Angle(:,end);
Length_SAS = length(Temp_StrAng);
Temp_StrAngFlt = zeros(Length_SAS,1);
for IdxData = 1: Length_SAS
    if(Temp_StrAng(IdxData) < 3276.7 && Temp_StrAng(IdxData) > 0)
        Temp_StrAngFlt(IdxData) = Temp_StrAng(IdxData);
    elseif(Temp_StrAng(IdxData) > 3276.7)
        Temp_StrAngFlt(IdxData) = (Temp_StrAng(IdxData) - 6553.6);
    end
end
for i = 1 : length(Temp_StrAngFlt)
    if (Temp_StrAngFlt(i) >200 || Temp_StrAngFlt(i) <-250)
        Temp_StrAngFlt(i) = Temp_StrAngFlt(i-1);
    end
end
%%      1.1.2 Interpolate data
Totallength = (Dataset.RoadLength(end));
Totallength = round(Totallength/10);
Totallength = 10*Totallength;
limit = Totallength; % 5100m (without traffic right), 7300m (Whole Track)
Sampling = 5; %10m

ExpandRange = 200000;
ExpolatedRange = linspace(0,1,ExpandRange);


Roadway = single(InterPolatedData(ExpolatedRange,  (Dataset.RoadLength(:,end))));
Ego_Velocity = single(InterPolatedData(Roadway,  Dataset.WHL_SPD_FL(:,end)));
Ego_Accel = single(InterPolatedData(Roadway,  Dataset.LONG_ACCEL(:,end)));
Location = Roadway;
SteeringAg =  single(InterPolatedData(Roadway, Temp_StrAngFlt(:,end)));
Lat_Accel =  single(InterPolatedData(Roadway, Dataset.LAT_ACCEL(:,end)));
Time = single(InterPolatedData(Roadway, Dataset.Time(:,end)));
% %% Flatten coordinate (Flatten Earth)
% Lat = Dataset.sig_State_Lat(:,end);
% Long = Dataset.sig_State_Lon(:,end);
% Height = Dataset.Height(:,end);
% XYZ_flat = [];
% for i  = 1: length(Lat)
%     XYZ_flat_temp = lla2flat([Lat(i), Long(i), Height(i)], [Lat(1),Long(1)], 0,0);
%     XYZ_flat = [XYZ_flat; XYZ_flat_temp];
% end
%
% figure(99)
% plot(XYZ_flat(:,1),XYZ_flat(:,2));
% X_flat = XYZ_flat(:,1);
% Y_flat = XYZ_flat(:,2);
% LineTemp = linspace(1,length(X_flat),length(X_flat))';
% Lines=[(1:size(X_flat,1))' (2:size(X_flat,1)+1)']; Lines(end,2)=1;
% % Lines = [LineTemp(1:end,1),LineTemp(2:end,1)+1];
% Curvature_flat = LineCurvature2D([X_flat,Y_flat],Lines);
% axis equal;
%
% dx  = gradient(X_flat);
% ddx = gradient(dx);
% dy  = gradient(Y_flat);
% ddy = gradient(dy);
% num   = dx .* ddy - ddx .* dy;
% denom = dx .* dx + dy .* dy;
% denom = sqrt(denom);
% denom = denom .* denom .* denom;
% curvature_flat = num ./ denom;
% curvature_flat(denom < 0) = NaN;
% figure(98)
% plot(curvature_flat);
% ylim([-1,1]);
%%      1.1.3 Change to sn coordinate system
sn_MaxRoadPos =limit/Sampling-1; %max(sn_MaxRoadPosArr);
sn_Ego_Velocity = single(zeros(1,sn_MaxRoadPos));
sn_Ego_Accel = single(zeros(1,sn_MaxRoadPos));
sn_Location = single(zeros(1,sn_MaxRoadPos));
sn_Aps = single(zeros(1,sn_MaxRoadPos));
sn_SteeringAg= single(zeros(1,sn_MaxRoadPos));
sn_Lat_Accel= single(zeros(1,sn_MaxRoadPos));
sn_Time = single(zeros(1,sn_MaxRoadPos));
% sn_X = single(zeros(1,sn_MaxRoadPos));
% sn_Y = single(zeros(1,sn_MaxRoadPos));
% sn_Z = single(zeros(1,sn_MaxRoadPos));

PrePos = 0;
count = 0;
PrePos = Sampling;
for j = 1 : length(Roadway)
    
    CurPos  = Roadway(j);
    if CurPos<limit
        if (CurPos - PrePos) >0
            count = count +1;
            PrePos = PrePos+Sampling;
            sn_Ego_Velocity(count) =Ego_Velocity(j);
            sn_Ego_Accel(count) = Ego_Accel(j);
            sn_Location(count) = Location(j);
            sn_SteeringAg(count) =SteeringAg(j);
            sn_Lat_Accel(count) = Lat_Accel(j);
            sn_Time(count) = Time(j);
        end
    end
end
%%      1.1.4 Find XYZ coordinate
XYZ= single(fnval(B_SplineRoadModel,sn_Location));
sn_X = XYZ(1,:);
sn_Y = XYZ(2,:);
sn_Z = XYZ(3,:);
%%    1.2 Road Data
%%      1.2.1 Calculate curvature
%%        [Process 1] Calcuate dervative of B_Spline
dB_SplineRoadModel = fnder(B_SplineRoadModel);
dVal_B_SplineRoadModel = single(fnval(dB_SplineRoadModel,sn_Location));
ddB_SplineRoadModel = fnder(dB_SplineRoadModel);
ddVal_B_SplineRoadModel = single(fnval(ddB_SplineRoadModel,sn_Location));
crossD_DD = cross( dVal_B_SplineRoadModel',ddVal_B_SplineRoadModel');

TwoDim_dVal_B_SplineRoadModel=dVal_B_SplineRoadModel;
TwoDim_ddVal_B_SplineRoadModel=ddVal_B_SplineRoadModel;
TwoDim_dVal_B_SplineRoadModel(3,:)=0;
TwoDim_ddVal_B_SplineRoadModel(3,:) = 0;
% CrossProductEle1=TwoDim_dVal_B_SplineRoadModel(:,1).*TwoDim_ddVal_B_SplineRoadModel(:,2);
% CrossProductEle2=TwoDim_dVal_B_SplineRoadModel(:,2).*TwoDim_ddVal_B_SplineRoadModel(:,1);
TwoDim_crossD_DD = cross(TwoDim_dVal_B_SplineRoadModel',TwoDim_ddVal_B_SplineRoadModel');
% TwoDim_crossD_DD = CrossProductEle1-CrossProductEle2;
%%        [Process 2] Calcuate Curvature (3D and 2D Curvature)
numCur = sqrt([1 1 1]*abs(crossD_DD.*crossD_DD)'); % Numerator of curvature
denCur = sqrt([1 1 1]*abs(dVal_B_SplineRoadModel.*dVal_B_SplineRoadModel.*dVal_B_SplineRoadModel)); % Denominator of curvature
denCur= denCur.^3;
ThreeDim_CurvatureRoadModel = numCur ./ denCur;

TwoDim_numCur = sqrt([1 1 1]*abs(TwoDim_crossD_DD.*TwoDim_crossD_DD)'); % Numerator of curvature
TwoDim_denCur = sqrt([1 1 1]*abs(TwoDim_dVal_B_SplineRoadModel.*TwoDim_dVal_B_SplineRoadModel.*TwoDim_dVal_B_SplineRoadModel)); % Denominator of curvature
TwoDim_denCur= TwoDim_denCur.^3;
TwoDim_CurvatureRoadModel = TwoDim_numCur ./ TwoDim_denCur;


sn_Curvature = ThreeDim_CurvatureRoadModel;
flt_curvature = movmean(sn_Curvature,5);
%%      1.2.2 Cacluate radius
Radius = [];
for i  = 1:length(sn_Location)-2
    x1=sn_X(i);
    y1=sn_Y(i);
    x2=sn_X(i+1);
    y2=sn_Y(i+1);
    x3=sn_X(i+2);
    y3=sn_Y(i+2);
    
    input=[x1 y1; x2 y2; x3 y3];
    [R,xyrc] = fit_circle_through_3_points(input);
    Radius=[Radius R];
end
flt_radius = movmean(Radius,2);
%%    1.3 Plot
%%      [Plot 1] Create Map
CurveStandard = 0.003;
HighCV_Idx=find(flt_curvature>CurveStandard);
HC_Curvature=flt_curvature;
HC_Curvature(flt_curvature<CurveStandard)=NaN;
HC_sn_Ego_Velocity = sn_Ego_Velocity;
HC_sn_Ego_Velocity(flt_curvature<CurveStandard)=NaN;
HC_sn_SteeringAngle = sn_SteeringAg;
HC_sn_SteeringAngle(flt_curvature<CurveStandard)=NaN;
HC_flt_radius = flt_radius;
HC_flt_radius(1./flt_radius<CurveStandard)=NaN;
figure(99)
set(gcf, 'color','w','Units', 'Normalized', 'OuterPosition', [0 0.05 1 0.95]);
plot(sn_X,sn_Y,'black','linewidth',2);
hold on;
plot(sn_X(HighCV_Idx),sn_Y(HighCV_Idx),'g*','linewidth',2);
hold off;
axis equal;
legend('Normal curvature', 'High curvature');
title('Map','fontsize',20);
xlabel('[m]');
ylabel('[m]');
grid on;
%%      [Plot 2] Curvature VS Speed VS 1/Radius
pltIndxRoad = 1 : length(flt_curvature);
pltIndxRoad = Sampling*pltIndxRoad;
figure(2)
set(gcf, 'color','w','Units', 'Normalized', 'OuterPosition', [0 0.05 1 0.95]);
subplot(3,1,1)
plot(pltIndxRoad,flt_curvature,'black','linewidth',2);
hold on;
plot(pltIndxRoad,HC_Curvature,'g*','linewidth',0.5);
hold off;
title('Curvature');
grid on;
xlabel('Roadway position [m]');
ylabel('Curvature [1/m]');

subplot(3,1,2)
plot(pltIndxRoad,sn_Ego_Velocity,'black','linewidth',2);
hold on;
plot(pltIndxRoad,HC_sn_Ego_Velocity,'g*','linewidth',0.5);
hold off;
title('Speed');
grid on;
xlabel('Roadway position [m]');
ylabel('Speed [km/h]');

subplot(3,1,3)
plot(pltIndxRoad(2:length(pltIndxRoad)-1),1./flt_radius,'black','linewidth',2);
hold on;
plot(pltIndxRoad(2:length(pltIndxRoad)-1),1./HC_flt_radius,'g*','linewidth',0.5);
hold off;
title('1/Radius');
grid on;
% ylim([0,200]);
xlabel('Roadway position [m]');
ylabel('1/Radius [1/m]');
%%      [Plot 3] Curvature VS 1/Radius
figure(3)
set(gcf, 'color','w','Units', 'Normalized', 'OuterPosition', [0 0.05 1 0.95]);
subplot(2,1,1)
plot(1./flt_radius,'linewidth',4);
legend('1/Radius');
title('1/Radius');
grid on;
xlabel('Roadway position [m]');
subplot(2,1,2)
plot(flt_curvature,'linewidth',4);
legend('Curvature');
title('Curvature');
grid on;
xlabel('Roadway position [m]');
%%      [Plot 4] Curvature VS Lateral acceleration
% flt_Lat_Accel = movmean(sn_Lat_Accel,2);
figure(800)
set(gcf, 'color','w','Units', 'Normalized', 'OuterPosition', [0 0.05 1 0.95]);
subplot(2,1,1)
plot(abs(sn_Lat_Accel),'linewidth',4);
legend('Lat Accel');
title('Lat Accel');
grid on;
xlabel('Roadway position [m]');
subplot(2,1,2)
plot(flt_curvature,'linewidth',4);
legend('Curvature');
title('Curvature');
grid on;
xlabel('Roadway position [m]');

Abs_Lat_Accel = abs(sn_Lat_Accel);
figure(801)
set(gcf, 'color','w','Units', 'Normalized', 'OuterPosition', [0 0.05 1 0.95]);
% scatter(sn_Curvature,Abs_Lat_Accel,'r');
scatter(flt_curvature,Abs_Lat_Accel,'b');
title('Lat Accel');
grid on;
xlabel('curvature');
ylabel('lateral acceleration');
axis square;
%%      [Plot 5] GRG Seminar Map VS CUrvature VS Speed
% flt_Lat_Accel = movmean(sn_Lat_Accel,2);
figure(803)

% set(gcf, 'color','w','Units', 'Normalized', 'OuterPosition', [0 0.05 1 0.95]);

set(gcf, 'color','w','pos',[10 10 1600 700]);
subplot(2,13,[1,2,3,4,14,15,16.17]);
plot(sn_X,sn_Y,'black','linewidth',2);
hold on;
plot(sn_X(HighCV_Idx),sn_Y(HighCV_Idx),'g*','linewidth',2);
hold off;
axis equal;
legend('Normal curvature', 'High curvature');
title('Test site: Midan A course','fontsize',12);
xlabel('[m]');
ylabel('[m]');
grid on;


subplot(2,13,[6:13]);
plot(pltIndxRoad,flt_curvature,'black','linewidth',2);
hold on;
plot(pltIndxRoad,HC_Curvature,'g*','linewidth',4);
hold off;
title('Curvature');
grid on;
xlabel('Roadway position [m]');
ylabel('Curvature [1/m]');


subplot(2,13,[19:26]);
plot(pltIndxRoad,sn_Ego_Velocity,'black','linewidth',2);
hold on;
plot(pltIndxRoad,HC_sn_Ego_Velocity,'g*','linewidth',4);
hold off;
title('Speed');
grid on;
xlabel('Roadway position [m]');
ylabel('Speed [km/h]');
%% 2. Design Curvature based Speed Model (Composed with 3 sections)
%%      [Process 1] Set range of sections
CurveInit = round(660/Sampling);
CurveEnd = round(750/Sampling);
% RangeEye2Road = 24;
Section_range = round(20/Sampling);
FirstCurve_Total = CurveInit:CurveEnd;
FC_Tot_Curvature = double(flt_curvature(FirstCurve_Total));
FC_Tot_Speed =double(sn_Ego_Velocity(FirstCurve_Total));
FC_Tot_V0 = FC_Tot_Speed(1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FirstCurve_Entry = CurveInit:CurveInit+Section_range-1;
FC_Ent_Curvature = double(flt_curvature(FirstCurve_Entry));
FC_Ent_Speed =double(sn_Ego_Velocity(FirstCurve_Entry));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FirstCurve_middle = CurveInit+Section_range:CurveEnd-Section_range;
FC_Mid_Curvature = double(flt_curvature(FirstCurve_middle));
FC_Mid_Speed =double(sn_Ego_Velocity(FirstCurve_middle));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FirstCurve_Exit = CurveEnd-Section_range+1:CurveEnd;
FC_Exit_Curvature = double(flt_curvature(FirstCurve_Exit));
FC_Exit_Speed =double(sn_Ego_Velocity(FirstCurve_Exit));
%%      [Process 2] Design Curv based Speed Mdl
FC_Ent_V0 = FC_Ent_Speed(1);
fun1 = @(k,FC_Curvature)FC_Ent_V0-k(1)*exp(k(2)*FC_Ent_V0*FC_Curvature);
k0 = [0,0];
k_ent = lsqcurvefit(fun1,k0,FC_Ent_Curvature,FC_Ent_Speed);
CurMdlSpd_Ent = fun1(k_ent,FC_Ent_Curvature);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FC_Mid_V0 = CurMdlSpd_Ent(end);
fun2 = @(k,FC_Curvature)FC_Mid_V0-k(1)*exp(k(2)*FC_Mid_V0*FC_Curvature);
k_mid = lsqcurvefit(fun2,k0,FC_Mid_Curvature,FC_Mid_Speed);
CurMdlSpd_Mid = fun2(k_mid,FC_Mid_Curvature);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FC_Exit_V0 = CurMdlSpd_Mid(end);
fun3 = @(k,FC_Curvature)FC_Exit_V0-k(1)*exp(k(2)*FC_Exit_V0*FC_Curvature);
k_exit = lsqcurvefit(fun3,k0,FC_Exit_Curvature,FC_Exit_Speed);
CurMdlSpd_Exit = fun3(k_exit,FC_Exit_Curvature);
%%      [Process 3] Result Plot
CurvMdlSpd_3parts = [CurMdlSpd_Ent CurMdlSpd_Mid CurMdlSpd_Exit];

figure(5)
pltIndxRoad = Sampling*FirstCurve_Entry;
% set(gcf, 'color','w','Units', 'Normalized', 'OuterPosition', [0 0.05 1 0.95]);
set(gcf, 'color','w','pos',[10 10 1300 700]);
subplot(2,3,1)
plot(pltIndxRoad,FC_Ent_Speed,'black','linewidth',3);
hold on;
plot(pltIndxRoad,fun1(k_ent,FC_Ent_Curvature),'magenta','linewidth',3);
ylabel('Vehicle Speed [km/h]');
legend('true','Curvature Model');
xlabel('Roadway position [m]');
hold off;
title('Curve Speed model (Enter section)');
grid on;
subplot(2,3,2)
pltIndxRoad = Sampling*FirstCurve_middle;
plot(pltIndxRoad,FC_Mid_Speed,'black','linewidth',3);
hold on;
plot(pltIndxRoad,fun2(k_mid,FC_Mid_Curvature),'magenta','linewidth',3);
ylabel('Vehicle Speed [km/h]');
legend('true','Curvature Model');
xlabel('Roadway position [m]');
hold off;
title('Curve Speed model (Mid section)');
grid on;

subplot(2,3,3)
pltIndxRoad = Sampling*FirstCurve_Exit;
plot(pltIndxRoad,FC_Exit_Speed,'black','linewidth',3);
hold on;
plot(pltIndxRoad,fun3(k_exit,FC_Exit_Curvature),'magenta','linewidth',3);
ylabel('Vehicle Speed [km/h]');
legend('true','Curvature Model');
xlabel('Roadway position [m]');
title('Curve Speed model (Exit section)');
grid on;
hold off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(2,3,4:6)
pltIndxRoad = Sampling*FirstCurve_Total;
plot(pltIndxRoad,FC_Tot_Speed,'black','linewidth',3);
hold on;
plot(pltIndxRoad,CurvMdlSpd_3parts,'magenta','linewidth',3);
legend('true','Curvature Model');
xlabel('Roadway position [m]');
ylabel('Vehicle Speed [km/h]');
title('Curvature based Speed Model');
legend('true','Curvature Model');
grid on;
hold off;
% %% 3. Design Curvature based Speed Model (Composed with 2 sections) (Modelling)
% %%      [Process 1] Set range of sections
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [FC_Curve_max,FC_Curve_maxIdx] = max(FC_Tot_Curvature);
% Section_range = FC_Curve_maxIdx;
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FirstCurve_Entry = CurveInit:CurveInit+Section_range-1;
% FC_Ent_Curvature = double(flt_curvature(FirstCurve_Entry));
% FC_Ent_Speed =double(sn_Ego_Velocity(FirstCurve_Entry));
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FirstCurve_Exit = CurveInit+Section_range:CurveEnd;
% FC_Exit_Curvature = double(flt_curvature(FirstCurve_Exit));
% FC_Exit_Speed =double(sn_Ego_Velocity(FirstCurve_Exit));
% %%      [Process 2] Design Curv based Speed Mdl
% FC_Ent_V0 = FC_Ent_Speed(1);
% fun1 = @(k,FC_Curvature)FC_Ent_V0-k(1)*exp(k(2)*FC_Ent_V0*FC_Curvature);
% k0 = [0,0];
% k_ent = lsqcurvefit(fun1,k0,FC_Ent_Curvature,FC_Ent_Speed);
% CurMdlSpd_Ent = fun1(k_ent,FC_Ent_Curvature);
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FC_Exit_V0 = CurMdlSpd_Ent(end);
% fun3 = @(k,FC_Curvature)FC_Exit_V0-k(1)*exp(k(2)*FC_Exit_V0*FC_Curvature);
% k_exit = lsqcurvefit(fun3,k0,FC_Exit_Curvature,FC_Exit_Speed);
% CurMdlSpd_Exit = fun3(k_exit,FC_Exit_Curvature);
% %%      [Process 3] Result Plot
% figure(7)
% % set(gcf, 'color','w','Units', 'Normalized', 'OuterPosition', [0 0.05 1 0.95]);
% set(gcf, 'color','w','pos',[10 10 1300 700]);
% subplot(2,2,1)
% pltIndxRoad = Sampling*FirstCurve_Entry;
% plot(pltIndxRoad,FC_Ent_Speed,'black','linewidth',3);
% hold on;
% plot(pltIndxRoad,fun1(k_ent,FC_Ent_Curvature),'magenta','linewidth',3);
% hold off;
% ylabel('Vehicle Speed [km/h]');
% legend('true','Curvature Model');
% xlabel('Roadway position [m]');
% title('Curve Speed model (Enter section)');
% grid on;
% subplot(2,2,2)
% pltIndxRoad = Sampling*FirstCurve_Exit;
% plot(pltIndxRoad,FC_Exit_Speed,'black','linewidth',3);
% hold on;
% plot(pltIndxRoad,fun3(k_exit,FC_Exit_Curvature),'magenta','linewidth',3);
% hold off;
% ylabel('Vehicle Speed [km/h]');
% legend('true','Curvature Model');
% xlabel('Roadway position [m]');
% title('Curve Speed model (Exit section)');
% grid on;
% 
% CurvMdlSpd_2parts = [CurMdlSpd_Ent CurMdlSpd_Exit];
% subplot(2,2,3:4)
% pltIndxRoad = Sampling*FirstCurve_Total;
% plot(pltIndxRoad,FC_Tot_Speed,'black','linewidth',3);
% hold on;
% plot(pltIndxRoad,CurvMdlSpd_2parts,'magenta','linewidth',3);
% hold off;
% xlabel('Roadway Position [m]');
% ylabel('Vehicle Speed [km/h]');
% title('Curvature based Speed Model');
% legend('true','Curvature Model');
% grid on;
% % Calculation R2 RMSE
% [R2_Mdl_2sect_mdl, RMSE_Mdl_2sect_mdl] = Cal_RMSE_RSQUARE(FC_Tot_Speed,CurvMdlSpd_2parts);
% %% 4. Design Curvature based Speed Model (Composed with 2 sections) (Validation)
% %%      [Process 1] Set range of sections
% CurveInit = round(3680/Sampling);
% CurveEnd = round(3780/Sampling);
% % RangeEye2Road = 24;
% SecondCurve_Total = CurveInit:CurveEnd;
% SC_Tot_Curvature = double(flt_curvature(SecondCurve_Total));
% SC_Tot_Speed =double(sn_Ego_Velocity(SecondCurve_Total));
% SC_Tot_V0 = SC_Tot_Speed(1);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [SC_Curve_max,SC_Curve_maxIdx] = max(SC_Tot_Curvature);
% Section_range = SC_Curve_maxIdx;
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SecondCurve_Entry = CurveInit:CurveInit+Section_range-1;
% SC_Ent_Curvature = double(flt_curvature(SecondCurve_Entry));
% SC_Ent_Speed =double(sn_Ego_Velocity(SecondCurve_Entry));
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SecondCurve_Exit = CurveInit+Section_range:CurveEnd;
% SC_Exit_Curvature = double(flt_curvature(SecondCurve_Exit));
% SC_Exit_Speed =double(sn_Ego_Velocity(SecondCurve_Exit));
% %%      [Process 2] Design Curv based Speed Mdl
% SC_Ent_V0 = SC_Ent_Speed(1);
% fun1 = @(k,SC_Curvature)SC_Ent_V0-k(1)*exp(k(2)*SC_Ent_V0*SC_Curvature);
% k0 = [0,0];
% 
% CurMdlSpd_Ent = fun1(k_ent,SC_Ent_Curvature);
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SC_Exit_V0 = CurMdlSpd_Ent(end);
% fun3 = @(k,SC_Curvature)SC_Exit_V0-k(1)*exp(k(2)*SC_Exit_V0*SC_Curvature);
% CurMdlSpd_Exit = fun3(k_exit,SC_Exit_Curvature);
% %%      [Process 3] Result Plot
% figure(900)
% % set(gcf, 'color','w','Units', 'Normalized', 'OuterPosition', [0 0.05 1 0.95]);
% set(gcf, 'color','w','pos',[10 10 1300 700]);
% subplot(2,2,1)
% pltIndxRoad = Sampling*SecondCurve_Entry;
% plot(pltIndxRoad,SC_Ent_Speed,'black','linewidth',3);
% hold on;
% plot(pltIndxRoad,fun1(k_ent,SC_Ent_Curvature),'magenta','linewidth',3);
% hold off;
% ylabel('Vehicle Speed [km/h]');
% legend('true','Curvature Model');
% xlabel('Roadway position [m]');
% title('Curve Speed model (Enter section)');
% grid on;
% subplot(2,2,2)
% pltIndxRoad = Sampling*SecondCurve_Exit;
% plot(pltIndxRoad,SC_Exit_Speed,'black','linewidth',3);
% hold on;
% plot(pltIndxRoad,fun3(k_exit,SC_Exit_Curvature),'magenta','linewidth',3);
% hold off;
% ylabel('Vehicle Speed [km/h]');
% legend('true','Curvature Model');
% xlabel('Roadway position [m]');
% title('Curve Speed model (Exit section)');
% grid on;
% 
% CurvMdlSpd_2parts = [CurMdlSpd_Ent CurMdlSpd_Exit];
% subplot(2,2,3:4)
% pltIndxRoad = Sampling*SecondCurve_Total;
% plot(pltIndxRoad,SC_Tot_Speed,'black','linewidth',3);
% hold on;
% plot(pltIndxRoad,CurvMdlSpd_2parts,'magenta','linewidth',3);
% hold off;
% xlabel('Roadway Position [m]');
% ylabel('Vehicle Speed [km/h]');
% title('Curvature based Speed Model');
% legend('true','Curvature Model');
% grid on;
% % Calculation R2 RMSE
% [R2_Mdl_2sect_val, RMSE_Mdl_2sect_val] = Cal_RMSE_RSQUARE(SC_Tot_Speed,CurvMdlSpd_2parts);

% %% 5. Design Lateral Acceleration based Speed Model
% %%      [Process 1] Set range of sections
% FC_Radius = flt_radius(FirstCurve_Total+1);
% figure(8)
% set(gcf, 'color','w','Units', 'Normalized', 'OuterPosition', [0 0.05 1 0.95]);
% plot(FC_Radius);
% LatMax = 3.8;
% Spd_Rad = sqrt(LatMax*FC_Radius)*3.6;
% figure(9)
% plot(Spd_Rad);
% %%
% Small_RadIdx = find(FC_Radius<30);
% Spd_SmallRad = sqrt(LatMax*FC_Radius(Small_RadIdx))*3.6;
% figure(10)
% plot(Spd_SmallRad);
% 
% 
% % %%
% % figure(12)
% % subplot(2,1,1)
% % plot(Radius);
% % ylim([0,100]);
% % subplot(2,1,2)
% % plot(sn_Curvature);

% %%
% 
% figure(12)
% scatter(1./flt_radius(HighCV_Idx), sn_Ego_Velocity(HighCV_Idx));
% 
% hold off;
% %%
% 
% Inverse_HC_radius=1./HC_flt_radius;
% Indx_Curve = find(Inverse_HC_radius>0.002);
% Indx_Curve_Enter = [];
% Indx_Curve_Exit = [];
% Indx_Temp  = 0 ;
% for i = 1: length(Indx_Curve)
%     if(Indx_Temp - Indx_Curve(i) <-300/Sampling)
%         Indx_Temp= Indx_Curve(i);
%         Indx_Curve_Enter = [Indx_Curve_Enter; Indx_Temp];
%         
%     end
% end
% Indx_Temp  = 10000000 ;
% for i = length(Indx_Curve): -1 : 1
%     if(Indx_Temp - Indx_Curve(i) >300/Sampling)
%         Indx_Temp= Indx_Curve(i);
%         Indx_Curve_Exit = [Indx_Temp;Indx_Curve_Exit];
%     end
% end
% Indx_Curve_EnterExit = [Indx_Curve_Enter,Indx_Curve_Exit];
% 
% Indx_Curve_EnterSection = zeros(length(Indx_Curve_EnterExit),200/Sampling);
% 
% for i = 1: length(Indx_Curve_EnterExit)
%     for j = 1 : round((Indx_Curve_Exit(i,1)- Indx_Curve_Enter(i,1))/2)
%         Indx_Curve_EnterSection(i,j) = Indx_Curve_Enter(i,1)+j;
%     end
% end
% 
% Indx_Temp=0;
% Indx_Curve_EnterSection_1D = [];
% for i = 1: length(Indx_Curve_EnterSection(:,1))
%     for j = 1: length(Indx_Curve_EnterSection(1,:))-1
%         if(Indx_Temp - Indx_Curve_EnterSection(i,j) <500)            
%             Indx_Curve_EnterSection_1D = [Indx_Curve_EnterSection_1D; Indx_Curve_EnterSection(i,j)];
%             Indx_Temp = Indx_Curve_EnterSection(i,j);            
%         end
%     end
%     
% end

%% Plot Accel VehSpd Curvature
Radius_revised = [10000, Radius, 10000];
pltIndxRoad = 1 : length(flt_curvature);
pltIndxRoad = Sampling*pltIndxRoad;
% 
PlotRange = [700/Sampling : 1400/Sampling];
% 
% PlotRange = [4700/Sampling : 5500/Sampling];

FontSize = 13;
figure(15)
set(gcf, 'color','w','Units', 'Normalized', 'OuterPosition', [0 0.05 1 0.8]);
subplot(3,2,1)
plot(pltIndxRoad(PlotRange),sn_Ego_Accel(PlotRange),'color',YP(9,:),'linewidth',2);
hold on;
title('Longitudinal Acceleration','fontsize',FontSize);
grid on;
xlabel('Roadway position [m]','fontsize',FontSize);
ylabel('Acceleration [m/s^2]','fontsize',FontSize);

subplot(3,2,3)
plot(pltIndxRoad(PlotRange),sn_Ego_Velocity(PlotRange),'color',RP(9,:),'linewidth',2);
hold on;
title('Speed','fontsize',FontSize);
grid on;
xlabel('Roadway position [m]','fontsize',FontSize);
ylabel('Speed [km/h]','fontsize',FontSize);

subplot(3,2,5)
plot(pltIndxRoad(PlotRange),1./Radius_revised(PlotRange),'color',CP(26,:),'linewidth',2);
% hold on;
% plot(pltIndxRoad(2:length(pltIndxRoad)-1),1./HC_flt_radius,'g*','linewidth',4);
% hold off;
title('Curvature','fontsize',FontSize);
grid on;
% ylim([0,200]);
xlabel('Roadway position [m]','fontsize',FontSize);

ylabel('1/Radius [1/m]','fontsize',FontSize);

set(gcf, 'color','w','Units', 'Normalized', 'OuterPosition', [0 0.05 0.6 0.9]);
subplot(3,2,2)
plot(sn_Time(PlotRange),sn_Ego_Accel(PlotRange),'color',YP(9,:),'linewidth',2);
hold on;
title('Longitudinal Acceleration Time','fontsize',FontSize);
grid on;
xlabel('Time [s]','fontsize',FontSize);
ylabel('Acceleration [m/s^2]','fontsize',FontSize);

subplot(3,2,4)
plot(sn_Time(PlotRange),sn_Ego_Velocity(PlotRange),'color',YP(5,:),'linewidth',2);
hold on;
title('VehicleSpeed','fontsize',FontSize);
grid on;
xlabel('Time [s]','fontsize',FontSize);
ylabel('Speed [km/h]','fontsize',FontSize);

subplot(3,2,6)
plot(sn_Time(PlotRange),1./Radius_revised(PlotRange),'color',CP(26,:),'linewidth',2);
% hold on;
% plot(pltIndxRoad(2:length(pltIndxRoad)-1),1./HC_flt_radius,'g*','linewidth',4);
% hold off;
title('Curvature','fontsize',FontSize);
grid on;
% ylim([0,200]);
xlabel('Time [s]','fontsize',FontSize);
ylabel('1/Radius [1/m]','fontsize',FontSize);

%% Sample data

SampleTime = sn_Time(PlotRange);
SampleDistance = pltIndxRoad(PlotRange);
SampleRadius = Radius_revised(PlotRange);
SampleSpeed= sn_Ego_Velocity(PlotRange);
SampleLongAccel = sn_Ego_Accel(PlotRange);
SampleLatAccel= sn_Lat_Accel(PlotRange);


MinimumRadius=min(SampleRadius);

%% Driver Parameter
LatMax = 3;
%%
V0 = SampleSpeed(1);
IdealV_Final = 3.6*sqrt(LatMax*MinimumRadius);
%% Section devide (Initial Section)
IndexBraking = find(SampleLongAccel<-0.01);
InitIndex_InitialSection = IndexBraking(1);
InitTime_InitialSection = SampleTime(InitIndex_InitialSection);

%% Section devide (Initial Section2)
DerivativeAccelArr = [];
for index  = 1: length(SampleTime)-1
    dt = SampleTime(index+1) - SampleTime(index);
    dAccel = SampleLongAccel(index+1)-SampleLongAccel(index);
    DerivativeAccel = dAccel/dt;
    DerivativeAccelArr = [DerivativeAccelArr DerivativeAccel];
end
flag = 0;
for index  = 1: length(DerivativeAccelArr)
    if flag ==0 && index>InitIndex_InitialSection && DerivativeAccelArr(index)>0
        InitIndex_InitialSection2 = index;
        flag = 1;
    end
end
InitTime_InitialSection2 = SampleTime(InitIndex_InitialSection2);
%% Section devide (Adjustment Section)
IndexLatMax = find(SampleLongAccel<-LatMax+0.01);
InitIndex_AdjustmentSection = IndexLatMax(1);
InitTime_AdjustmentSection = SampleTime(InitIndex_AdjustmentSection);
LengthInitSection1= InitTime_InitialSection2-InitTime_InitialSection;
LengthInitSection2= InitTime_AdjustmentSection-InitTime_InitialSection2;
flag = 0;
DevAccelThreslhold = 0.5;
for index  = 1: length(DerivativeAccelArr)-3
    Temp1 = DerivativeAccelArr(index+3);
    Temp2 =DerivativeAccelArr(index+2);
    Temp3 = DerivativeAccelArr(index+1);
    if flag ==0 && Temp1 >DevAccelThreslhold&&  Temp2>DevAccelThreslhold  && Temp3>DevAccelThreslhold
        InitIndex_TerminationSection=index;
        flag = 1;
    end
end
InitTime_TerminationSection = SampleTime(InitIndex_TerminationSection);
LengthAdjustmentSection = InitTime_TerminationSection - InitTime_AdjustmentSection;
%% Section devide (Termination Section)
IndexAccel=find(SampleLongAccel>-0.3);
flag = 0;
for index = 1: length(IndexAccel)
    if flag ==0 && IndexAccel(index)>InitIndex_TerminationSection
        Temp_ExitIndex_TerminationSection = index;
        flag = 1;
    end
end
ExitIndex_TerminationSection = IndexAccel(Temp_ExitIndex_TerminationSection);
ExitTime_TerminationSection = SampleTime(ExitIndex_TerminationSection);
LengthTerminationSection =  ExitTime_TerminationSection-InitTime_TerminationSection;
%%

fig=figure('name','Timing parameter','numbertitle','off');
set(gcf, 'color','w','Units', 'Normalized', 'OuterPosition', [0 0.05 0.5 0.55]);

% Set sub plot 1;
ax1 = subplot(1,1,1);
set(ax1,'parent',fig);hold(ax1,'on');box(ax1,'on')
plot(ax1,SampleTime,SampleLongAccel,'color',WP(8,:),'linewidth',6);grid on;
scatter(ax1, SampleTime(InitIndex_InitialSection), SampleLongAccel(InitIndex_InitialSection),'*','MarkerEdgeColor',PP(4,:),'LineWidth',9);
scatter(ax1, SampleTime(InitIndex_InitialSection2), SampleLongAccel(InitIndex_InitialSection2),'*','MarkerEdgeColor',PP(4,:),'LineWidth',9);
scatter(ax1, SampleTime(InitIndex_AdjustmentSection), SampleLongAccel(InitIndex_AdjustmentSection),'*','MarkerEdgeColor',PP(4,:),'LineWidth',9);
scatter(ax1, SampleTime(InitIndex_TerminationSection), SampleLongAccel(InitIndex_TerminationSection),'*','MarkerEdgeColor',PP(4,:),'LineWidth',9);
scatter(ax1, SampleTime(ExitIndex_TerminationSection), SampleLongAccel(ExitIndex_TerminationSection),'*','MarkerEdgeColor',PP(4,:),'LineWidth',9);

title('Longitudinal Acceleration Time','fontsize',FontSize);
xlabel('Time [s]','fontsize',FontSize);
ylabel('Acceleration [m/s^2]','fontsize',FontSize);
%%
TimingParameters_t = [InitTime_InitialSection, InitTime_InitialSection2,InitTime_AdjustmentSection, InitTime_TerminationSection, ExitTime_TerminationSection];
Accel_Timing = [SampleLongAccel(InitIndex_InitialSection),SampleLongAccel(InitIndex_InitialSection2),SampleLongAccel(InitIndex_AdjustmentSection),SampleLongAccel(InitIndex_TerminationSection),SampleLongAccel(ExitIndex_TerminationSection)];
fig=figure('name','Timing parameter','numbertitle','off');
set(gcf, 'color','w','Units', 'Normalized', 'OuterPosition', [0 0.05 0.5 0.55]);
ax1 = subplot(1,1,1);
set(ax1,'parent',fig);hold(ax1,'on');box(ax1,'on')
plot(ax1,SampleTime,SampleLongAccel,'color',WP(8,:),'linewidth',6);grid on;
plot(ax1,TimingParameters_t,Accel_Timing,'color',PP(4,:),'linewidth',2,'linestyle','--');grid on;
area(ax1,TimingParameters_t,Accel_Timing,'FaceColor',PP(4,:),'EdgeColor',PP(4,:),'linewidth',2,'linestyle',':','FaceAlpha',0.3);

IntegralAccelMdl = abs(trapz(TimingParameters_t, Accel_Timing));
%% Model Parameter setting
Init1_Init2 = LengthInitSection1;
Init2_Adj = LengthInitSection2;
AccelInit2 = abs(SampleLongAccel(InitIndex_InitialSection2));
Adj_Term= LengthAdjustmentSection;
Term_Exit = LengthTerminationSection;
% LatMax
%% Model Validation
StaticArea = (0.5*(Init1_Init2*AccelInit2)+0.5*(LatMax+AccelInit2)*Init2_Adj+0.5*LatMax*Term_Exit); 

load('ValidationSet.mat');

[V_MinimumRadius,MinRadiusIndx]=min(V_SampleRadius);
V_V0 = V_SampleSpeed(1);
V_IdealV_Final = 3.6*sqrt(LatMax*V_MinimumRadius);
DynamicArea = V_V0/3.6-V_IdealV_Final/3.6 -StaticArea;
V_Adj_Term =  DynamicArea/LatMax;
MinimumRadiusTime = V_SampleTime(MinRadiusIndx);







V_ExitTime_TerminationSection = V_SampleTime(MinRadiusIndx)+1;
V_InitTime_TerminationSection = V_ExitTime_TerminationSection-Term_Exit;
V_InitTime_AdjustmentSection = V_InitTime_TerminationSection - V_Adj_Term;
V_InitTime_InitialSection2 = V_InitTime_AdjustmentSection -Init2_Adj;
V_InitTime_InitialSection = V_InitTime_InitialSection2 - Init1_Init2;
V_TimingParameters_t = [V_InitTime_InitialSection, V_InitTime_InitialSection2,V_InitTime_AdjustmentSection, V_InitTime_TerminationSection, V_ExitTime_TerminationSection];
V_Accel_Timing = [0,-AccelInit2,-LatMax,-LatMax,0];

figure(21)
set(gcf, 'color','w','Units', 'Normalized', 'OuterPosition', [0 0.05 1 0.8]);
subplot(1,1,1)
plot(V_SampleTime,V_SampleLongAccel,'color',GP(9,:),'linewidth',5);
hold on;
area(V_TimingParameters_t,V_Accel_Timing,'FaceColor',PP(4,:),'EdgeColor',PP(4,:),'linewidth',2,'linestyle',':','FaceAlpha',0.3);


title('Longitudinal Acceleration (ValidationSet)','fontsize',FontSize);
grid on;
xlabel('Roadway position [m]','fontsize',FontSize);
ylabel('Acceleration [m/s^2]','fontsize',FontSize);


%%
% %%
% pltIndxRoad = 1 : length(flt_curvature);
% pltIndxRoad = Sampling*pltIndxRoad;
% xlimIndex=[4850,5300];
% xlimIndex=[6700,7400];
% xlimIndex=[0,22000];
% % xlimIndex=[0,22000];
% FontSize = 13;
% figure(18)
% set(gcf, 'color','w','Units', 'Normalized', 'OuterPosition', [0 0.05 0.4 0.95]);
% subplot(4,1,1)
% plot(pltIndxRoad,sn_Ego_Accel,'color',YP(9,:),'linewidth',2);
% hold on;
% title('Longitudinal Acceleration','fontsize',FontSize);
% grid on;
% xlabel('Roadway position [m]','fontsize',FontSize);
% ylabel('Acceleration [m/s^2]','fontsize',FontSize);
% xlim(xlimIndex);
% subplot(4,1,2)
% plot(pltIndxRoad,sn_Lat_Accel,'color',YP(5,:),'linewidth',2);
% hold on;
% title('Lateral Acceleration','fontsize',FontSize);
% grid on;
% xlabel('Roadway position [m]','fontsize',FontSize);
% ylabel('Acceleration [m/s^2]','fontsize',FontSize);
% xlim(xlimIndex);
% subplot(4,1,3)
% plot(pltIndxRoad,sn_Ego_Velocity,'color',RP(9,:),'linewidth',2);
% hold on;
% title('Speed','fontsize',FontSize);
% grid on;
% xlabel('Roadway position [m]','fontsize',FontSize);
% ylabel('Speed [km/h]','fontsize',FontSize);
% xlim(xlimIndex);
% subplot(4,1,4)
% plot(pltIndxRoad(2:length(pltIndxRoad)-1),1./Radius,'color',CP(26,:),'linewidth',2);
% % hold on;
% % plot(pltIndxRoad(2:length(pltIndxRoad)-1),1./HC_flt_radius,'g*','linewidth',4);
% % hold off;
% title('Curvature','fontsize',FontSize);
% grid on;
% % ylim([0,200]);
% xlabel('Roadway position [m]','fontsize',FontSize);
% ylabel('1/Radius [1/m]','fontsize',FontSize);
% xlim(xlimIndex);
% 
% 
% %%
% Radius_revised = [10000, Radius, 10000];
% 
% Cal_LateralAcceleration = (sn_Ego_Velocity/3.6).^2 ./ Radius_revised;
% 
% 
% figure(19)
% set(gcf, 'color','w','Units', 'Normalized', 'OuterPosition', [0 0.05 1 0.8]);
% 
% plot(Cal_LateralAcceleration,'color',CP(26,:),'linewidth',2);
% hold on;
% plot(sn_Lat_Accel,'color',CP(6,:),'linewidth',2);
% grid on;
% legend('Calculated Lateral Accel','Measured Lateral Accel');
% title('Comparison calculation with measurement');
% 
% 
