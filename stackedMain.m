%clear workspace, config
close all;
clear all;
clc ;
dataSet = 'Primates'
basePath = '/home/w328li/MLDSP-desktop/samples/';
if isunix & ismac
    basePath = '/Users/wanxinli/Desktop/project/MLDSP-desktop/samples/';
end
dataSetPath = strcat(basePath, dataSet)
kVal = 9; % used only for CGR-based representations(if methodNum=1,15,16,17)
selectedFolder = dataSetPath;

% read sequences
fprintf('Reading sequences .... \n');
maxClusSize = 50000; %  0 if limit all cluster sizes by the size of smallest cluster;
[acN, Seq, numberOfClusters, clusterNames, pointsPerCluster,Fnm] = readExternsBac(dataSetPath,maxClusSize);
AcNmb = Fnm;
totalSeq = length(Seq);

% construct cgr
allCGR = cell(1,totalSeq);
for i=1:totalSeq
    ss = Seq{i};
    tCGR=zeros(2^kVal);
    for j=1:length(ss)
        sq = ss{j};
        sqSeg = regexp(sq, '[^ATCG]', 'split');
        for m=1:length(sqSeg)
            seg = sqSeg{m};
            tCGRNw=cgr(seg,'ACGT',kVal);
            tCGR=tCGR+tCGRNw;
        end
    end  
    allCGR{i}=tCGR;
end

f = cell(1, totalSeq);
lg = cell(1, totalSeq);
for i=1:totalSeq
    f{i} = fft(allCGR{i});
    lg{i} = abs(f{i});
end

% compute distance matrix
fprintf('Computing Distance matrix .... \n');
lgl = cell(1,totalSeq);
parfor i=1:totalSeq
    lgl{i} =  reshape(lg{i},1,[]);
end
lg = lgl;
fm=cell2mat(lgl(:));
disMat = f_dis(fm,'cor',0,1);
[Y,eigvals] = cmdscale(disMat,3);

% create labels
clear a;
clear s;
a=[];
for i=1:numberOfClusters
    for j=1:pointsPerCluster{i}
        a=[a; i];
    end
end

% perform classification
fprintf('Performing classification .... \n');
alabels = a;
folds=10;
if (totalSeq<folds)
    folds = totalSeq;
end
[accuracy, avg_accuracy, clNames, cMat] = classificationCode(disMat,alabels, folds, totalSeq, AcNmb);
acc = [accuracy avg_accuracy];
s.ClassifierModel=cellstr(clNames.');
s.Accuracy=cell2mat(acc).';
ClassificationAccuracyScores = struct2table(s);
disp(ClassificationAccuracyScores);

fprintf('Process completed \n')