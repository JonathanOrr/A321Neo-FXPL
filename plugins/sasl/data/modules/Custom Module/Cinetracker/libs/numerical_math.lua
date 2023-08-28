function Gauss_lobatto_quadrature(n)
    local x = {}   -- array to hold the quadrature nodes
    local w = {}   -- array to hold the corresponding weights

    if n == 1 then -- special case for one point quadrature
        x[1] = 0.0
        w[1] = 2.0
        return x, w
    end

    local N = n - 1   -- number of interior nodes
    local eps = 1e-15 -- tolerance for Newton-Raphson iterations

    -- Define the Legendre polynomial P_n(x) and its derivative P'_n(x)
    local function p(x)
        local p0, p1 = 1.0, x
        for i = 2, N do
            local pi = ((2 * i - 1) * x * p1 - (i - 1) * p0) / i
            p0 = p1
            p1 = pi
        end
        return p1
    end

    local function dp(x)
        return N * (x * p(x) - p0) / (x ^ 2 - 1.0)
    end

    local p0 = 1.0                  -- initialize P_{n-1}(x)
    local xm = -math.cos(math.pi / N) -- right endpoint of interval
    local x0 = -xm                  -- left endpoint of interval
    local x1 = xm                   -- right endpoint of interval

    local dx = eps                  -- initialize dx to enter the while loop
    while math.abs(dx) > eps do     -- iterate until tolerance is met
        local dp0 = dp(x0)          -- evaluate P'_{n-1}(x_0)
        local dp1 = dp(x1)          -- evaluate P'_{n-1}(x_1)

        dx = -p(x1) / dp1           -- Newton-Raphson update for x_1
        x1 = x1 + dx

        dx = -p(x0) / dp0 -- Newton-Raphson update for x_0
        x0 = x0 + dx
    end

    -- Compute the quadrature nodes and weights
    for i = 1, n do
        if i == 1 then
            x[i] = -1.0                 -- left endpoint
            w[i] = 2.0 / (N * N)        -- weight for left endpoint
        elseif i == n then
            x[i] = 1.0                  -- right endpoint
            w[i] = 2.0 / (N * N)        -- weight for right endpoint
        else
            x[i] = x0 + (i - 1) * (x1 - x0) / N -- interior node
            w[i] = 2.0 / (N * N * p(x[i]) ^ 2) -- weight for interior node
        end
    end

    table.sort(x)
    return x, w -- return nodes and weights
end

function Lagrange_interpolation(x, y)
    assert(#x == #y, "x and y arrays must have the same length")

    local n = #x -- number of data points
    local function L(i, xval)
        local prod = 1.0
        for j = 1, n do
            if i ~= j then
                prod = prod * (xval - x[j]) / (x[i] - x[j])
            end
        end
        return prod
    end

    local function P(xval)
        local sum = 0.0
        for i = 1, n do
            sum = sum + y[i] * L(i, xval)
        end
        return sum
    end

    return P -- return the Lagrange interpolation polynomial
end
