% data_processing.m only needs to be run once (whenever a new text file is
% collected). It produces 3 .mat files which can then be analyzed (see
% below for descriptions):
% 'lab3_process_separate.mat'
% 'lab3_process_combined.mat'
% 'our_process_separate.mat'

% Arguments:
% data_file (e.g. 'csi_logs/csi_log_left_run2.txt'): The name of the text file
% MAC (e.g. '78:4b:87:a2:b7:57'): The MAC address of the src we are concerned about. Keep it lowercase.
function data_processing(data_file, MAC)
% process_channels_lab3 is the code that was given for us to use during
% lab3. Running this function will produce two .mat files (note that there
% are two columns since the other two columns would have had zeros):
% 'lab3_process_separate.mat': contains information about H for individual
% subcarriers (so each packet will have 56 rows) for the given MAC address
% 'lab3_process_combined.mat': contains information about h combined across
% each of the subcarriers (so each packet will have 1 row) for the given
% MAC address
process_channels_lab3(data_file,MAC);

% process_channels is the code that Veronica wrote to parse the text file
% and obtain the channel measurements for the given MAC address (note that
% there are four columns, with two of the four having zeros)
% Running this function will produce one .mat file:
% 'our_process_separate.mat': contains information about h for individual
% subcarriers (so each packet will have 56 rows)
process_channels(data_file,MAC);

end