% 1. copy all files into separate directory
% 2. Run MATLAB
% 3. In command prompt type in cd 'the_name_of_installation_directory'
%    where the_name_of_installation_directory is a full path to teh installation directory
%    for example, if files were copied to the directory 'rf_book' on drive c, then
%    one should type in cd 'c:\rf_book'
% 4. From MATLAB command line run set_path
% 5. In the main menue of the command window go to file/set path...
% 6. In the path browser go to file\save path
% 7. now all paths are setup and you can run examples from the command line

%%  root_dir
clc
root_dir='C:\Users\nimrodgs\Documents\Nimrod\P12';
main_dir=[root_dir '\main'];
path(main_dir,path);

%%
tools_dir=strcat(root_dir,'\tools');
path(tools_dir,path);

signals_dir = strcat(root_dir,'\signals');
path( signals_dir ,path);

instrument_dir = strcat(root_dir,'\instrument');
path( instrument_dir ,path);

sg_dir = strcat(instrument_dir,'\ESG');
path( sg_dir ,path);

AFG_dir = strcat(instrument_dir,'\AFG');
path( AFG_dir ,path);

vsa_dir = strcat(instrument_dir,'\vsa');
path( vsa_dir ,path);

scope_dir = strcat(instrument_dir,'\scope');
path( scope_dir ,path);

analysis_dir = strcat(root_dir,'\analysis');
path( analysis_dir ,path);

dmm_dir = strcat(instrument_dir,'\dmm');
path( dmm_dir ,path);

DATA_dir = strcat(root_dir,'\DATA');
path( DATA_dir ,path);

new_dir = strcat(root_dir,'\NEW');
path( new_dir ,path);

% AFG_dir = strcat(new_dir,'\AFG');
% path( AFG_dir ,path);

% 
% J_dir='j:';
% iqtools_dir=[J_dir '\iqtools'];
% path(iqtools_dir,path);
% plots_dir = strcat(root_dir,'\plots');
% path( plots_dir ,path);
