function Knn_Class_Build(totaldata, numCoeff, k)
% This function builds a KNN classifier with the user defined inputs:
% numCoeff = the number of coefficients allowed to use, k = the k value to
% use, totaldata = the training data set.  This method uses the total error
% value

%split data into classification 
numData = size(totaldata, 2);
data = cell(1,numData);
classifier = zeros(numData,1);
for i = 1:numData
    data{i} = totaldata{1,i};
    classifier(i,1) = totaldata{2,i};
end

%Calculate coefficients for all the data
ClassifierData = zeros(numData, numCoeff);
for i = 1:numData
    coeff = SolverLinearSquare(data{i});
    ClassifierData(i,1:numCoeff) = coeff(1:numCoeff);
end

%create the powerset array
powerset = PowerSet(1:numCoeff);

%Create a cell that will hold the error rate for every set of coefficients
%in the powerset.
X = [];
minVals = cell(2,1);

%Work out the required coeffiient to keep, try for every combination within
%the power set.
numPowerSetData = size(powerset,2);
for i = 1:numPowerSetData
    numMissClassified = 0;
    p = powerset{i};
    
    %grab the information requried from each data set
    for j = 1:numData
        a = ClassifierData(j,:);
        b = a(p);
        X(j,1:length(b)) = b;
    end
    x = X;
    
    for l = 1:numData
        distances = [numData, 2];
        for j = 1:numData
            if (j == l)
                distances(j,1) = NaN;
                distances(j,2) = j;
            else
                distances(j,1) = (x(l,:) - x(j,:))*(x(l,:) - x(j,:))';
                distances(j,2) = j;
            end
        end
        
        %Calculate the closest neighbours
        imageClass = zeros(k,1);
        for j = 1:k
            [a,pos] = min(distances(:,1));
            val = distances(pos,2);
            distances(pos,:) = [];
            imageClass(j,1) = classifier(val);
        end        
        clasification = mode(imageClass);
        if(clasification ~= classifier(l))
            numMissClassified = numMissClassified + 1;
        end
    end
    error = numMissClassified/numData;
    
    if(minVals{2,1} ~= 0)
        if(error < minVals{2,1})
            minVals{1,1} = powerset{i};
            minVals{2,1} = error;
        end
    else
        minVals{1,1} = powerset{i};
        minVals{2,1} = error;
    end
    X = [];
end

%Identify optimal coefficients
coeffUsed = minVals{1,1};
error = minVals{2,1};
coeffUsedError = [coeffUsed, error];

%pull optimal coefficients from the data set and design the data set that
%will hold all the information requried for the classifier to classify a
%future image
Classifier_Data = zeros(numData + 1, length(coeffUsed) + 1);
Classifier_Data(1,1:length(coeffUsed)) = coeffUsed;
Classifier_Data(1, length(coeffUsed) + 1) = k;
Classifier_Data(2:numData+1,  length(coeffUsed) + 1) = classifier;
for i = 2:(numData + 1)
   a = ClassifierData(i-1,:);
   Classifier_Data(i,1:length(coeffUsed)) = a(coeffUsed);
end

%Save the data
save KNN_Classifier_Data Classifier_Data
end