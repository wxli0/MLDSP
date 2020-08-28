% ML-DSP
% the main program that user needs to run for the results.
% default dataSet is Primates
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Gurjit Singh Randhawa  %
% Department of Computer Science,%
% Western University, Canada     %
% email: grandha8@uwo.ca         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%clear workspace
close all;
clear all;
testSetName = 'Primates';
methodNum=1; %change method number referring the variable above (between 1 and 16)
two_fragments = false;

clc ;
basePath = '/home/w328li/MLDSP-desktop/samples/';
if isunix
    basePath = '/Users/wanxinli/Desktop/project/MLDSP-desktop/samples/';
end
dataSet = strcat(basePath, testSetName);
testingSet = 'NoData';% change to 'NoData' if there is no testing set
seqToTest=0; % 0 to test all sequences, or any value upto number of available sequences
minSeqLen = 0;    % e.g. 50000 shorter sequences will be omited, change to 0 for considering shorter sequences
maxSeqLen = 0; % todo: check pruned sequence length, start position, only ACGT
fragsPerSeq = 1; %e.g. 3 shorter sequences will be considered as they are, multiple non-overlapping fragments will be used for longer sequences 

%select method
methodsList = {'CGR(ChaosGameRepresentation)','Purine-Pyrimidine','Integer','Integer (other variant)','Real','Doublet','Codons','Atomic','EIIP','PairedNumeric','JustA','JustC','JustG','JustT','PuPyCGR','1DPuPyCGR'};
kVal = 9; % used only for CGR-based representations(if methodNum=1,15,16)

selectedFolder = dataSet;
fprintf('Reading sequences .... \n');%load('Bac2500seq.mat');

%**********cluster size options*****
%run the following with a limit on the cluster size (randomly select the sequences)
%maxClusSize = 0 limit all cluster sizes by the size of smallest cluster;
%(removing smaller sequences may change the cluster size later)
%otherwise reduce the size of larger clusters by the assigned value
maxClusSize = 5000;
[AcNmb, Seq, numberOfClusters, clusterNames, pointsPerCluster,Fnm] = readExterns(dataSet,maxClusSize)
msLblReq = 0;

%***********************************
%preprocess data
fprintf('Preprocessing data .... \n');
[Seq, AcNmb, pointsPerCluster, totalSeq] = preprocessData(Seq,AcNmb,numberOfClusters,pointsPerCluster,minSeqLen,maxSeqLen,fragsPerSeq);

%calculate length stats
[maxLen, minLen, meanLen, medLen] = lengthCalc(Seq);

%numerical sequences, length normalized by median length
%code can be modified to use other length stats for length normalization
mLen = medLen;
nmValSH=cell(1,totalSeq);
f=cell(1,totalSeq);
lg=cell(1,totalSeq);

fprintf('Generating numerical sequences, applying DFT, computing magnitude spectra .... \n');

if(methodNum==1 || methodNum==15)    
    parfor a = 1:totalSeq
        sq = upper(Seq{a});
        if(methodNum==15)            
            sq = regexprep(sq,'G','A');
            sq = regexprep(sq,'C','T');       
        end
        nsNew = cgr(sq,'ACGT',kVal);
        nmValSH{a} =  nsNew;
        f{a} = fft(nsNew);
        lg{a} = abs(f{a});
    end

    %distance calculation by Pearson correlation coefficient
    fprintf('Computing Distance matrix .... \n');
    lgl = cell(1,totalSeq);
    parfor i=1:totalSeq
        lgl{i} =  reshape(lg{i},1,[]);      
    end
    lg = lgl;
    fm=cell2mat(lgl(:));
    disMat = f_dis(fm,'cor',0, 1); 
else
    if(methodNum==16)
        cgrLen = power(2,kVal);
        f=cell(1,totalSeq);
        lg=cell(1,totalSeq);
        parfor a = 1:totalSeq
            sq = upper(Seq{a});
            sq = regexprep(sq,'G','A');
            sq = regexprep(sq,'C','T'); 
            nmVal = cgr(sq,'ACGT',kVal);
            nmValSH{a} = nmVal(cgrLen,1:cgrLen);  
            f{a} = fft(nmValSH{a});
            lg{a} = abs(f{a});
        end             
    else
        [ f, lg, nmValSH ] = oneDnumRepMethods(Seq, methodNum, mLen, totalSeq);
    end
    fprintf('Computing Distance matrix .... \n');
    fm=cell2mat(lg(:));
    disMat = f_dis(fm,'cor',0,1);
end

%Multi-dimensional Scaling
fprintf('Performing Multi-dimensional scaling .... \n');
[Y,eigvals] = cmdscale(disMat,3);

%Classification Code
clear a;
clear s;

a=[];
for i=1:numberOfClusters
    for j=1:pointsPerCluster{i}
        a=[a; i];
    end
end
ATestlg = [disMat a];
rng(15,'twister');

alabels = a;
fprintf('Performing classification .... \n');
folds=10;
if (totalSeq<folds)
    folds = totalSeq;
end
tic
if(msLblReq==0)
    global falseEntries;
    falseEntries = containers.Map({'100,100'}, [[1]]);
    [accuracy, avg_accuracy, clNames, cMat] = classificationCode(disMat,alabels, folds, totalSeq);
else
    [accuracy, avg_accuracy, clNames, cMat, mls] = classificationCodeMisList(disMat,alabels, folds, totalSeq, AcNmb, clusterNames);
end
toc
acc = [accuracy avg_accuracy];
s.ClassifierModel=cellstr(clNames.');
s.Accuracy=cell2mat(acc).';
ClassificationAccuracyScores = struct2table(s)
fprintf("printing false entries\n")
disp(falseEntries)

fprintf('**** Processing completed ****\n');
