% Authors:  Nikhil Patwardhan, Ashish Bagate, Pratiksha Shah
% Date:     10 March 2011
% Program:  To run svmtrain on training data and svmpredict on tuning data
%           with different values of c and g for all 5 classes. The optimum
%           results are recorded for each of the 5 classes and will be used
%           for classifying the testing data.

runs=50-4;
% Initial values
c = 0.01;

acc = zeros(runs,runs);
max = 0;
pc = 0;     % optimum c
pg = 0;     % optimum g

for i=1:runs
    g = 0.01;
    for j=1:runs
        %disp(c);
        %disp(g);
        str=sprintf('-c %d -g %f -b 1',c,g);
        
        [model probMatrix accuracy] = buildAndTest(1,c,g);
        acc(i,j) = accuracy(1);

        if max < acc(i,j)
            max = acc(i,j);
            pc = c;
            pg = g;
        end;
        
        % 0.01 0.02 0.03.....0.1 0.2 0.3 ......1 2 3.....10 20
        % 30....100 200 300....1000
        if j < 10
            j_incr = 0.01;
        elseif j < 19
            j_incr = 0.1;
        elseif j < 28
            j_incr = 1;
        elseif j < 37
            j_incr = 10;
        else j_incr = 100;
        end;
        g = g + j_incr;
    end;
    if i < 10
        i_incr = 0.01;
    elseif i < 19
        i_incr = 0.1;
    elseif i < 28
        i_incr = 1;
    elseif i < 37
        i_incr = 10;
    else i_incr = 100;
    end;
    c = c + i_incr;
end;
disp('Optimum parameters: ');
disp(max);
disp(pc);
disp(pg);
save('optimumblack.mat','max','pc','pg','acc');