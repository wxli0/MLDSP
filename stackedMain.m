% ML-DSP
% the main program that user needs to run for the results.
% default dataSet is Primates
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Gurjit Singh Randhawa  %
% Department of Computer Science,%
% Western University, Canada     %
% email: grandha8@uwo.ca         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%clear workspace
close all;
clear all;
clc ;
dataSet = 'Primates'
basePath = '/home/w328li/MLDSP-desktop/samples/';
if isunix & ismac
    basePath = '/Users/wanxinli/Desktop/project/MLDSP-desktop/samples/'
end
dataSetPath = strcat(basePath, dataSet)
kVal = 9; % used only for CGR-based representations(if methodNum=1,15,16,17)

selectedFolder = dataSetPath;
fprintf('Reading sequences .... \n');%load('Bac2500seq.mat');

%**********cluster size options*****
%run the following with a limit on the cluster size (randomly select the sequences)
%maxClusSize = 0 limit all cluster sizes by the size of smallest cluster;
%(removing smaller sequences may change the cluster size later)
%otherwise reduce the size of larger clusters by the assigned value
maxClusSize = 50000;
[acN, Seq, numberOfClusters, clusterNames, pointsPerCluster,Fnm] = readExternsBac(dataSetPath,maxClusSize);
%[allCGR,ptsNw] = redefineClus(numberOfClusters, pointsPerCluster, Seq, Fnm, kVal, maxSeqLen);
AcNmb = Fnm;
totalSeq = length(Seq);
allCGR = cell(1,totalSeq);
for i=1:totalSeq
    ss = Seq{i};
    tCGR=zeros(2^kVal);
    for j=1:length(ss)
        sq = ss{j};
        sqSeg = regexp(sq, '[^ATCG]', 'split')
        for m=1:length(sqSeg)
            seg = sqSeg{m};
            tCGRNw=cgr(seg,'ACGT',kVal);
            tCGR=tCGR+tCGRNw;
        end
    end  
    allCGR{i}=tCGR;
end

f = cell(1, totalSeq);
lg = cell(1, totalSeq);
for i=1:totalSeq
    f{i} = fft(allCGR{i});
    lg{i} = abs(f{i});
end

%pointsPerCluster=ptsNw;
fprintf('Computing Distance matrix .... \n');
lgl = cell(1,totalSeq);
parfor i=1:totalSeq
    lgl{i} =  reshape(lg{i},1,[]);
end
lg = lgl;
fm=cell2mat(lgl(:));
disMat = f_dis(fm,'cor',0,1);
[Y,eigvals] = cmdscale(disMat,3);
% fprintf('Generating 3D plot .... \n');
% index=1;
% counter=1;
% Cluster = zeros(1,totalSeq);
% for i=1:totalSeq
%     Cluster(i)=index;
%     if(counter==pointsPerCluster{index})
%         index=index+1;
%         counter=0;
%     end
%     counter= counter+1;
% end
% uniqueClusters  = unique(Cluster);
% cmap = distinguishable_colors(numberOfClusters);
% hf = figure;
% hold on;
% for h=1:numberOfClusters
% cIndex = Cluster == uniqueClusters(h);
% plot3(Y(cIndex,1),Y(cIndex,2),Y(cIndex,3),'.','markersize', 15, 'Color',cmap(h,:),'DisplayName',clusterNames{h});
% end
% view(3), axis vis3d, box on, datacursormode on
% xlabel('x'), ylabel('y'), zlabel('z')
% tname = strcat(selectedFolder,' (',int2str(totalSeq),' Sequences',')');
% title(tname)
% hdt = datacursormode(hf);
% set(hdt,'UpdateFcn',{@myupdatefcn,Y,Fnm})
% legend('show');

clear a;
clear s;
a=[];
for i=1:numberOfClusters
    for j=1:pointsPerCluster{i}
        a=[a; i];
    end
end
ATestlg = [disMat a];
% rng(15,'twister');

alabels = a;
fprintf('Performing classification .... \n');
folds=10;
if (totalSeq<folds)
    folds = totalSeq;
end
[accuracy, avg_accuracy, clNames, cMat] = classificationCode(disMat,alabels, folds, totalSeq, Seq);
acc = [accuracy avg_accuracy];
s.ClassifierModel=cellstr(clNames.');
s.Accuracy=cell2mat(acc).';
ClassificationAccuracyScores = struct2table(s);

