% convolutional interleaver

I = 12;
M = 17;

% calculate the needed amount of memory (sum of natural numbers..)
ram_len = M * (I-1) * I / 2;

% prepare start address table for every branch
start = zeros(I-1,1);
tmp = 1;
for i=1:length(start)
   start(i) =  tmp;
   tmp = tmp + M*i;
end

% initialize the RAM to -1
ram = zeros(ram_len, 1) - 1;

% generate input and output vectors
input = linspace(0, 4*ram_len-1, 4*ram_len);
output = zeros(4*ram_len,1) - 2;

% starting branch = 0
branch = 0;
% starting offset = -1 (increased to 0 in first cycle)
offset = -1;

for i = 1:length(input)
    if branch == 0
        % directly route input to output
        output(i) = input(i);
        % increase the intra-branch-offset once per revolution
        offset = offset + 1;
    else
        % calculate the RAM address
        address = start(branch) + mod(offset, branch*M);
        % read output and write input
        output(i) = ram(address);
        ram(address) = input(i);
    end;
    % increase the branch number every sample
    branch = mod(branch + 1, I);
end;
    