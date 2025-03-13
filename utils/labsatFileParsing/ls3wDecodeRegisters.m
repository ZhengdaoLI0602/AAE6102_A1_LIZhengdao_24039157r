%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FGI-GSRx software GNSS receiver
%
% Finnish Geospatial Research Institute
% Department of Navigation and Positioning
% DO NOT DISTRIBUTE
%
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [iData, qData] = ls3wDecodeRegisters(raw_data, quantization, num_channels)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extracts parameters from LabSat .ini-file
%
% Inputs:
%   raw_data            - Raw ls3w 64-bit register data
%   quantization        - Sample quantization [1(-bit), 2(-bit), or 3(-bit)]
%   num_channels        - Number of channels
%
% Outputs:
%   iData               - Parsed in-phase samples for all channels
%   qData               - Parsed quadrature samples for all channels
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Number of samples per register
num_samples_per_register = floor(64 / (quantization * 2 * num_channels));

% Initialize arrays to store the I and Q components
total_samples = numel(raw_data) * num_samples_per_register;

% Initialize output arrays
iData = zeros(total_samples, 1, 'int8');
qData = zeros(total_samples, 1, 'int8');

% Shift per channel
SPC = quantization * 2;

% Shift per sample
SFT = SPC * num_channels;

% Spare bits and shift bits are based on the .ini configuration and quantization
d_ls3w_spare_bits = 64 - num_samples_per_register * SFT;

% Sample counter
sample_counter = 1;

% Process each 64-bit register
for reg_idx = 1:numel(raw_data)

    % Convert the 64-bit register into individual bits (bitset); Extract bits from least significant to most significant
    bs = flip(int8(bitget(raw_data(reg_idx), 1:64)));

    % Iterate over each sample of the channel in the register
    for sample_idx = 0:(num_samples_per_register-1)
        
        % Iterate over each received channel
        for channel_idx = 0:(num_channels-1)

            % Compute the bit positions for I and Q in this sample
            bit_offset = 1  +  d_ls3w_spare_bits  +  sample_idx*SFT  +  channel_idx*SPC;

            % Decode into 8-bit integers
            switch quantization
                case 1 % 1-bit: [0, 1] -> [1,-1]
                    iData(sample_counter) = 1 - 2*bs(bit_offset);
                    qData(sample_counter) = 1 - 2*bs(bit_offset+1);

                case 2 % 2-bits: [00,01,10,11] -> [1,2,-2,-1]
                    iData(sample_counter) = 1 - 3*bs(bit_offset)   + bs(bit_offset+1);
                    qData(sample_counter) = 1 - 3*bs(bit_offset+2) + bs(bit_offset+3);

                case 3 % 3-bits: [000,001,010,011,100,101,110,111] -> [1,2,3,4,-4,-3,-2,-1]
                    iData(sample_counter) = 1 - 5*bs(bit_offset)   + 2*bs(bit_offset+1) + bs(bit_offset+2);
                    qData(sample_counter) = 1 - 5*bs(bit_offset+3) + 2*bs(bit_offset+4) + bs(bit_offset+5);
                otherwise
                    % Close all files opened by the MATLAB instance and throw an error if the quantization is not supported
                    fclose('all');
                    error("Quantization number not supported!");
            end
            
            % Iterate sample counter
            sample_counter = sample_counter + 1;
        end
    end
end