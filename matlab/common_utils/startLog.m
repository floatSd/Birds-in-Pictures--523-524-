function startLog
% Setup the log file
date_now = clock;
date_now = strcat(num2str(date_now(1)),'_',num2str(date_now(2)),...
                '_', num2str(date_now(3)), num2str(date_now(4)),...
                num2str(date_now(5)));
diary(strcat('..\logs\log', date_now,'.log'));