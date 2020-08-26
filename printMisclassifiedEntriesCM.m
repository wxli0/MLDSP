function [] = printMisclassifiedEntriesCM(cm)
    global falseEntries 
    falseEntries = containers.Map;
    fprintf("printing misclassified entries\n")
    for i = 1:size(cm, 1)
        for j = 1:size(cm, 2)
            if i == j
                continue
            end
            if cm(i, j) ~= 0
                fprintf("(%d,%d):%d\n", i, j, cm(i,j));
                global falseEntries
                if isKey([num2str(i) num2str(j)], falseEntries)
                    falseEntries([num2str(i) num2str(j)]) = [falseEntries([num2str(r) num2str(p)]) cm(i,j)];
                else
                    falseEntries([num2str(i) num2str(j)]) = [cm(i,j)];
                end
            end
        end
    end
    fprintf("printing false entries\n");
    disp(falseEntries);  
end      
