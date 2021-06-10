function [] = stackedMain(dataType, dataSet, testSet)
    %clear workspace, config
    close all;
    % clear all;
    clc ;
    if nargin < 3
        testSet=''
    end

    ver_gtdb = 'r202';

    basePath = ""
    if strcmp(dataType, 'GTDB')
        basePath = strcat('/mnt/sda/MLDSP-samples-', ver_gtdb, "/");
    elseif strcmp(dataType, 'HGR')
        basePath = strcat("/mnt/sda/DeepMicrobes-data/labeled_genome-", ver_gtdb, "/");
    end

    dataSetPath = strcat(basePath, dataSet)
    testSetPath = strcat(basePath, testSet)
    kVal = 7; 
    selectedFolder = dataSetPath;

    % read sequences
    fprintf('Reading sequences .... \n');
    maxClusSize = 50000; %  0 if limit all cluster sizes by the size of smallest cluster;
    [acN, Seq, numberOfClusters, clusterNames, pointsPerCluster,Fnm] = readExternsBac(dataSetPath,maxClusSize);
    AcNmb = Fnm;
    totalSeq = length(Seq);

    % construct double-stranded cgr
    fprintf('Generating CGRs.... \n');
    allCGR = cell(1,totalSeq);

    fprintf("totalSeq is: %d\n", totalSeq)
    parfor i=1:totalSeq
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

    fprintf('Computing disMat .... \n');
    lgl = cell(1,totalSeq);
    parfor i=1:totalSeq
        lgl{i} =  reshape(lg{i},1,[]);
    end
    lg = lgl;
    fm=cell2mat(lgl(:));
    disMat = f_dis(fm,'cor',0,1);

    clusterStart = pointsPerCluster;
    for i=1:length(clusterStart)
        if i==1
            clusterStart{i} = 1;
        else
            clusterStart{i} = clusterStart{i-1}+pointsPerCluster{i-1};
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
    folds=5;
    if (totalSeq<folds)
        folds = totalSeq;
    end
    if (strcmp(testSet, ''))
        [accuracy, avg_accuracy, clNames, cMat] = classificationCode(dataType, disMat, alabels, folds, totalSeq, AcNmb, clusterNames, dataSet, ver_gtdb);
        acc = [accuracy avg_accuracy];
        s.ClassifierModel=cellstr(clNames.');
        s.Accuracy=cell2mat(acc).';
        disp(cellstr(clNames.'))
        disp(acc)
        ClassificationAccuracyScores = struct2table(s);
        disp(ClassificationAccuracyScores);
    end

    if (~strcmp(testSet,''))
        minSeqLen = 0
        maxSeqLen = 0
        [mList3]=testingExternMisList(dataType, testSetPath,disMat,alabels,lg,clusterNames,kVal, maxClusSize, clusterStart, dataSet, minSeqLen,maxSeqLen, ver_gtdb);
    end


    fprintf('Process completed \n')
