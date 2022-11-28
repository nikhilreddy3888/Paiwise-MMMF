function [weakR, strongR] = generateData()
%CODE FOR RANDOM MATRIX GENERATION
clear;
%% Binary
%{
row=2000;
col=1000;
ratingLevel = [-1, 1];
non0Per = 10;
non_zero=ceil((row*col) * non0Per /100);
rating_per = [1 1];
total = sum(rating_per(:));
ratio = ceil(non_zero / total);
R=zeros(row,col);
maxIdx = row *col;
for i=1:length(ratingLevel)
    idx_zero = find( R(:) == 0 );
    rand_idx = randperm(size(idx_zero,1));
    R(idx_zero( rand_idx( 1:rating_per(i)*ratio)  ) )= ratingLevel(i);
end
%}
%% Binary
%{
row=5;
col=1000;
%ratingLevel = [-1, 1];
non0Per = 10;
non_zero=ceil((row*col) * non0Per /100);
R=zeros(row,col);
temp=randi([1 2],row,col);
max_index = row*col;
idx=randperm(max_index);
idx=idx(1:non_zero);

R(idx)=temp(idx);
R(R==1) = -1;
R(R==2) = 1;

%}
%% rating matrix
%{
row=5;
col=1000;
ratingLevel = 5;
non0Per = 10;
non_zero=ceil((row*col) * non0Per /100);
rating_per = [1 1 1 1 1];
total = sum(rating_per(:));
ratio = ceil(non_zero / total);
R=zeros(row,col);
maxIdx = row *col;
randPerm = randperm(maxIdx);
for i=1:ratingLevel
    idx_zero = find( R(:) == 0 );
    rand_idx = randperm(size(idx_zero,1));
    R(idx_zero( rand_idx( 1:( rating_per(i)*ratio) ) ) )= i;
end
%}
%{
row=10;
col=10;
ratingLevel = 5;
non0Per = 60;
non_zero=ceil((col * non0Per) /100);

rating_per = [1 1 1 1 1];
total = sum(rating_per(:));
ratio = ceil(non_zero / total);
R=zeros(row,col);
for userNo=1:row
    for i=1:5
        idx_zero = find( R(userNo,:) == 0 );
        rand_idx = randperm(size(idx_zero,2));
        R(userNo,idx_zero(rand_idx(1:(rating_per(i)*ratio))))= i;
        clear rand_idx idx_zero
    end
end
%}

%{
row = 5;
column = 1000;
max_index = row*column;
non_zero = ceil((max_index * 100)/100);
R=zeros(row,column);
temp=randi([0 5],row,column);
idx=randperm(max_index);
idx=idx(1:non_zero);
R(idx)=temp(idx);
%}

%weakR = R;
%strongR = [];

%
R=load('movielens.txt');
R = R(1:943,:);
%}

%{
movielens = load('movielens1m.mat');
R = movielens.movielens1m;
%}

%eachMovie = load('eachMovie.mat');
%R = eachMovie.eachMovie;
%incase of weak generalization
weakR = sparse(R);
strongR = [];
%}

%{
weakMax = 5000;
[n, ~] = size(R);
idx = randperm(n);
weakR = sparse(R(idx(1:weakMax),:));
strongR = sparse(R(idx(weakMax+1:end),:));
%}

%R = R(:,1:1685);
%R = R.*2;

%R=load('jester-data-1.csv');
%R=load('R_matrix_1_5.csv');
end