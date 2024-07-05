lowerRange1 = 1;
upperRange1 = 10;
lowerRange2 = 11;
upperRange2 = 20;
randomizedTrials_all=zeros(45,20)

clear randomizedTrials

for subj_id=45:45
    randomizedTrials = [];
    while numel(randomizedTrials) < 20
        % Generate a random number
        randomNumber = randi([lowerRange1, upperRange2]);

        % Check if the number already exists in the distribution
        while ismember(randomNumber, randomizedTrials)
            randomNumber = randi([lowerRange1, upperRange2]);
        end

        % Check if adding the number violates the condition
        if numel(randomizedTrials) >= 2 && numel(randomizedTrials) < 20 && (randomizedTrials(end) >= lowerRange1 && randomizedTrials(end) <= upperRange1) && (randomizedTrials(end-1) >= lowerRange1 && randomizedTrials(end-1) <= upperRange1)
            % If three consecutive numbers in the range 0-10 are already present, choose a number from the range 10-20
            randomNumber = randi([lowerRange2, upperRange2]);
            while ismember(randomNumber, randomizedTrials)
                randomNumber = randi([lowerRange2, upperRange2]);
            end
        elseif numel(randomizedTrials) >= 2 && numel(randomizedTrials) < 20 && (randomizedTrials(end) >= lowerRange2 && randomizedTrials(end) <= upperRange2) && (randomizedTrials(end-1) >= lowerRange2 && randomizedTrials(end-1) <= upperRange2)
            % If three consecutive numbers in the range 10-20 are already present, choose a number from the range 0-10
            randomNumber = randi([lowerRange1, upperRange1]);
            while ismember(randomNumber, randomizedTrials)
                randomNumber = randi([lowerRange1, upperRange1]);
            end
        end

        % Add the unique number to the distribution
        randomizedTrials = [randomizedTrials, randomNumber];
    end
    
    randomizedTrials_all(subj_id,:)=randomizedTrials;
end


save("randomizedTrials_all.mat","randomizedTrials_all")
writetable(randomizedTrials_all,"randomizedTrials_all.csv")





%% Define the conditions
% lowerBound = 1;  % Minimum value
% upperBound = 2;  % Maximum value
% numElements = 20;  % Number of random integers to generate
% 
% % Generate random integers within the specified range
% randomIntegers = randi([lowerBound, upperBound], 1, numElements);
% condition1 = sum(randomIntegers) < 20;  % Example condition: Numbers less than 20
% 
% sum_rand=0
% i=1
% rand_Int=[]
% while i<20
%     rand_Int(i)=(randomIntegers(i))
%     if sum(rand_Int)>20
%         break
%     end
%     i=i+1;
% end
% 
% vList{
% 
% vList={}
% i=1
% NM_list = find(contains(videoList,'NM_'));
% vList=videoList{NM_list}{:}
% NM_list=videoList{strcmp(extractBefore(videoList,"_"),'NM'}
% while i<length(rand_Int)
%     if mod(i, 2) == 1
%         cond='NM'
%     else
%         cond='NY'
%     end
%         vList{i}=
%     i=i+1
%     break
%         
% 
% vList{i}
% 
% % Apply additional conditions
% condition1 = randomIntegers < 20;  % Example condition: Numbers less than 20
% condition2 = mod(randomIntegers, 2) == 0;  % Example condition: Even numbers
% 
% % Apply the conditions using logical indexing
% result = randomIntegers(condition1 & condition2);
% 
% % Display the result
% disp(result);