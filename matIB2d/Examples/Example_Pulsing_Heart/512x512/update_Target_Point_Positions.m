%-------------------------------------------------------------------------------------------------------------------%
%
% IB2d is an Immersed Boundary Code (IB) for solving fully coupled non-linear 
% 	fluid-structure interaction models. This version of the code is based off of
%	Peskin's Immersed Boundary Method Paper in Acta Numerica, 2002.
%
% Author: Nicholas A. Battista
% Email:  nickabattista@gmail.com
% Date Created: May 27th, 2015
% Institution: UNC-CH
%
% This code is capable of creating Lagrangian Structures using:
% 	1. Springs
% 	2. Beams (*torsional springs)
% 	3. Target Points
%	4. Muscle-Model (combined Force-Length-Velocity model, "Hill+(Length-Tension)")
%
% One is able to update those Lagrangian Structure parameters, e.g., spring constants, resting lengths, etc
% 
% There are a number of built in Examples, mostly used for teaching purposes. 
% 
% If you would like us to add a specific muscle model, please let Nick (nickabattista@gmail.com) know.
%
%--------------------------------------------------------------------------------------------------------------------%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION: updates the target point positions
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function targets = update_Target_Point_Positions(dt,current_time,targets)


IDs = targets(:,1);                 % Stores Lag-Pt IDs in col vector
xPts= targets(:,2);                 % Original x-Values of x-Target Pts.
yPts= targets(:,3);                 % Original y-Values of y-Target Pts.
kStiffs = targets(:,4);             % Stores Target Stiffnesses 

N_target = length(targets(:,1));    %Gives total number of target pts!


% Coefficients for Polynomial Phase-Interpolation
a = 2.739726027397260;  % y1(t) = at^2
b = 2.739726027397260;  % y3(t) = -b(t-1)^2+1
c = -2.029426686960933; % y2(t) = ct^3 + dt^2 + gt + h
d = 3.044140030441400;
g = -0.015220700152207;
h = 0.000253678335870;

% Period Info
tP1 = 0.05;                        % Contraction time
tP2 = 0.05;                        % Expansion time
period = tP1+tP2;                   % Period
t = rem(current_time,period);       % Current time in simulation ( 'modular arithmetic to get time in period')


% Read In Pts!
[xP1,yP1,xP2,yP2] = read_File_In('All_Positions.txt');


for i=1:N_target                    % Loops over all target points!
    
    
    if (t <= tP1) 

			%PHASE 1 --> PHASE 2
			
			tprev = 0.0;
			t1 = 0.1*tP1;   
			t2 = 0.9*tP1;
			if (t<t1) 							%For Polynomial Phase Interp.
				g1 = a*power((t/tP1),2);
            elseif ((t>=t1)&&(t<t2)) 
				g1 = c*power((t/tP1),3) + d*power((t/tP1),2) + g*(t/tP1) + h;
            elseif (t>=t2)
				g1 = -b*power(((t/tP1) - 1),2) + 1;
            end
			
			xPts(IDs(i)) = xP1(i) + g1*( xP2(i) - xP1(i) );
			yPts(IDs(i)) = yP1(i) + g1*( yP2(i) - yP1(i) );	
			
    elseif ((t>tP1)&&(t<=(tP1+tP2)))
			
			%PHASE 2 --> PHASE 1
            
			tprev = tP1;
			t1 = 0.1*tP2 + tP1;
			t2 = 0.9*tP2 + tP1;
			if (t<t1) 							%//For Polynomial Phase Interp.
				g2 = a*power( ( (t-tprev)/tP2) ,2);
            elseif ((t>=t1)&&(t<t2)) 
				g2 = c*power( ( (t-tprev)/tP2) ,3) + d*power( ((t-tprev)/tP2) ,2) + g*( (t-tprev)/tP2) + h;
            elseif (t>=t2) 
				g2 = -b*power( (( (t-tprev)/tP2) - 1) ,2) + 1;
            end			
            
			xPts(IDs(i)) = xP2(i) + g2*( xP1(i) - xP2(i) );
			yPts(IDs(i)) = yP2(i) + g2*( yP1(i) - yP2(i) );
    
    end
    
    targets(IDs(i),2) = xPts(IDs(i)); % Store new xVals
    targets(IDs(i),3) = yPts(IDs(i)); % Store new yVals

end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION: reads in info from file that contains probability distributions
% (rows) for each game of Bingo w/ N players (columns)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [x1,y1,x2,y2] = read_File_In(file_name)

filename = file_name;  %Name of file to read in

fileID = fopen(filename);

    % Read in the file, use 'CollectOutput' to gather all similar data together
    % and 'CommentStyle' to to end and be able to skip lines in file.
    C = textscan(fileID,'%f %f %f %f','CollectOutput',1);

fclose(fileID);        %Close the data file.

mat_info = C{1};   %Stores all read in data

%Store all elements in matrix
mat = mat_info(1:end,1:end);

x1 =  mat(:,1); %store regular bingo expectation values 
y1 =  mat(:,2); %store inner bingo expectation values 
x2 =  mat(:,3); %store outer bingo expectation values 
y2 =  mat(:,4); %store cover all bingo expectation values 
