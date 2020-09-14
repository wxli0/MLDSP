%clear workspace, config
close all;
clear all;
clc ;
dataSet = 'Primates'
testSet = 'Haplorrhini'
basePath = '/home/w328li/MLDSP-desktop/samples/';
if isunix & ismac
    basePath = '/Users/wanxinli/Desktop/project/MLDSP-desktop/samples/';
end
methodNum = 1
dataSetPath = strcat(basePath, dataSet)
testSetPath = strcat(basePath, testSet)
kVal = 9; % used only for CGR-based representations(if methodNum=1,15,16,17)
selectedFolder = dataSetPath;

% read sequences
fprintf('Reading sequences .... \n');
maxClusSize = 50000; %  0 if limit all cluster sizes by the size of smallest cluster;
[acN, Seq, numberOfClusters, clusterNames, pointsPerCluster,Fnm] = readExternsBac(dataSetPath,maxClusSize);
AcNmb = Fnm;
totalSeq = length(Seq);
[maxLen, minLen, meanLen, medLen] = lengthCalc(Seq);

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
if (strcmp(testSet, ''))
    [accuracy, avg_accuracy, clNames, cMat] = classificationCode(disMat,alabels, folds, totalSeq, AcNmb);
    acc = [accuracy avg_accuracy];
    s.ClassifierModel=cellstr(clNames.');
    s.Accuracy=cell2mat(acc).';
    ClassificationAccuracyScores = struct2table(s);
    disp(ClassificationAccuracyScores);
end

if (~strcmp(testSet,''))
    minSeqLen = 0
    maxSeqLen = 0
    seqToTest = 0
    [tab,mList1,mList2,mList3,mList4,mList5,mList6]=testingExternMisList(testSetPath,methodNum,disMat,alabels,lg,clusterNames,kVal,medLen,minSeqLen,maxSeqLen,seqToTest);
    tabc=table2cell(tab);
    tabc=[tab.Properties.VariableNames;tabc];
    tabc = string(tabc);
    writematrix(tabc,'testingMatrix4.xlsx');
    writematrix(string(mList1(1)),'testingMatrix4.xlsx','Sheet',2);  
    writematrix(string(mList2(1)),'testingMatrix4.xlsx','Sheet',3);  
    writematrix(string(mList3(1)),'testingMatrix4.xlsx','Sheet',4);  
    writematrix(string(mList4(1)),'testingMatrix4.xlsx','Sheet',5);  
    writematrix(string(mList5(1)),'testingMatrix4.xlsx','Sheet',6); 
    writematrix(string(mList6(1)),'testingMatrix4.xlsx','Sheet',7);  
end


fprintf('Process completed \n')
