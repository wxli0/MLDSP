function [ accuracy, avg_acc, clNames, cMat ] = classificationCode( disMat,alabels, folds, totalSeq, AcNum, clusterNames, dataSet)
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
    header2 = [clusterNames, 'prediction', 'actual']
    if (length(clusterNames)==2)
        header2 = {'combined', 'prediction', 'actual'}
    end

    for i = 1:folds
        AllTestInd = test(cv,i);
        testInd = find(AllTestInd);
        AllTrainInd = training(cv,i);
        trainInd = find(AllTrainInd);
        trainSet = disMat(trainInd,trainInd);
        testSet = disMat(testInd,trainInd);
        testAcNum = AcNum(testInd)
        testFnm = []
        for f = 1:length(testAcNum)
            splitAcNum = split(testAcNum{f}, '/')
            testFnm = [testFnm, splitAcNum(end)]
        end

        %linear-discriminant
        fprintf("training LDA\n")
        c1 = fitcdiscr(...
        trainSet, ...
        alabels(trainInd), ...
        'DiscrimType', 'linear', ...
        'Gamma', 0, ...
        'FillCoeffs', 'off', ...
        'ClassNames', cn);
        fprintf("classifying using LDA\n")
        [plabel1, score1, ~] = predict(c1,testSet)
        cMat1{i} = confusionmat(alabels(testInd),plabel1,'Order',ord);
        score1Matrix = [score1, plabel1, alabels(testInd)]    

        %Linear SVM
        fprintf("training linear SVM \n")
        template = templateSVM(...
            'KernelFunction', 'linear', ...
            'PolynomialOrder', [], ...
            'KernelScale', 'auto', ...
            'BoxConstraint', 1, ...
            'Standardize', true);
        c2 = fitcecoc(...
            trainSet, ...
            alabels(trainInd), ...
            'Learners', template, ...
            'Coding', 'onevsall', ...
            'ClassNames', cn);

        fprintf("classifying using LSVM\n")
        [plabel2, ~, score2] = predict(c2,testSet)
        cMat2{i} = confusionmat(alabels(testInd),plabel2,'Order',ord);
        score2Matrix = [score2, plabel2, alabels(testInd)]    

        fprintf("alabels are:\n")
        disp(alabels(testInd))

        %QSVM   
        fprintf("training QSVM\n")
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
        [plabel3, ~, ~, score3] = predict(cModel3,testSet)    
        cMat3{i} = confusionmat(alabels(testInd),plabel3,'Order',ord);   
        score3Matrix = [score3, plabel3, alabels(testInd)]    
 
        T1 = array2table(score1Matrix,'VariableNames',header, 'RowNames', testFnm)
        writetable(T1, strcat("outputs/train-", dataSet, ".xls"), 'WriteRowNames',true, 'Sheet', strcat('linear-discriminant-score', num2str(i)));  

        T2 = array2table(score2Matrix,'VariableNames',header2, 'RowNames', testFnm)
        writetable(T2, strcat("outputs/train-", dataSet, ".xls"), 'WriteRowNames',true, 'Sheet', strcat('linear-svm-score', num2str(i)));  

        T3 = array2table(score3Matrix,'VariableNames',header, 'RowNames', testFnm)
        writetable(T3, strcat("outputs/train-", dataSet, ".xls"), 'WriteRowNames',true, 'Sheet', strcat('quadratic-svm-score', num2str(i)));  



    end

    cMat{1}=cMat1;
    cMat{2}=cMat2;
    cMat{3}=cMat3;
    
    clNames = {"LinearDiscriminant","LinearSVM","QuadraticSVM", "AvgAccuracy"};
    
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

function [] = printMisclassifiedEntriesCM(cm)
    global falseEntries 
    for i = 1:size(cm, 1)
        for j = 1:size(cm, 2)
            if i == j
                continue
            end
            if cm(i, j) ~= 0
                fprintf("(%d,%d):%d\n", i, j, cm(i,j));
            end
        end
    end
end      
