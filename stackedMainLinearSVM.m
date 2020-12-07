%clear workspace, config
close all;
clear all;
clc ;

dataSet = 'g__C941/o__Bacteroidales'
splitDataSet = split(dataSet, '/');
parentSet = splitDataSet{1,:};
childSet = splitDataSet{2,:};
% testSet = ''
testSet = 'MAG/g__C941/'
splitTestSet = split(testSet, '/');
magSet = splitTestSet{2,:};

basePath = '/home/w328li/MLDSP/samples/';
if isunix & ismac
    basePath = '/Users/wanxinli/Desktop/project/MLDSP/samples/';
end
methodNum = 1
dataSetPath = strcat(basePath, dataSet)
testSetPath = strcat(basePath, testSet)
kVal = 7; % used only for CGR-based representations(if methodNum=1,15,16,17)
selectedFolder = dataSetPath;

% read sequences
fprintf('Reading sequences .... \n');
maxClusSize = 50000; %  0 if limit all cluster sizes by the size of smallest cluster;
[acN, Seq, numberOfClusters, clusterNames, pointsPerCluster,Fnm] = readExternsBac(dataSetPath,maxClusSize);
AcNmb = Fnm;
totalSeq = length(Seq);
[maxLen, minLen, meanLen, medLen] = lengthCalc(Seq);

% construct single-stranded cgr
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
            segComp = seqrcomplement(seg);
            tCGRNwComp = cgr(segComp,'ACGT',kVal);    
            tCGR = tCGR+tCGRNw+tCGRNwComp;
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

% disp(disMat);

clusterStart = pointsPerCluster;
for i=1:length(clusterStart)
    if i==1
        clusterStart{i} = 1;
    else
        clusterStart{i} = clusterStart{i-1}+pointsPerCluster{i-1};
    end
end

for i=1:length(clusterStart)
    for j=i:length(clusterStart)
        pdisMat = disMat(clusterStart{i}:(clusterStart{i}+pointsPerCluster{i}-1), clusterStart{j}:(clusterStart{j}+pointsPerCluster{j}-1));
        pdisMat = pdisMat';
        pdisMat = pdisMat(:)';
        fprintf("%s and %s avg dissimilarity is: %f\n", clusterNames{i}, clusterNames{j}, nanmean(pdisMat))
    end
end

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
if (strcmp(testSet, ''))
    [accuracy, avg_accuracy, clNames, cMat] = classificationCode(disMat,alabels, folds, totalSeq, AcNmb);
    acc = [accuracy avg_accuracy];
    s.ClassifierModel=cellstr(clNames.');
    s.Accuracy=cell2mat(acc).';
    ClassificationAccuracyScores = struct2table(s);
    disp(ClassificationAccuracyScores);
end

if (~strcmp(testSet,''))
    classifyTestSeqExternMisListLinearSVM(testSetPath, methodNum,disMat,alabels,lg,clusterNames,kVal,medLen, clusterStart, dataSet, magSet)
end


fprintf('Process completed \n')
