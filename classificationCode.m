function [ accuracy, avg_acc, clNames, cMat ] = classificationCode(dataType, disMat,alabels, folds, totalSeq, AcNum, clusterNames, dataSet, ver_gtdb)
    %10-fold cross validation
    %classification accuracy for 4 classifiers
    %linear-discriminant, linear svm, quadratic svm, fine knn,
    %subspace-discriminant, subspace-knn
    %only first four classifiers are used for more than 2000 sequences
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Author: Gurjit Singh Randhawa  %
    % Department of Computer Science,%
    % Western University, Canada     %
    % email: grandha8@uwo.ca         %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % seed = 98;
    % rng(seed);
    cv = cvpartition(totalSeq,'kfold',folds);
    cMat1=cell(1,folds);
    cMat2=cell(1,folds);
    cMat3=cell(1,folds);

    cn=unique(alabels);
    n = length(cn);
    ord = [];
    for xx=1:n
        ord=[ord xx];
    end

    header = [clusterNames, 'prediction', 'actual']

    for i = 1:folds
        AllTestInd = test(cv,i);
        testInd = find(AllTestInd);
        AllTrainInd = training(cv,i);
        trainInd = find(AllTrainInd);
        trainSet = disMat(trainInd,trainInd);
        testSet = disMat(testInd,trainInd);
        testAcNum = AcNum(testInd)
        testFnm = [];
        for f = 1:length(testAcNum)
            splitAcNum = split(testAcNum{f}, '/');
            testFnm = [testFnm, splitAcNum(end)];
        end 


        %QSVM   
        fprintf("training QSVM, fold %d\n", i)
        template = templateSVM(...
            'KernelFunction', 'polynomial', ...
            'PolynomialOrder', 2, ...
            'KernelScale', 'auto', ...
            'BoxConstraint', 1, ...
            'Standardize', true);
        cModel3 = fitcecoc(...
            trainSet, ...
            alabels(trainInd), ...
            'Learners', template, ...
            'FitPosterior',true, ...
            'Coding', 'onevsall', ...
            'ClassNames', cn); 
        fprintf("classifying using QSVM\n")
        [plabel3, ~, ~, score3] = predict(cModel3,testSet);    
        cMat3{i} = confusionmat(alabels(testInd),plabel3,'Order',ord);   
        score3Matrix = [score3, plabel3, alabels(testInd)]    
 
        T3 = array2table(score3Matrix,'VariableNames',header, 'RowNames', testFnm)
        outputPath = ""
        if strcmp(dataType, 'GTDB')
            outputPath = strcat("outputs-", ver_gtdb, "/train-", dataSet, ".xlsx");
        end
        writetable(T3, outputPath, 'WriteRowNames',true, 'Sheet', strcat('quadratic-svm-score', num2str(i)));  



    end

    cMat{1}=cMat3;
    
    clNames = {"QuadraticSVM", "AvgAccuracy"};
    
    accuracy=cell(1,length(cMat));
   
    for i=1:length(accuracy)
        cm = cMat{i};
        cMatrix = 0;
        for k = 1:folds
         cMatrix = cMatrix+cm{k};
        end
        if( sum(cMatrix(:))~=totalSeq)
            totalSeq
        end
        fprintf("confusion matrix for %d is:\n", i)
        disp(cMatrix)
        accuracy{i} = round((trace(cMatrix)/totalSeq)*100,1);
    end    
    avg_acc = round(sum([accuracy{:}])/length(accuracy),1);
    
end
