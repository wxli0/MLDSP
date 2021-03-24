function [mList3] = testingExternMisList(dSet,numMethod,disMat,alabels,lg,clusterNames,kVal, maxClusSize, clusterStart, dataSet)
     warning('off','all');
    %read and clean testing data
    [AcNmbTest,SeqTest, pnts,Fnm] = readTestingExternSet(dSet, maxClusSize);
    %totalSeq = length(lg);
    numberOfClusters = length(clusterNames);
    
    %testing
    [pMat,mList3] = classifyTestSeqExternMisList(AcNmbTest,Fnm, numMethod,disMat,alabels,SeqTest,lg,clusterNames,kVal,clusterStart, dataSet);

end
