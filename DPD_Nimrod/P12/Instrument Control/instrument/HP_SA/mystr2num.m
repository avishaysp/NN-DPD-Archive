function M = mystr2num(MEAS)
% returns a vector of integers from a char
% e.g. M = '-53.58,-16.25,-53.41' is returned as
% m =  [-53.58 -16.25 -53.41];
   if ismember(',',MEAS)
      for i = 1:length(MEAS)
          if MEAS(i) == ','
              MEAS(i) = ' '; 
          end  
      end
    else
      error('Function only for use of cascaded comma separated hidden integers use other function to convert a char array to string array');
   end
  M = sscanf(MEAS,'%f'); 