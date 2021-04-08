function [pMat,mList3] = classifyTestSeqExternMisList(AcNmbTest,Fnm, disMat,alabels,SeqTest,lg,clusterNames,kVal,clusterStart, dataSet)
    numTestSeq = length(SeqTest);
    nSeq = cell(1,numTestSeq);
    fVec = cell(1,numTestSeq);
    lgNew = cell(1,numTestSeq);
    totalSeq = length(disMat);
    for r=1:numTestSeq
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
  
    %QSVM   
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


    
    mList3=cell(2,numTestSeq);
     
    pMat = zeros(3,length(clusterNames));
    fprintf("numTestSeq is: %d\n", numTestSeq);
    score3Matrix = zeros(numTestSeq, length(clusterNames)+1);

    for s=1:numTestSeq
        testV = disMatTrainTest(s,1:totalSeq);
        [clabel3, ~, ~, score3] = predict(cModel3,testV);    
        pMat(3,clabel3)= pMat(3,clabel3)+1;

        mList3{1,s}=AcNmbTest{s};

        mList3{2,s}=clusterNames{clabel3};

        score3 = [score3 clabel3];
        score3Matrix(s,:) = score3;

        fprintf("%d\n",  clabel3)
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

    writetable(T3, strcat("outputs_cov121/test-", dataSet, ".xlsx"), 'WriteRowNames',true, 'Sheet', 'quadratic-svm-score');  

end

