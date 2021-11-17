-------------------------------------------------------------------------------
-- A32NX Freeware Project
-- Copyright (C) 2020
-------------------------------------------------------------------------------
-- LICENSE: GNU General Public License v3.0
--
--    This program is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.
--
--    Please check the LICENSE file in the root of the repository for further
--    details or check <https://www.gnu.org/licenses/>
-------------------------------------------------------------------------------

-- Predictor function for SVM

function predict_svm_gaussian(model, x)

    local bias  = model.bias;
    local alpha = model.alpha;
    local SV    = model.SV;
    local Mu    = model.Mu;
    local Sg    = model.Sg;
    
    -- Input standardization
    local input = {}
    for i,_x in ipairs(x) do
        input[i] = (_x - Mu[i]) / Sg[i]
    end

    local sum = bias;
    for n,a in ipairs(alpha) do  -- For each Lagrangian multiplier
        -- Compute the norm
        local norm = 0
        for i = 1,#input do
            norm = norm + (SV[n][i] - input[i]) ^ 2
        end
        norm = math.sqrt(norm)

        local G = math.exp(-norm);
        sum = sum + a * G;
    end

    return sum
end