function ymax = ycrit(as,bs,af,bf,c)
%ycrit Takes the model fitted parameters evaluates the overshoot value.
%
%
%   Copyright (c) <2018> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project root for
%   license information.

ncrit = log(-(as*bs)/(af*bf))/(bf-bs);

if ncrit < 0 || ~isreal(ncrit)
    ymax = NaN;
    return;
end

ymax = as*exp(bs*ncrit)+af*exp(bf*ncrit)+c;
end