function [] = printMisclassifiedEntriesCM(cm)
    fprintf("printing misclassified entries\n")
    for i = 1:size(cm, 1)
        for j = 1:size(cm, 2)
            if i == j
                continue
            end
            if cm(i, j) ~= 0
                fprintf("(%d,%d):%d\n", i, j, cm(i,j))
            end
        end
    end
        
