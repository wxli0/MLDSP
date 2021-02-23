function [pMat,mList1,mList2,mList3] = classifyTestSeqExternMisList(AcNmbTest,numMethod,disMat,alabels,SeqTest,lg,clusterNames,kVal,mLen, clusterStart, dataSet)
    numTestSeq = length(SeqTest);
    nSeq = cell(1,numTestSeq);
    fVec = cell(1,numTestSeq);
    lgNew = cell(1,numTestSeq);
    totalSeq = length(disMat);
    for r=1:numTestSeq
        Sq = upper(SeqTest{r});
        
        if(numMethod==1 || numMethod>=15)             
            if(numMethod == 1)
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
            elseif(numMethod==15) 
                Sq = regexprep(Sq,'G','A');
                Sq = regexprep(Sq,'C','T'); 
                nSeq{r} = cgr(Sq,'ACGT',kVal);
                lgN = abs(fft(nSeq{r}));
                lgNew{r} = reshape(lgN,1,[]); 
            else
                cgrLen = power(2,kVal);
                Sq = regexprep(Sq,'G','A');
                Sq = regexprep(Sq,'C','T'); 
                nmVal = cgr(Sq,'ACGT',kVal);
                nSeq{r} = nmVal(cgrLen,1:cgrLen);  
                lgNew{r} = abs(fft(nSeq{r}));
            end              
        else    
            I = mLen-length(Sq);
            if(I<0)
                Sq=Sq(1:mLen);
            end                
            if(numMethod==2) 
                nSq = numMappingPP(Sq);
            elseif(numMethod==3)
                nSq = numMappingInt(Sq);
            elseif(numMethod==4)
                nSq = numMappingIntN(Sq);
            elseif(numMethod==5)
                nSq = numMappingReal(Sq);
            elseif(numMethod==6)
                nSq = numMappingDoublet(Sq);
            elseif(numMethod==7)
                nSq = numMappingCodons(Sq);
            elseif(numMethod==8)
                nSq = numMappingAtomic(Sq);
            elseif(numMethod==9)
                nSq = numMappingEIIP(Sq);
            elseif(numMethod==10)
                nSq = numMappingAT_CG(Sq);
            elseif(numMethod==11)
                nSq = numMappingJustA(Sq);
            elseif(numMethod==12)
                nSq = numMappingJustC(Sq);
            elseif(numMethod==13)
                nSq = numMappingJustG(Sq);
            elseif(numMethod==14) 
                nSq = numMappingJustT(Sq);          
            end
            
            if(I>0)
               nsTemp = wextend('1','asym',nSq,I);
               nSq = nsTemp((I+1):length(nsTemp)); 
            end
            
%             I = mLen-length(nSq);
%             if(I>0)
%                 nsTemp = wextend('1','asym',nSq,I);
%                 nsNew = nsTemp((I+1):length(nsTemp));
%             elseif(I<0)
%                 nsNew=nSq(1:mLen);
%             else
%                 nsNew = nSq;
%             end
%             nSeq{r} = nsNew;  
            
            nSeq{r} = nSq; 	
		    lgNew{r} = abs(fft(nSeq{r}));  
        end
%         fNew = fft(nSeq{r});    
%         lgNew = abs(fNew); 
%         testV = [];
%         for d=1:length(lg)
%             aa=(1-corrcoef(lgNew,lg{d}))/2;
%             testV = [testV aa(1,2)];
%         end
%         fVec{r} = testV;
    end
    lgg = [lg lgNew];
    fmm=cell2mat(lgg(:));
    disMatWithTest = f_dis(fmm,'cor',0,1);
    sId = totalSeq+1;
    eId = length(disMatWithTest);
    disMatTrainTest = disMatWithTest(sId:eId,1:totalSeq);

    % [status, msg, msgID] = mkdir(strcat('outputs/',dataSet))
    % [status, msg, msgID] = mkdir(strcat('outputs/',dataSet,'histograms/'))
    for i = 1:numTestSeq
        for j=1:length(clusterStart)
            endIndex = totalSeq;
            if (j ~= length(clusterStart))
                endIndex = clusterStart{j+1}-1;
            end
            pdisMat = disMat(i, clusterStart{j}:endIndex);
            pdisMat = pdisMat';
            pdisMat = pdisMat(:)';
            % % disp(pdisMat)
            % 
            % f=figure;
            % histogram(pdisMat, 'Normalization', 'probability');
            % saveas(f, strcat('outputs/',dataSet,'histograms/',string(i),"-",clusterNames{j},'.png'))
            fprintf("Seq %d and %s avg dissimilarity is: %f\n", i, clusterNames{j}, mean(pdisMat));
        end
    end
    
    cn = unique(alabels);
    %discriminant
    cModel1 = fitcdiscr(...
            disMat, ...
            alabels, ...
            'DiscrimType', 'linear', ...
            'Gamma', 0, ...
            'FillCoeffs', 'off', ...
            'ClassNames', cn);

    %Linear SVM
    template = templateSVM(...
                'KernelFunction', 'linear', ...
                'PolynomialOrder', [], ...
                'KernelScale', 'auto', ...
                'BoxConstraint', 1, ...
                'Standardize', true);
    cModel2 = fitcecoc(...
                disMat, ...
                alabels, ...
                'Learners', template, ...
                'Coding', 'onevsall', ...
                'ClassNames', cn);
  
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



       

    
    mList1=cell(2,numTestSeq);
    mList2=cell(2,numTestSeq);
    mList3=cell(2,numTestSeq);
     
    pMat = zeros(3,length(clusterNames));
    fprintf("numTestSeq is: %d\n", numTestSeq);
    score1Matrix = zeros(numTestSeq, length(clusterNames)+1);
    score2Matrix = zeros(numTestSeq, length(clusterNames)+1);
    score3Matrix = zeros(numTestSeq, length(clusterNames)+1);
    if (length(clusterNames)==2):
        score1Matrix = zeros(numTestSeq, length(clusterNames));
        score2Matrix = zeros(numTestSeq, length(clusterNames));
        score3Matrix = zeros(numTestSeq, length(clusterNames));

    for s=1:numTestSeq
        testV = disMatTrainTest(s,1:totalSeq);
        [clabel1, score1, ~] = predict(cModel1, testV); 
        pMat(1,clabel1)= pMat(1,clabel1)+1;
        [clabel2, ~, pbscore2] = predict(cModel2,testV);   
        fprintf("pbscore2 is:\n")
        disp(pbscore2)
        fprintf("clabel2 is:\n")
        disp(clabel2)
        pMat(2,clabel2)= pMat(2,clabel2)+1;
        [clabel3, ~, ~, score3] = predict(cModel3,testV);    
        pMat(3,clabel3)= pMat(3,clabel3)+1;

        mList1{1,s}=AcNmbTest{s};
        mList2{1,s}=AcNmbTest{s};
        mList3{1,s}=AcNmbTest{s};

        mList1{2,s}=clusterNames{clabel1};
        mList2{2,s}=clusterNames{clabel2};
        mList3{2,s}=clusterNames{clabel3};

        score1 = [score1 clabel1];
        score1Matrix(s,:) = score1;
        score2 = [pbscore2 clabel2];
        score2Matrix(s,:) = score2;
        score3 = [score3 clabel3];
        score3Matrix(s,:) = score3;

        fprintf("clabel1 = %d\n", clabel1);
        fprintf("score1 = %s\n", num2str(score1));
        fprintf("clabel2 = %d\n", clabel2);
        fprintf("pbscore2 = %s\n", num2str(score2));
        fprintf("clabel3 = %d\n", clabel3);
        fprintf("score3 = %s\n", num2str(score3));
        fprintf("clabel4 = %d\n", clabel4);

        fprintf("%d,%d,%d\n", clabel1, clabel2, clabel3)
    end   

    for i=1:length(clusterNames)
        clusterNames{i} = [num2str(i) '-' clusterNames{i}]
    end
    disp(clusterNames)
    header = [clusterNames, 'prediction']

    fprintf("score2Matrix is \n");
    disp(score2Matrix)
    T1 = array2table(score1Matrix,'VariableNames',header)
    T2 = array2table(score2Matrix,'VariableNames',header, 'RowNames', AcNmbTest)
    T3 = array2table(score3Matrix,'VariableNames',header)

    writetable(T1, strcat("outputs/", dataSet, ".xls"), 'Sheet', 'linear-discriminant-score');  
    writetable(T2, strcat("outputs/", dataSet, ".xls"), 'Sheet', 'linear-svm-score');  
    writetable(T3, strcat("outputs/", dataSet, ".xls"), 'Sheet', 'quadratic-svm-score');  

end

