
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  This script plots the MCMC inversion results
%% 

%name of inversion (appended to output file names)
inversion_name = 'synthetic';


%%If data sets are not already loaded, uncomment lines below (modify Inpute_file.m
%script name, if necessary)

Input_file_Ustress
[data,datasig,xysites,XYsites,numdata]=LoadData(filename,datatype,origin);


%Number of burn-in samples to discard 
discardindex= 20;   




%% END OF INPUT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


DHAT_Ustress = load(['./MCMC_outputs/DHAT_Ustress_' inversion_name '.txt']);
M_Ustress = load(['./MCMC_outputs/M_Ustress_' inversion_name '.txt']);
Msig_Ustress = load(['./MCMC_outputs/Msig_Ustress_' inversion_name '.txt']);
Mstress_Ustress = load(['./MCMC_outputs/Mstress_Ustress_' inversion_name '.txt']);
Mlocked_Ustress = load(['./MCMC_outputs/Mlocked_Ustress_' inversion_name '.txt']);
Slip_Ustress = load(['./MCMC_outputs/Slip_Ustress_' inversion_name '.txt']);
logrho_Ustress = load(['./MCMC_outputs/logrho_Ustress_' inversion_name '.txt']);
logDET_Ustress = load(['./MCMC_outputs/logDET_Ustress_' inversion_name '.txt']);




figure
subplot(121)
plot(logrho_Ustress+logDET_Ustress)
xlabel('sample number')
ylabel('log probability')
subplot(122)
plot(-log10(abs(logrho_Ustress+logDET_Ustress)))
xlabel('sample number')
ylabel('-log_{10}(abs(log probability))')


M_Ustress(1:discardindex,:)=[];
Msig_Ustress(1:discardindex,:)=[];
Mstress_Ustress(1:discardindex,:)=[];
Mlocked_Ustress(1:discardindex,:)=[];
Slip_Ustress(1:discardindex,:)=[];
DHAT_Ustress(1:discardindex,:)=[];

meanSlip=mean(Slip_Ustress,1);
meanM=mean(M_Ustress,1);
meanMlocked=mean(Mlocked_Ustress,1);
meanDHAT=mean(DHAT_Ustress,1);


sigmaslip=std(Slip_Ustress); %standard deviation



%plot posterior distributions of data weights
figure
for k=1:size(Msig_Ustress,2)
    subplot(3,3,k)
    hist(Msig_Ustress(:,k),40)
    title(['Weight for data set ' num2str(k)]) 
    xlabel('standard deviation')
end

%plot posterior distributions stress components
figure
subplot(3,3,1)
hist(Mstress_Ustress(:,1),40)
title('strike-slip shear stress') 
xlabel('MPa')
subplot(3,3,2)
hist(Mstress_Ustress(:,2),40)
title('dip-slip shear stress') 
xlabel('MPa')


%plot posterior distributions of fault parameters
labels{1}='depth (km)';
labels{2}='dip (degrees)';
labels{3}='strike (degrees)';
labels{4}='east position (km)';
labels{5}='north position (km)';

figure
for k=1:5
    subplot(3,3,k)
    hist(M_Ustress(:,k),30)
    xlabel(labels{k})
end


%plot mean of slip
%construct fault patches 
pm=[];
faults=[faults_fixed(1:2)' meanM];
%specify components of slip to be calculate ([strike-slip,dip-slip,opening]) -- e.g. [0 1 0] means dip slip only
dis_geom1  = [faults, [1 1 0]];
dis_geom = movefault(dis_geom1);  % move the fault so that the coordinates of the midpoint refer to the
                                             % fault bottom as in Okada
%% Create slip patches
nhe=faults_fixed(3);
nve=faults_fixed(4);
pm1=patchfault(dis_geom(1,1:7),nhe,nve);
pm = [pm; pm1];

plotpatchslip3D_vectors(pm,meanSlip,nve);
title('mean slip distribution')
plotpatchslip3D(pm,meanSlip(1:end/2),nve);
title('mean of strike-slip component')
plotpatchslip3D(pm,sigmaslip(1:end/2),nve);
title('standard deviation of strike-slip component')
plotpatchslip3D(pm,meanSlip(1+end/2:end),nve);
title('mean of dip-slip component')
plotpatchslip3D(pm,sigmaslip(1+end/2:end),nve);
title('standard deviation of dip-slip component')

%plot mean distribution of slipping patches
plotpatchslip3D(pm,1-meanMlocked,nve)
title('probablity of a patch slipping')


%plot fit to data

%scale vectors relative to map size
for loop=1:length(numdata)
    mapscale=abs(max(XYsites{loop}(:,1))-min(XYsites{loop}(:,1)));
    D=load(filename{loop});
    figure; hold on
 
    if datatype{loop}==1
        Dhat=meanDHAT(sum(numdata(1:loop-1))+1:sum(numdata(1:loop)));
        scale=.2*mapscale/max(abs(Dhat));
        quiver(XYsites{loop}(:,1),XYsites{loop}(:,2),scale*D(:,3),scale*D(:,4),0,'b');
        quiver(XYsites{loop}(:,1),XYsites{loop}(:,2),scale*Dhat(1:2:end)',scale*Dhat(2:2:end)',0,'r');
        legend('data','model')
        title(['Fit to ' dataname{loop}])
    end
    
    if datatype{loop}==2
        Dhat=meanDHAT(sum(numdata(1:loop-1))+1:sum(numdata(1:loop)));
        scale=.1*mapscale/max(abs(Dhat));
        quiver(XYsites{loop}(:,1),XYsites{loop}(:,2),0*D(:,3),scale*D(:,3),0,'b');
        quiver(XYsites{loop}(:,1),XYsites{loop}(:,2),0*Dhat',scale*Dhat',0,'r');
        legend('data','model')
        title(['Fit to ' dataname{loop}])
    end
    
    if datatype{loop}==3
       
      Dhat=meanDHAT(sum(numdata(1:loop-1))+1:sum(numdata(1:loop)));
        subplot(121)
        scatter(XYsites{loop}(:,1), XYsites{loop}(:,2), 50,D(:,3),'filled')
        colorbar
        colormap(jet)
        subplot(122)
        scatter(XYsites{loop}(:,1), XYsites{loop}(:,2), 50,Dhat,'filled')
        colorbar
        colormap(jet)

        title(['Fit to ' dataname{loop}])

    end

end


%figure with slip distribution and data
for loop=1:length(numdata)
    mapscale=abs(max(XYsites{loop}(:,1))-min(XYsites{loop}(:,1)));
    D=load(filename{loop});
    figure; hold on
 
    if datatype{loop}==1
        Dhat=meanDHAT(sum(numdata(1:loop-1))+1:sum(numdata(1:loop)));
        scale=.2*mapscale/max(abs(Dhat));
        quiver(XYsites{loop}(:,1),XYsites{loop}(:,2),scale*D(:,3),scale*D(:,4),0,'b');
        quiver(XYsites{loop}(:,1),XYsites{loop}(:,2),scale*Dhat(1:2:end)',scale*Dhat(2:2:end)',0,'r');
        plotpatchslip3D_vectors2(pm,meanSlip,nve);
        title(['Fit to ' dataname{loop}])
    end
    
    if datatype{loop}==2
        Dhat=meanDHAT(sum(numdata(1:loop-1))+1:sum(numdata(1:loop)));
        scale=.1*mapscale/max(abs(Dhat));
        quiver3(XYsites{loop}(:,1),XYsites{loop}(:,2),0*XYsites{loop}(:,2),0*D(:,3),0*D(:,3),scale*D(:,3),0,'b');
        quiver3(XYsites{loop}(:,1),XYsites{loop}(:,2),0*XYsites{loop}(:,2),0*Dhat',0*Dhat',scale*Dhat',0,'r');
        plotpatchslip3D_vectors2(pm,meanSlip,nve);
        title(['Fit to ' dataname{loop}])
    end
    
    if datatype{loop}==3
       
        Dhat=meanDHAT(sum(numdata(1:loop-1))+1:sum(numdata(1:loop)));
        subplot(121)
        plot3k([XYsites{loop}(:,1) XYsites{loop}(:,2) 0*XYsites{loop}(:,2)],D(:,3));
        plotpatchslip3D_vectors2(pm,meanSlip,nve);
        title('data')
        subplot(122)
        plot3k([XYsites{loop}(:,1) XYsites{loop}(:,2) 0*XYsites{loop}(:,2)],Dhat);
        plotpatchslip3D_vectors2(pm,meanSlip,nve);
        title(['Fit to ' dataname{loop}])
    end

end

