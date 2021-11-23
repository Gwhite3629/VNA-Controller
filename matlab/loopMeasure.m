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
cubicfit = [7.435988835568764e-009   -1.959457954557580e-005    2.783794695694888e-004    3.418126220619930e+002];

S11_data=[];
fo = [];
mag= [];
min_elap=[];
rt_start = tic;
real_time = [];
current_time=0;
ctl_temp = [];
safety_temp = [];
temp = [];
pressure = [];

fstart = 280e6;
fstop = 295e6;
tstart = 0.2e-6;
tstop = 8e-6;
npts = 2^16;

saveFilename = input('Enter matlab filename: ','s');

figGated = figure;
figFo = figure;
pressure_plot = figure;
figTemp = figure;

while 1
    data = measNA(fstart,fstop,'s param','s11','IFBW',300);
    f = data.freq;
    real_time = [real_time; toc(rt_start)/60];
    current_time=current_time+data.min_elapsed;
    min_elap=[min_elap current_time];
    S11=data.S11*[1;j];
    S11_data = [S11_data S11];
    [Ht,t] = chirpz_frequency2time(S11.*blackman(length(f)),f,tstart,tstop,npts);
    [Hf,f2] = chirpz_time2frequency(Ht,t,f(1),f(end),npts);    
    [val,ind] = max(abs(Hf));
    fo = [fo;f2(ind)];
    mag = [mag;20*log10(val)];

    ctl_temp = [ctl_temp; input('Enter the controller temp (Eurotherm): ')];
    safety_temp = [safety_temp; input('Enter the safety TC temp: ')];
    temp = [temp; input('Enter the bolt-on reference temp: ')];
    pressure = [pressure; input('Enter the pressure: ')];

    save(saveFilename);
    
    figure(figGated);hold on;plot(f2,20*log10(abs(Hf))); grid on;
    xlabel('Frequency [Hz]'); ylabel('Magnitude [dB]');
    figure(figFo); plot(real_time,fo/1e6); grid on;
    xlabel('Time [min]'); ylabel('Resonance Frequency [MHz]');
    figure(pressure_plot); plot(real_time, pressure, 'o-'); grid on;
    xlabel('Time [min]'); ylabel('Pressure [psig]'); 

    %%%% conversion of frequency value to temperature using the cubic fit
    %%%% above
    
    SAWtemp = FtoT(fo/1e6, cubicfit);  
    figure(figTemp); plot(real_time, [ctl_temp temp SAWtemp]); 
    xlabel('Time [min]'); ylabel('Temperature [\circC]'); 
    legend('Controller', 'Bolt-on', 'SAW'); grid on;
    
    keyboard
end

%csvwrite(input('Enter csv filename: ',''s'), [real_time ctl_temp temp SAWtemp pressure fo mag]);

dlmwrite(input('Enter csv filename: ','s'), [real_time ctl_temp temp SAWtemp pressure fo mag safety_temp], 'precision', 10);