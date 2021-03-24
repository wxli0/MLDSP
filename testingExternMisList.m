function [mList3] = testingExternMisList(dSet,disMat,alabels,lg,clusterNames,kVal, maxClusSize, clusterStart, dataSet, minSeqLen,maxSeqLen)
     warning('off','all');
    %read and clean testing data
    [AcNmbTest,SeqTest, pnts,Fnm] = readTestingExternSet(dSet, minSeqLen,maxSeqLen, maxClusSize);
    %totalSeq = length(lg);
    numberOfClusters = length(clusterNames);
    
    %testing
    [pMat,mList3] = classifyTestSeqExternMisList(AcNmbTest,Fnm, disMat,alabels,SeqTest,lg,clusterNames,kVal,clusterStart, dataSet);

end
