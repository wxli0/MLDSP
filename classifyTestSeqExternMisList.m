function [pMat,mList3] = classifyTestSeqExternMisList(dataType, AcNmbTest,Fnm, disMat,alabels,SeqTest,lg,clusterNames,kVal,clusterStart, dataSet)
    numTestSeq = length(SeqTest);
    nSeq = cell(1,numTestSeq);
    fVec = cell(1,numTestSeq);
    lgNew = cell(1,numTestSeq);
    totalSeq = length(disMat);
    parfor r=1:numTestSeq
        Sq = upper(SeqTest{r});
        tCGR=zeros(2^kVal);
        for j=1:length(Sq)
            sq = Sq{j};
            sqSeg = regexp(sq, '[^ATCG]', 'split');
            for m=1:length(sqSeg)
                seg = sqSeg{m};
                tCGRNw=cgr(seg,'ACGT',kVal);
                segComp = seqrcomplement(seg);
                tCGRNwComp = cgr(segComp,'ACGT',kVal);    
                tCGR = tCGR+tCGRNw+tCGRNwComp;
            end
        end 
        nSeq{r} = tCGR;
        lgN = abs(fft(nSeq{r}));
        lgNew{r} = reshape(lgN,1,[]); 
    end

    lgg = [lg lgNew];
    fmm=cell2mat(lgg(:));
    disMatWithTest = f_dis(fmm,'cor',0,1);
    sId = totalSeq+1;
    eId = length(disMatWithTest);
    disMatTrainTest = disMatWithTest(sId:eId,1:totalSeq);
    
    cn = unique(alabels);
  
    cModel3 = "";
    cn_size = size(cn);
    if cn_size(1) > 1
        %Quadratic svm  
        template = templateSVM(...
                    'KernelFunction', 'polynomial', ...
                    'PolynomialOrder', 2, ...
                    'KernelScale', 'auto', ...
                    'BoxConstraint', 1, ...
                    'Standardize', true);
        cModel3 = fitcecoc(...
                    disMat, ...
                    alabels, ...
                    'Learners', template, ...
                    'FitPosterior',true, ...
                    'Coding', 'onevsall', ...
                    'ClassNames', cn); 
    else
        cModel3 = fitcsvm(...
                    disMat, ...
                    alabels, ...
                    'KernelFunction', 'polynomial', ...
                    'PolynomialOrder', 2, ...
                    'KernelScale','auto', ...
                    'Standardize',true, ...
                    'BoxConstraint', 1, ...
                    'Standardize', true, ...
                    'OutlierFraction',0.10);
    end


    
    mList3=cell(2,numTestSeq);
     
    pMat = zeros(3,length(clusterNames));
    fprintf("numTestSeq is: %d\n", numTestSeq);
    score3Matrix = zeros(numTestSeq, length(clusterNames)+1);

    for s=1:numTestSeq
        testV = disMatTrainTest(s,1:totalSeq);
        clabel3 = "";
        score3 = "";
        if cn_size(1) > 1
            [clabel3, ~, ~, score3] = predict(cModel3,testV);    
        else
            [clabel3, score3] = predict(cModel3,testV);
        end
        pMat(3,clabel3)= pMat(3,clabel3)+1;

        mList3{1,s}=AcNmbTest{s};

        mList3{2,s}=clusterNames{clabel3};

        score3 = [score3 clabel3];
        score3Matrix(s,:) = score3;

    end   

    for i=1:length(clusterNames)
        clusterNames{i} = [num2str(i) '-' clusterNames{i}]
    end
    disp(clusterNames)
    header = [clusterNames, 'prediction']


    testFnm = [];
    for f = 1:length(Fnm)
        splitAcNum = split(Fnm{f}, '/');
        testFnm = [testFnm, splitAcNum(end)];
    end


    T3 = array2table(score3Matrix,'VariableNames',header, 'RowNames', testFnm)

    outputPath = strcat("outputs-", dataType, "-", "/test-", dataSet, ".xlsx")
    writetable(T3, outputPath, 'WriteRowNames',true, 'Sheet', 'quadratic-svm-score');  

end

