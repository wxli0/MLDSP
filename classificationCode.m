function [ accuracy, avg_acc, clNames, cMat ] = classificationCode( disMat,alabels, folds, totalSeq, AcNum)
    %10-fold cross validation
    %classification accuracy for 6 classifiers
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
    cMat4=cell(1,folds);
    cMat5=cell(1,folds);
    cMat6=cell(1,folds);
    cn=unique(alabels);
    n = length(cn);
    ord = [];
    for xx=1:n
        ord=[ord xx];
    end

    for i = 1:folds
        AllTestInd = test(cv,i);
        testInd = find(AllTestInd);
        AllTrainInd = training(cv,i);
        trainInd = find(AllTrainInd);
        trainSet = disMat(trainInd,trainInd);
        testSet = disMat(testInd,trainInd);

        %linear-discriminant
        c1 = fitcdiscr(...
        trainSet, ...
        alabels(trainInd), ...
        'DiscrimType', 'linear', ...
        'Gamma', 0, ...
        'FillCoeffs', 'off', ...
        'ClassNames', cn);
        plabel1 = predict(c1,testSet);
        cMat1{i} = confusionmat(alabels(testInd),plabel1,'Order',ord);
        printMisclassifiedEntriesCM(cMat1{i})

        fmt=['testInd =' repmat(' %1.0f',1,numel(testInd)) '\n'];
        fprintf(fmt,testInd)
        % disp(cMat1{i})
        % fmt=['plabel1 =' repmat(' %1.0f',1,numel(plabel1)) '\n'];
        % fprintf(fmt, plabel1)
        % fmt=['alabels(testInd) =' repmat(' %1.0f',1,numel(alabels(testInd))) '\n'];
        % fprintf(fmt, alabels(testInd))
        % print misclassified testid and sequence
        for k = 1:length(plabel1)
            alabelsArray = alabels(testInd);
            if plabel1(k) ~= alabelsArray(k)
                fprintf("predicted is: %d, ref is %d \n", plabel1(k), alabelsArray(k))
                fprintf("fileId is:")
                disp(AcNum(testInd(k)))
            end
        end




        
        %linear-svm
        if(n==2)
            c2 = fitcsvm(...
            trainSet, ...
            alabels(trainInd), ...
            'KernelFunction', 'linear', ...
            'PolynomialOrder', [], ...
            'KernelScale', 'auto', ...
            'BoxConstraint', 1, ...
            'Standardize', true, ...
            'ClassNames', cn);
            [plabel2, score2] = predict(c2,testSet);
            cMat2{i} = confusionmat(alabels(testInd),plabel2,'Order',ord);
        else
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
            'FitPosterior',true, ...
            'Coding', 'onevsall', ...
            'ClassNames', cn);
            [plabel2, ~, ~, score2] = predict(c2,testSet);
            scores2=[scores2 score2];
            plabels2=[plabels2 plabel2];
            cMat2{i} = confusionmat(alabels(testInd),plabel2,'Order',ord);
        end
        disp(alabels(testInd))
        disp(plabel2)
        disp(score2)

        %quad-svm
        if(cn==2)
            c3 = fitcsvm(...
            trainSet, ...
            alabels(trainInd), ...
            'KernelFunction', 'polynomial', ...
            'PolynomialOrder', 2, ...
            'KernelScale', 'auto', ...
            'BoxConstraint', 1, ...
            'Standardize', true, ...
            'ClassNames', cn);
            plabel3 = predict(c3,testSet);
            cMat3{i} = confusionmat(alabels(testInd),plabel3,'Order',ord);
        else
             template = templateSVM(...
            'KernelFunction', 'polynomial', ...
            'PolynomialOrder', 2, ...
            'KernelScale', 'auto', ...
            'BoxConstraint', 1, ...
            'Standardize', true);
            c3 = fitcecoc(...
            trainSet, ...
            alabels(trainInd), ...
            'Learners', template, ...
            'Coding', 'onevsall', ...
            'ClassNames', cn);
            plabel3 = predict(c3,testSet); 
            cMat3{i} = confusionmat(alabels(testInd),plabel3,'Order',ord);            
        end
        
        %fine-knn
        c4 = fitcknn(...
        trainSet, ...
        alabels(trainInd), ...
        'Distance', 'Euclidean', ...
        'Exponent', [], ...
        'NumNeighbors', 1, ...
        'DistanceWeight', 'Equal', ...
        'Standardize', true, ...
        'ClassNames', cn);
        plabel4 = predict(c4,testSet);
        cMat4{i} = confusionmat(alabels(testInd),plabel4,'Order',ord); 

        % next 2 classifiers are used for less than 2000 sequences for time efficiency
        if(totalSeq<=20000)
            %subspace-discriminant
            subspaceDimension = max(1, min(74, length(trainSet) - 1));
            c5 = fitcensemble(...
            trainSet, ...
            alabels(trainInd), ...
            'Method', 'Subspace', ...
            'NumLearningCycles', 30, ...
            'Learners', 'discriminant', ...
            'NPredToSample', subspaceDimension, ...
            'ClassNames', cn);
            plabel5 = predict(c5,testSet);
            cMat5{i} = confusionmat(alabels(testInd),plabel5,'Order',ord); 

            %subspace knn
            subspaceDimension = max(1, min(74, length(trainSet) - 1));
            c6 = fitcensemble(...
            trainSet, ...
            alabels(trainInd), ...
            'Method', 'Subspace', ...
            'NumLearningCycles', 30, ...
            'Learners', 'knn', ...
            'NPredToSample', subspaceDimension, ...
            'ClassNames', cn);
            plabel6 = predict(c6,testSet);
            cMat6{i} = confusionmat(alabels(testInd),plabel6,'Order',ord); 
        end
    end

    cMat{1}=cMat1;
    cMat{2}=cMat2;
    cMat{3}=cMat3;
    cMat{4}=cMat4;
    if(totalSeq<=20000)
        cMat{5}=cMat5;
        cMat{6}=cMat6;
        clNames = {"LinearDiscriminant","LinearSVM","QuadraticSVM","FineKNN","SubspaceDiscriminant","SubspaceKNN","AverageAccuracy"};
    else
        clNames = {"LinearDiscriminant","LinearSVM","QuadraticSVM","FineKNN",'AverageAccuracy'};
    end
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
        if (i == 1)
            fprintf("confusion matrix for LinearDiscriminant is:\n")
            disp(cMatrix)
        end
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
