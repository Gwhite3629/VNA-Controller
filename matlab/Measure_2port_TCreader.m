%script to measure Agilent 8753 NA, and 16-channel thermocouple reader
%(NI-9213). There are only 12 ouputs on the box for the thermocouple
%reader, so the default number of channels to read will be 12.

%measNA: Gets measurements from Agilent 8753ES Network Analyzer
%
%fstar=starting frequency in Hertz, 
%fstopr=stopping frequency in Hertz
%leave freqs empty (ie []) to get start and stop from the NA
%
%OPTIONAL INPUT ARGUMENTS in varargin:
%Enter each optional parameter in the format:
%   measNA(...,'ParameterName',ParameterValue,...)
%   for example:
%   data=measNA(70e6,90e6,'time',[0,20e-6],'gate',[2e-6,10e-6],...
%       's param','s11','block sxx','s11,s22','deltaf',10000,...
%       'IFBW',6000,'repeat',2)
% 
% INPUT OPTIONS:
%-'s param'=S parameters to measure, string, e.g. 's11,S22S21'.
%-'ifbw'=intermediate frequency bandwidth, double, in Hz
%-'gate'=Time gating limits,vector of doubles, gate [start,stop], in sec
%-'time'=Time domain limits,vector of doubles, time [start,stop], in sec
%-'deltaf'=frequency step for frequency block measurements, double, in Hz
%-'block sxx'=S parameter to measure during frequency block measurements, 
%   string, e.g. 'S11'
%   NOTE: specifying either deltaf or block sxx with activate the 
%       frequency block measurements for finer frequency resolution.
%-'repeat'=Number of times to repeat measurements, integer, this changes
%   the ouput form of data so each measurement has a separate substruct.
%   The entire set of measurements is repeated in series.
%-'gpib_add'= address for the GPIB VNA (integer).
clear all;

% calibration fit coefficients for device #28, fab 12/08/2011
% cubicfit = [7.435988835568764e-009   -1.959457954557580e-005    2.783794695694888e-004    3.418126220619930e+002];

%FS = stoploop();

delay = 5;  %loop delay in seconds
file_index = 1;
S11_data=[];
S22_data=[];
fo_1 = [];
fo_2 = [];
mag_1= [];
mag_2 = [];
min_elap=[];
rt_start = tic;
real_time_NA = [];
real_time_TC = [];
tcdata_array = [];
current_time=0;
% ctl_temp = [];
% safety_temp = [];
% temp = [];
% pressure = [];
counter = 50;
%NA configurations:
% fstart = [];
% fstop = [];
% IFBW=[];
fstart = 430E6;
fstop = 453E6;
IFBW=3000;

%time-gating stuff:
tstart = 0.2e-6;
tstop = 8e-6;
npts = 2^16;

saveFilename = input('Enter matlab filename: ','s');
% 
% figGated_1 = figure;
%figFo_1 = figure;
% figGated_2 = figure;
%figFo_2 = figure;
% pressure_plot = figure;
% figTemp = figure;

%configure the 9213 tc reader
s = config_9213('Dev1',0,'Celsius','K');      %set to read 'Dev1', channels 0 through 11. Adjust as needed.
s.NumberOfScans = 2;                %2 is the minimum allowed.

while(1)
    data = measNA(fstart,fstop,'s param','s11,s22','IFBW',IFBW);
    f = data.freq;
    real_time_NA = [real_time_NA; toc(rt_start)];
    current_time=current_time+data.min_elapsed;
    min_elap=[min_elap current_time];
    S11 = data.S11*[1;1i];
    S22 = data.S22*[1;1i];
    S11_data = [S11_data S11];      %these will hold ALL of the S param data (big matlab file)
    S22_data = [S22_data S22];
    
%     %S11 time gating:
%     [Ht,t] = chirpz_frequency2time(S11.*blackman(length(f)),f,tstart,tstop,npts);
%     [Hf_1,f2] = chirpz_time2frequency(Ht,t,f(1),f(end),npts);    
%     [val,ind] = max(abs(Hf_1));
%     fo_1 = [fo_1;f2(ind)];
%     mag_1 = [mag_1;20*log10(val)];
%     
%     %S22 time gating:
%     [Ht,t] = chirpz_frequency2time(S22.*blackman(length(f)),f,tstart,tstop,npts);
%     [Hf_2,f2] = chirpz_time2frequency(Ht,t,f(1),f(end),npts);    
%     [val,ind] = max(abs(Hf_2));
%     fo_2 = [fo_2;f2(ind)];
%     mag_2 = [mag_2;20*log10(val)];

%     %User Inputs:
%     ctl_temp = [ctl_temp; input('Enter the controller temp (Eurotherm): ')];
%     safety_temp = [safety_temp; input('Enter the safety TC temp: ')];
%     %temp = [temp; input('Enter the bolt-on reference temp: ')];
%     pressure = [pressure; input('Enter the pressure: ')];

    %read TC channels
    [tcdata, timestamp] = s.startForeground;
    real_time_TC = [real_time_TC; toc(rt_start)+timestamp];
    tcdata_array = [tcdata_array; tcdata];
    tcdata

    counter = counter-1;
    FileName = strcat(saveFilename,num2str(file_index));
    save(FileName);
    pause(delay);
    if counter==0
        save(FileName);
        pause(delay);
        S11_data=[];
        S22_data=[];
        fo_1 = [];
        fo_2 = [];
        mag_1= [];
        mag_2 = [];
        real_time_NA = [];
        real_time_TC = [];
        tcdata_array = [];
        counter = 50;
        file_index = file_index+1;
    end

%     figure(figGated_1);hold on;plot(f2,20*log10(abs(Hf_1))); grid on;
%     xlabel('Frequency [Hz]'); ylabel('Magnitude [dB]');
%      figure(figFo_1); plot(real_time_NA,fo_1/1e6); grid on;
%      xlabel('Time [min]'); ylabel('Resonance Frequency [MHz]');
% %  
% %     figure(figGated_2);hold on;plot(f2,20*log10(abs(Hf_2))); grid on;
% %     xlabel('Frequency [Hz]'); ylabel('Magnitude [dB]');
%      figure(figFo_2); plot(real_time_NA,fo_2/1e6); grid on;
%      xlabel('Time [min]'); ylabel('Resonance Frequency [MHz]');
%     
%     figure(pressure_plot); plot(real_time_NA, pressure, 'o-'); grid on;
%     xlabel('Time [min]'); ylabel('Pressure [psig]'); 
%       figure(3); plot(real_time_TC,tcdata_array); grid on;
%      xlabel('Time [min]'); ylabel('Temp');
%      
%      figure(4); plot(f/1E6,20*log10(abs(S11))); grid on;
%      xlabel('Freq [MHz]'); ylabel('|S11| [dB]');
    %%%% conversion of frequency value to temperature using the cubic fit
    %%%% above
    
%     SAWtemp = FtoT(fo/1e6, cubicfit);  
%     figure(figTemp); plot(real_time_NA, [ctl_temp temp SAWtemp]); 
%     xlabel('Time [min]'); ylabel('Temperature [\circC]'); 
%     legend('Controller', 'Bolt-on', 'SAW'); grid on;

    

end

