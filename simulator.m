P = [];
SL = 2501;
dR = 1600:100:3200;
%dR = 4201;
%dR = 1600;
MINPR = [150 200];
MAXPR = [225 400];
SR = [11 20];
SR = [30 50];
close all
h1 = figure;
h2 = figure;
COMP = [];
with_ear_sigma = 20;
for sears = 1:3
    PR(1) = MINPR(1) + (MINPR(2)-MINPR(1))*rand(1);
    PR(2) = MAXPR(1) + (MAXPR(2)-MAXPR(1))*rand(1);
    
    %PR = [175 225];
    
    T_ear = PR(1) + (PR(2)-PR(1)).*rand(1);
    T = [];
    for r = 1:numel(dR)
        SL = dR(r);
        P = [];
        parfor e = 1:100
            T = normrnd(T_ear,with_ear_sigma)
            Z = zeros(1,SL);
            idx = 1:round(T):SL;
            SHIFT = round(20*rand(size(idx)));
            %SHIFT = 0;
            AMP = 3*rand(size(idx));
            %AMP = 1;
            Z(idx + SHIFT) = AMP;
            Z = Z(1:SL);
            SIGMA = SR(1) + (SR(2)-SR(1)).*rand(1);
            Zf = imfilter(Z,fspecial('gaussian',[51 51],SIGMA),'replicate');
            %Zf = Z;
            NOISE = normrnd(0,.1,size(Zf));
            %NOISE = 0;
            Zf = Zf + NOISE;
            
            P(e,:) = abs(fft(Zf));
        end
        uP = mean(P,1)';
        %h = fspecial('average',[5 1]);
        %uP = imfilter(uP,h,'replicate');
    
        [T(r)] = findT(uP,SL,400);
    end
    close all
    
    figure(h1);
    plot(uP(1:100));
    title([num2str(mean(T)) '--' num2str(mean(T_ear))]);
    COMP(sears,:) = [mean(T) T_ear];
    figure(h2)
    plot(COMP(:,1),COMP(:,2),'.')
    title(corr(COMP(:,1),COMP(:,2)))
    drawnow
    
end
%%
close all
Z = zeros(1,3000);
idx = 1:17:3000;
Z(idx) = 1;
aZ = abs(fft(Z))
plot(aZ)
%% raw
KLmin = [200 225];
KLmax = [250 350];
kH = [.56 .08];
kE = [0 .08];
kEL = [.0 .08];         % shape parameter for kernel function
close all
dR = 1600:100:3200;
%dR = [2400 3200];
dR = 1200:25:1600;
gL = [13.6 1.79];       % gap length
gH = [.33 .121];        % delta gap height
kD = [0 .2 .1 .5];      % kernel depression
h1 = figure;
damping = [.9 .1];

%dampen = [.1 1];
cV = [];
DATA = [];
for V = 10%:5:100
    MES = [];
    for ear = 1:100
        T = [];
        KLm = KLmin(1) + (KLmin(2)-KLmin(1)).*rand(1);
        KLM = KLmax(1) + (KLmax(2)-KLmax(1)).*rand(1);    
        kL(1) = .5*(KLM+KLm);    
        kL(2) = V;
        % loop over windows sizes
        for r = 1:numel(dR)
            SL = 3200;
            SL = dR(r);        
            pfftKR = [];
            parfor samp = 1:100
                KR = [];
                while numel(KR) < SL                
                    KR = [KR kerSim_0(kL,kH,kEL,kE,gL,gH,kD,damping)];
                end
                KR = KR(1:SL);    
                DATA = [DATA KR];
                KR = imfilter(KR,fspecial('average',[1 41]),'replicate');                            
                dKR = gradient(KR);
                dKR = imfilter(dKR,fspecial('gaussian',[1 41],8),'replicate');
                pos = dKR > 0;
                %plot(dKR.*pos);
                %drawnow
                sig = dKR.*pos;
                sig = sig - mean(sig);
                pfftKR(samp,:) = abs(fft(sig));
            end


            KR = [];
            while numel(KR) < SL                
                KR = [KR kerSim_0(kL,kH,kEL,kE,gL,gH,kD,damping)];
            end
            KR = KR(1:SL);  
            sKR = imfilter(KR,fspecial('average',[1 41]),'replicate');  
            %csvwrite('/mnt/spaldingdata/nate/communications/papers/maizeEarScan/figures/modelData/kernelRowModel.csv',KR);
            %csvwrite('/mnt/spaldingdata/nate/communications/papers/maizeEarScan/figures/modelData/smoothkernelRowModel.csv',sKR);
            %close all
            uSIG = mean(pfftKR,1);
            %csvwrite('/mnt/spaldingdata/nate/communications/papers/maizeEarScan/figures/modelData/uFFT.csv',uSIG');
            %uSIG = imfilter(uSIG,fspecial('average',[1 5]),'replicate');
            figure(h1);
            subplot(1,3,1);        
            plot(KR);
            hold on
            plot(sKR,'r')
            hold off
            axis([0 numel(KR) 0 1]);
            title('Gray Scale Profile Example');
            subplot(1,3,2);
            plot(uSIG(1:50));
            title('Average FFT of Gray Scale Profile');
            %figure;
            %plot(uSIG);
            drawnow
            T(r) = findT(uSIG',SL,400);
        end        
        %title([num2str(TE) '--' num2str(mean(T))]);
        MES(ear,1) = mean(T);
        %MES(ear,2) = kL(1) + mean(gL);
        MES(ear,2) = kL(1) + wblstat(gL(1),gL(2));
        ear
        %close all
        figure(h1);
        subplot(1,3,3);
        scatter(MES(:,1),MES(:,2),'.')
        title(['Corr of trials--' num2str(corr(MES(:,1),MES(:,2))) '--' num2str(V)])
        drawnow
    end
    cV = [cV corr(MES(:,1),MES(:,2))];
end
csvwrite('/mnt/spaldingdata/nate/communications/papers/maizeEarScan/figures/modelData/corr_100.csv',MES);
%% match histograms of model and raw data

while numel(KR) < SL                
    KR = [KR kerSim_0(kL,kH,kEL,kE,gL,gH,kD)];
end
KR = KR(1:SL); 

%%
scV = cV;
%% look at histogram of raw data
rD = [];
for e = 1:20
    rD = [rD I{e}(:)];
end

