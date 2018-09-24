%   Copyright (C) 2018  Zoe J. Looser et al.
%
%   This program is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This program is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this program.  If not, see <http://www.gnu.org/licenses/>.

% ======================================================================= %

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

% Store a record of the normalisation, and re-order the fields for tidyness
dataNorm.idxsNorm = idxsNorm;
dataNorm = orderfields(dataNorm);

end
