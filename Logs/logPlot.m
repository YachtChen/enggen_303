% Add your log file names to the 'log_files' cell array
log_files = {'putty2.log', 'putty4.log', 'putty8.log', 'putty16.log', 'putty32.log', 'putty64.log', 'putty128.log'};

% Initialize a cell array to store the data from each log file
data = cell(1, numel(log_files));

% Read the log files and store the data in the 'data' cell array
for i = 1:numel(log_files)
    data{i} = read_log_file(log_files{i});
    data{i} = make_data_in_phase(data{i});
end

for i = 1:numel(log_files)
    for j = 1:numel(data{i})
        bits = 0;
        data{i}(j) = bitshift(int16(data{i}(j)), 2) + bits;
        if ((data{i}(j)==0)&&(j>5))
            data{i}(j) = data{i}(j-1);
        end
    end
end

% Generate the time values for the sawtooth signal
t = linspace(0, 1000, 1000);


sawtooth_signal = 1023/2* (1 - sawtooth(2 * pi * t / 1000, 0));


% Plot the data
figure
hold on
for i = 1:numel(log_files)
    %plot(data{i}, 'DisplayName', log_files{i})
    % Compute the trend line
    p = polyfit(1:numel(data{i}), data{i}, 1);
    p(2) = 0;
    disp(p(1));
    trend_line = polyval(p, 1:numel(data{i}));
    plot(trend_line);
end
plot(sawtooth_signal, 'DisplayName', 'Sawtooth Signal')
hold off
xlabel('Index')
ylabel('Values')
title('Log Files Plot (In Phase)')
legend('show')

% Function to read log files and store the data in an array
function data = read_log_file(file_name)
    % Read the log file
    file_content = fileread(file_name);
    
    % Remove the header by finding the first newline character
    first_newline = find(file_content == newline, 1, 'first');
    file_content = file_content(first_newline+1:end);
    
    % Split the file content by newline characters
    file_lines = split(file_content, newline);
    
    % Convert the strings to integers
    data = str2double(file_lines);
end


% Function to make data in phase by starting from zero and wrapping around
function data = make_data_in_phase(data)
    % Find the index of the first zero in the data
    first_zero_idx = find(data == 0, 1, 'first');
    % Reorder the data to start from zero and wrap around
    data = [data(first_zero_idx:end); data(1:first_zero_idx-1)];
end
