function [pMat,mList2] = classifyTestSeqExternMisList(testPath, numMethod,disMat,alabels,lg,clusterNames,kVal,mLen, clusterStart, dataSet, magSet)
    [AcNmbTest,SeqTest, pnts,Fnm] = readTestingExternSet(testPath,minSeqLen,maxSeqLen,maxClusSize);

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

    for i = 1:numTestSeq
        for j=1:length(clusterStart)
            endIndex = totalSeq;
            if (j ~= length(clusterStart))
                endIndex = clusterStart{j+1}-1;
            end
            pdisMat = disMat(i, clusterStart{j}:endIndex);
            pdisMat = pdisMat';
            pdisMat = pdisMat(:)';

            fprintf("Seq %d and %s avg dissimilarity is: %f\n", i, clusterNames{j}, mean(pdisMat));
        end
    end
    
    cn = unique(alabels);

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
  
    
    mList2=cell(2,numTestSeq);
      
    pMat = zeros(6,length(clusterNames));
    fprintf("numTestSeq is: %d\n", numTestSeq);

    score2Matrix = zeros(numTestSeq, length(clusterNames)+1);

    for s=1:numTestSeq
        testV = disMatTrainTest(s,1:totalSeq);

        [clabel2, ~, pbscore2] = predict(cModel2,testV);   
        
        mList2{1,s}=AcNmbTest{s};
        mList2{2,s}=clusterNames{clabel2};

        score2 = [pbscore2 clabel2];
        score2Matrix(s,:) = score2;
        
        fprintf("clabel2 = %d\n", clabel2);
    end   

    for i=1:length(clusterNames)
        clusterNames{i} = [num2str(i) '-' clusterNames{i}]
    end
    disp(clusterNames)
    header = [clusterNames, 'prediction']
    T2 = array2table(score2Matrix,'VariableNames',header)
    writetable(T2, strcat("outputs/", dataSet, ".xls"), 'Sheet', strcat(magSet, '-linear-svm-pbscore'));  

end

