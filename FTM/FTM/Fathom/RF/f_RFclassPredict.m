function result = f_RFclassPredict(X,model,Y,allP,verb)
% - predict class membership via Random Forest
%
% USAGE: result = f_RFclassPredict(X,model,Y,allP,verb);
%
% X       = data matrix
% model   = Random Forest model generated by f_RFclass
% Y       = set to empty (= []) when classifying unknowns; a vector of integers
%           specifying class membership indicates X is a 'test' set 
% allP    = return all predictions                                 (default = 0)
% verb    = verbose output                                         (default = 0)
%
% result = structure with the following fields:
%  .Y_hat   = predicted class membership
%  .votes   = normalized weights for the model
%  .marg    = measure of the confidence of the classification of each
%             observation; ranges from 0 (= lack) to 1 (= complete confidence)    
%  .predict = per tree predictions; if allP = 1, then the individual component
%             of the returned object is a character matrix where each column
%             contains the predicted class by a tree in the forest.
%  .err     = classification errors
%
% SEE ALSO: f_RFclass

% -----References:-----
% Breiman, L., and A. Cutler. 2003. Manual on setting up, using, and
%   understanding Random Forests v4.0. Technical Report. Available from:
%   http://www.stat.berkeley.edu/~breiman/Using_random_forests_v4.0.pdf  

% -----Notes:-----
% Not yet implemented: proximity

% -----Author(s):-----
%**************************************************************
%* mex interface to Andy Liaw et al.'s C code (used in R package randomForest)
%* Added by Abhishek Jaiantilal ( abhishek.jaiantilal@colorado.edu )
%* License: GPLv2
%* Version: 0.02
%
% Calls Classification Random Forest
% A wrapper matlab file that calls the mex file
% This does prediction given the data and the model file
% Options depicted in predict function in:
% http://cran.r-project.org/web/packages/randomForest/randomForest.pdf
%**************************************************************

% modified by David L. Jones, Aug-2009
% This file is part of the 'FATHOM TOOLBOX FOR MATLAB'

% changes by David L. Jones:
% - edited documentation
% - reorganized defaults, new code for translating labels back to originals,
% support for standardized/centered data, confusion matrix and error rates
% Feb-2012: votes are now normalized; output now organized in a structure
% May-2013: now supports margins

% -----Check input & set defaults:-----
if (nargin<2), error('Must specify X & MODEL!'); end
if (nargin<3), Y    = []; end % default classify unknowns
if (nargin<4), allP = 0;  end % default don't return all predictions
if (nargin<5), verb = 0;  end % default no verbose listing

% Replace empty inputs with defaults:
if isempty(Y), Y = NaN; end;

% Check for compatible sizes:
if ~isnan(Y)
   if (size(X,1) ~= size(Y,1)), error('Size mismatch b/n X & Y'); end;
end

% -----Standardize/Center data:-----
switch model.stnd
   case 'raw'  % use raw data for X
   case 'stnd' % standardize variables in X
      X = f_stnd(X);
   case 'ctr'  % center variables in X
      X = f_center(X);
   otherwise
      error('Invalid option for STND!');
end

% Call mex file:
[Y_hat,predict,votes] = mexClassRF_predict(X',model.nrnodes,model.nTree,...
   model.xbestsplit,model.classwt,model.cutoff,model.treemap,model.nodestatus,...
   model.nodeclass,model.bestvar,model.ndbigtree,model.nClass,allP);

% Clean up:
clear mexClassRF_predict

% Format predicted values:
votes = votes';
votes = votes ./ repmat(sum(votes,2),1,size(votes,2)); % normalize [D.Jones]
Y_hat = double(Y_hat);

% Calculate margins (= confidence in each classification; after Beiman &
% Cutler, 2003: p. 14):
votesS = sort(votes,2,'descend');   % sort votes descending, by column
marg   = votesS(:,1) - votesS(:,2); % difference between 2 largest normalized votes

% Translate labels to original format (new -> old):
Y_old    = model.Y_old;    % original class labels
Y_new    = model.Y;        % new labels starting at 1
grps_old = unique(Y_old);  
grps     = unique(Y_new);
nGrps    = size(grps(:),1); % # of groups (classes)
nClass   = model.nClass;
% 
YY = repmat(NaN,size(Y_hat)); % preallocate
for i = 1:nGrps
   YY(Y_hat==grps(i)) = grps_old(i);
end
% 
Y_hat = YY; % replace with new labels


% -----Create Confusion Matrix if X is TEST data:-----
if ~isnan(Y)
   % Classification error rates:
   err = f_errRate(Y,Y_hat);
   
   % -----Send output to display:-----
   if (verb>0)
      
      fprintf('\n==================================================\n');
      fprintf('       RANDOM FOREST ''Majority Rules'' \n'           );
      fprintf('    Classification Success Using TEST Data: \n');
      fprintf('--------------------------------------------------\n' );
      
      fprintf('Group        Corrrect  \n');
      for j=1:nClass
         
         fprintf('%s %d %s %10.2f %s \n',['  '],grps_old(j),['     '],[1-err.grp(j)]*100,['%']);
      end
      
      fprintf('\n\n');
      fprintf('Total Correct  = %4.2f %s \n',(1-err.tot)*100,['%']);
      fprintf('Total Error    = % 4.2f %s \n',err.tot*100,['%']);
      fprintf('Prior prob     = group size \n');
      
      fprintf('\n--------------------------------------------------\n' );
      fprintf('     Confusion Matrix (%s): \n',['%'])
      hdr = sprintf('%6.0f ',grps_old(:)');
      fprintf(['group: ' hdr]);
      fprintf('\n')
      for j=1:nClass
         txt = [sprintf('%6.0f ',grps_old(j)) sprintf('%6.2f ',err.conf(j,:)*100)];
         fprintf(txt);
         fprintf('\n')
      end
      fprintf('\n==================================================\n\n');
   end
else
   err = NaN;
end

% Wrap results up into a structure:
result.Y_hat   = Y_hat;
result.votes   = votes;
result.marg    = marg;
result.predict = predict;
result.err     = err;
