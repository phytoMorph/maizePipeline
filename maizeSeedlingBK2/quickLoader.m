FilePath = '/mnt/spaldingdata/nate/mirror_images/maizeData/hirsc213/return/seedlingData/output/';
FileList = {};
FileExt = {'csv'};
FileList = gdig(FilePath,FileList,FileExt,1);
%% treatment scan
key = 'Treatment';
keyID = 'PictureDay';
pKey = 'Phenotype';
clear S
S.hello = 0;
for e = 1:numel(FileList)
    [v] = keyLookup(FileList{e},key)
    id = str2num(keyLookup(FileList{e},keyID));
    pid = keyLookup(FileList{e},pKey);
    v = strrep(v,' ','');
    v = strrep(v,'7','');
    v = strrep(v,'11','');
    if ~isempty(v)
        if strcmp(pid,'PlantHeight')
            data = mean(csvread(FileList{e}));
            if numel(data) == 1
                if ~isfield(S,(v))
                    S.(v) = {};
                end
                if numel(S.(v)) < id
                    S.(v){id} = [];
                end
                S.(v){id} = [S.(v){id};data];
                %waitforbuttonpress
            end
        end
    end
    e
    numel(FileList)
end
%% treatement scan part two
close all
u = [];
s = [];
for e = 1:21
    u(1,e) = mean(S.Control{e});
    u(2,e) = mean(S.Cstressday{e});
    s(1,e) = std(S.Control{e})*numel(S.Control{e})^-.5;
    s(2,e) = std(S.Cstressday{e})*numel(S.Cstressday{e})^-.5;
end
errorbar(u',s');
%% find unique types
key = {};
for e = 1:numel(FileList)
    try
        [p,nm,ext] = fileparts(FileList{e});
        n = strfind(nm,'}');
        key{e} = nm(1:n(7));
    catch ME
        if ~isempty(strfind(FileList{e},'.txt'))
            FileList{e}
        end
        [p,nm,ext] = fileparts(FileList{e});
        ext
        key{e} = 'NO KEY';
    end
end
UQ = unique(key);

%%
close all
h1 = figure;
h2 = figure;
for u = 1:numel(UQ)
    try
       
        %searchString = '{Plot_9}{Experiment_1}{Planted_2-15-2016}{SeedSource_BAM29-8}{SeedYear_2014}{Genotype_Mo17}{Treatment_Control}';
        searchString = UQ{u};
        %searchString = '{Plot_40}{Experiment_3}{Planted_2-22-16}{SeedSource_BAM7-3}{SeedYear_2014}{Genotype_B73}{Treatment_7C stress day 11}';
        H = [];
        DBM = [];
        pid = '';
        fprintf(['Searching']);
        for e = 1:numel(FileList)
            [p,n,ext] = fileparts(FileList{e});
            fidx = strfind(n,searchString);
            if ~isempty(fidx)
                pid = keyLookup(FileList{e},'Plot');
                didx = strfind(n,'{PlantNumber_All}{Phenotype_PlantHeight}');
                if ~isempty(didx)
                    gidx = strfind(n,'{PictureDay_');
                    hidx = strfind(n(gidx(1):end),'}');
                    kidx = strfind(n(gidx(1):end),'_');
                    data = csvread(FileList{e});
                    idx = str2num(n((kidx(1)+gidx(1)):(hidx(1)+gidx(1)-2)))-3;
                    H(idx,:) = data;
                end
                
                didx = strfind(n,'{PlantNumber_All}{Phenotype_DigitalBioMass}');
                if ~isempty(didx)
                    gidx = strfind(n,'{PictureDay_');
                    hidx = strfind(n(gidx(1):end),'}');
                    kidx = strfind(n(gidx(1):end),'_');
                    data = csvread(FileList{e});
                    idx = str2num(n((kidx(1)+gidx(1)):(hidx(1)+gidx(1)-2)))-3;
                    DBM(idx,:) = data;
                end
                fprintf(['.']);
                if mod(e,30) == 0
                     fprintf(['\n']);
                end 
            end
        end
        
        
        if all(H(:,1))~=0
            break
        end
        %H(any(H==0,2),:) = [];
        figure(h1);
        plot(H)
        
        figure(h2)
        plot(DBM);
        title(num2str(u))
        drawnow
        u
        numel(UQ)
        title(pid)
        waitforbuttonpress
    catch ME
        ME
        FileList{e}
    end
end
%%
