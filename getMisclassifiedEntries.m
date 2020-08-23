function [ret] = getMisclassifiedEntries(ref, pred)
    ret = containers.Map;
    for i  = 1:length(ref)
        r = ref(i);
        p = pred(i);
        if (r==p)
            continue
        end
        if isKey([num2str(r) num2str(p)], ret)
            ret([num2str(r) num2str(p)]) = ret([num2str(r) num2str(p)])+1;
        else
            ret([num2str(r) num2str(p)]) = 1;
        end
    end
        
