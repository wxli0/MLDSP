function [tab,mList1,mList2,mList3,mList4,mList5,mList6] = testingExternMisList(dSet,numMethod,disMat,alabels,lg,clusterNames,kVal,mLen,minSeqLen,maxSeqLen,maxClusSize, clusterStart, dataSet)
     warning('off','all');
    %read and clean testing data
    [AcNmbTest,SeqTest, pnts,Fnm] = readTestingExternSet(dSet,minSeqLen,maxSeqLen,maxClusSize);
    %totalSeq = length(lg);
    numberOfClusters = length(clusterNames);
    
    %testing
    [pMat,mList1,mList2,mList3,mList4,mList5,mList6] = classifyTestSeqExternMisList(AcNmbTest,numMethod,disMat,alabels,SeqTest,lg,clusterNames,kVal,mLen, clusterStart, dataSet);

end
