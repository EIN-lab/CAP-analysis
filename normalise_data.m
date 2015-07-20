function dataNorm = normalise_data(data, idxsNorm)

% Copy the structure to the output
dataNorm = data;

% Get a list of fieldnames
listFields = fieldnames(data);
nFields = length(listFields);

% Work out how many rows we should have
nSweeps = size(data.time_sweeps, 1);

% Provide a list of fields not to normalise
badFields = {'baseline', 'time_sweeps', 'edge_fit', 'fit_rsquared_adj', ...
    'fit_rmse'};

for iField = 1:nFields
    
    % Extract the current fieldname
    iFieldName = listFields{iField};
    
    % Check if this field is appropriate
    isGoodField = ~ismember(iFieldName, badFields) && ...
        isnumeric(data.(iFieldName)) && ...
        size(data.(iFieldName), 1) == nSweeps;
    if isGoodField
        
        % Calculate the baseline value
        baselineVals = mean(dataNorm.(iFieldName)(idxsNorm, :), 1);
        
        % Normalise the values
        dataNorm.(iFieldName) = bsxfun(@rdivide, dataNorm.(iFieldName), ...
            baselineVals);
        
    end
    
end

end