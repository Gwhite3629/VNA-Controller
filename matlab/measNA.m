function data=measNA(fstar,fstop,varargin)
%measNA: Gets measurements from Agilent 8753ES Network Analyzer
%
%fstar=starting frequency in Hertz
%fstopr=stopping frequency in Hertz
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


if mod(nargin,2)
    error(['Variable input arguments must be in form',...
        ' ...,''ParameterName'',ParameterValue'])
end

%Default parameters that can be changed by
s_param='S11,S12,S21,S22';
IFBW=300;
gatestar=[];
gatestop=[];
timestar=[];
timestop=[];
deltaf=[];
block_sxx='S21';
repeat=[];


%Process varargin
for m=1:2:length(varargin)-1
    if ~ischar(varargin{m})
        error(['Variable input arguments must be in form',...
        ' ...,''Name'',parameter'])
    end
   switch  lower(varargin{m})
       case {'s','sxx','s_param', 's parameters', 's param'}
           s_param=upper(varargin{m+1});
       case 'ifbw'
           IFBW=varargin{m+1};
       case {'gate','time gate'}
           gatestar=varargin{m+1}(1);
           gatestop=varargin{m+1}(2);
       case {'time','time domain'}
           timestar=varargin{m+1}(1);
           timestop=varargin{m+1}(2);
       case 'deltaf'
           deltaf=varargin{m+1};
       case {'block_s_param', 'block s param','block s','block sxx',...
               'block_s','block_sxx'}
           block_sxx=upper(varargin{m+1});
           if length(block_sxx)>3
               block_sxx=block_sxx(1:3);
               warning('MATLAB:measNAblocksxx',...
                   ['Block Sxx truncated to ''',block_sxx,'''.'])
           end
           deltaf=((fstop-fstar)/1601)/5;
       case {'repeat', 'average'}
           repeat=varargin{m+1};
           varargin{m}='null';
           warning('off','MATLAB:measNAblocksxx')
           warning('off','MATLAB:measNArecog')
       otherwise
           warning('MATLAB:measNArecog',['Input argument ''',...
               varargin{m},''' not recognised and was ignored.'])
   end
end



% if strfind(s_param,'S11')
%     disp('measuring S11')
% end


try  %Communicate with Network Analyzer, if fails close ports

% Create a GPIB object.
obj1 = instrfind('Type', 'gpib', 'BoardIndex', 0,...
    'PrimaryAddress', 16, 'Tag', '');

% Create the GPIB object if it does not exist
% otherwise use the object that was found.
if isempty(obj1)
    obj1 = gpib('ni', 0, 16);
%     obj1 = gpib('ics', 0, 16); 
%     obj1 = gpib('NI', 0, 16);
else
    fclose(obj1);
    obj1 = obj1(1);
end
%Customize commumication for NA
set(obj1,'InputBufferSize',80050);
set(obj1, 'Timeout', 20);

fopen(obj1);% Connect to instrument object, obj1.

%Initialize NA
fprintf(obj1,'TIMDTRANOFF')
fprintf(obj1,'GATEOOFF')
fprintf(obj1, 'POIN1601')
fprintf(obj1, ['IFBW',num2str(IFBW)])
% fprintf(obj1, 'IFBW300')

time=clock;

%If start/stop freq empty, use NA values
if isempty(fstar)
    fstar=str2double(query(obj1,'STAR?'));
end
if isempty(fstop)
    fstop=str2double(query(obj1,'STOP?'));
end

%Capture data for entire bandwidth
fprintf(obj1,sprintf('STAR%1E',fstar))
fprintf(obj1,sprintf('STOP%1E',fstop))

%Get freq from NA to be sure you get exact values
F_start=str2double(query(obj1,'STAR?'));
F_stop=str2double(query(obj1,'STOP?'));
N_pnts=str2double(query(obj1,'POIN?'));
freq=linspace(F_start,F_stop,N_pnts)';

if strfind(s_param,'S11')
    S11=str2num(query(obj1, 'S11;SMIC;SMIMRX;FORM4;OUTPFORM'));
else
    S11=[];
end
if strfind(s_param,'S12')
    S12=str2num(query(obj1, 'S12;SMIC;SMIMRX;FORM4;OUTPFORM'));
else
    S12=[];
end
if strfind(s_param,'S21')
    S21=str2num(query(obj1, 'S21;SMIC;SMIMRX;FORM4;OUTPFORM'));
else
    S21=[];
end
if strfind(s_param,'S22')
    S22=str2num(query(obj1, 'S22;SMIC;SMIMRX;FORM4;OUTPFORM'));
else
    S22=[];
end

%%%% Gate and recapture
%MOVE gate to after meas freq, then remeasure gated freq resp.  
%Don't meas gated time domain data.

if ~isempty(gatestar)
    fprintf(obj1,'GATEOON')
    fprintf(obj1,sprintf('GATESTAR%1E',gatestar))
    fprintf(obj1,sprintf('GATESTOP%1E',gatestop))
    
    if strfind(s_param,'S11')
        S11_gated=str2num(query(obj1, 'S11;SMIC;SMIMRX;FORM4;OUTPFORM'));
    else
        S11_gated=[];
    end
    if strfind(s_param,'S12')
        S12_gated=str2num(query(obj1, 'S12;SMIC;SMIMRX;FORM4;OUTPFORM'));
    else
        S12_gated=[];
    end
    if strfind(s_param,'S21')
        S21_gated=str2num(query(obj1, 'S21;SMIC;SMIMRX;FORM4;OUTPFORM'));
    else
        S21_gated=[];
    end
    if strfind(s_param,'S22')
        S22_gated=str2num(query(obj1, 'S22;SMIC;SMIMRX;FORM4;OUTPFORM'));
    else
        S22_gated=[];
    end
    
    fprintf(obj1,'GATEOOFF')

else
    S11_gated=[];
    S12_gated=[];
    S21_gated=[];
    S22_gated=[];
end

if ~isempty(timestar)
    % % %Get Time Domain (ifft) data
    fprintf(obj1,'TIMDTRANON')
    fprintf(obj1,sprintf('STAR%1E',timestar))
    fprintf(obj1,sprintf('STOP%1E',timestop))
    % fprintf(obj1, 'STAR0')
    % fprintf(obj1, 'STOP40E-06')

    t_start=str2double(query(obj1,'STAR?'));
    t_stop=str2double(query(obj1,'STOP?'));
    N_pnts=str2double(query(obj1,'POIN?'));
    t=linspace(t_start,t_stop,N_pnts)';

    if strfind(s_param,'S11')
        td_S11=str2num(query(obj1, 'S11;SMIC;SMIMRX;FORM4;OUTPFORM'));
    else
        td_S11=[];
    end
    if strfind(s_param,'S12')
        td_S12=str2num(query(obj1, 'S12;SMIC;SMIMRX;FORM4;OUTPFORM'));
    else
        td_S12=[];
    end
    if strfind(s_param,'S21')
        td_S21=str2num(query(obj1, 'S21;SMIC;SMIMRX;FORM4;OUTPFORM'));
    else
        td_S21=[];
    end
    if strfind(s_param,'S22')
        td_S22=str2num(query(obj1, 'S22;SMIC;SMIMRX;FORM4;OUTPFORM'));
    else
        td_S22=[];
    end

    fprintf(obj1,'TIMDTRANOFF')
    % disp('Got time domain data')
else
%     t_start=[];
%     t_stop=[];
    t=[];

    td_S11=[];
    td_S12=[];
    td_S21=[];
    td_S22=[];
end


%%%%% Capture block-divided frequency response
if ~isempty(deltaf)
    nblocks=ceil(((fstop-fstar)/deltaf+1)/N_pnts);

    f_block=zeros(nblocks*N_pnts,1);
    S_block=zeros(nblocks*N_pnts,2);
    for i=1:nblocks-1
        fprintf(obj1,sprintf('STAR%1E',fstar+(i-1)*N_pnts*deltaf))
        fprintf(obj1,sprintf('STOP%1E',fstar+i*N_pnts*deltaf-deltaf))
        f_block(1+N_pnts*(i-1):N_pnts*i)=linspace(...
            str2double(query(obj1,'STAR?')),...
            str2double(query(obj1,'STOP?')),N_pnts);
        S_block(1+N_pnts*(i-1):N_pnts*i,:)=str2num(query(obj1,...
             [block_sxx,';SMIC;SMIMRX;FORM4;OUTPFORM']));
    end

    i=nblocks;
    fprintf(obj1,sprintf('STAR%1E',fstop-(N_pnts-1)*deltaf))
    fprintf(obj1,sprintf('STOP%1E',fstop))
    f_block(1+N_pnts*(i-1):N_pnts*i)=linspace(...
        str2double(query(obj1,'STAR?')),...
        str2double(query(obj1,'STOP?')),N_pnts);
     S_block(1+N_pnts*(i-1):N_pnts*i,:)=str2num(query(obj1,...
             [block_sxx,';SMIC;SMIMRX;FORM4;OUTPFORM']));

    f_divide=f_block(N_pnts*(nblocks-1));

    S_block=S_block([1:N_pnts*(nblocks-1),find(f_block>f_divide)'],:);
    f_block=f_block([1:N_pnts*(nblocks-1),find(f_block>f_divide)']);

    %Fit To Spline 
    %(might not need spline now, but keep in case meas freqs were rounded)

    f_spline=linspace(fstar,fstop,(fstop-fstar)/deltaf+1)';
    S_spline(:,1) = interp1(f_block,S_block(:,1),f_spline,'spline');
    S_spline(:,2) = interp1(f_block,S_block(:,2),f_spline,'spline');

    S_block=S_spline;
    f_block=f_spline;

    
    %Reset NA to wide-band freqs
    fprintf(obj1,sprintf('STAR%1E',fstar))
    fprintf(obj1,sprintf('STOP%1E',fstop))

else
    deltaf=[];
    f_block=[];
    S_block=[];
end

%%%%%%%%%%%%%%%%%
%%%Save data
data.time=time;
data.min_elapsed=minuteselapsed(time,clock);

data.F_start=F_start;
data.F_stop=F_stop;
data.N_pnts=N_pnts;

data.freq=freq;
data.S11=S11;
data.S21=S21;
data.S12=S12;
data.S22=S22;

data.gatestart=gatestar;
data.gatestop=gatestop;
data.S11_gated=S11_gated;
data.S21_gated=S21_gated;
data.S12_gated=S12_gated;
data.S22_gated=S22_gated;

data.t=t;
data.td_S11=td_S11;
data.td_S21=td_S21;
data.td_S12=td_S12;
data.td_S22=td_S22;


data.deltaf=deltaf;
data.f_block=f_block;
data.S_block=S_block;


% Disconnect from instrument object, obj1.
fclose(obj1);
delete(obj1);
clear obj1

% beep;pause(.2);beep;

 catch %If an error disconnect from instrument object
     fclose(obj1);
     delete(obj1);
     clear obj1
     data=lasterror;
     rethrow(lasterror)
     
 end


% %If repeated measurements desired, call measNA recursively
if repeat>1
    meas=data;
    clear data
    data=struct('meas1',meas);
    for r=2:repeat 
        pause(0.1) 
        %Pause to make certain that the gpib close happened completely
        data=setfield(data, ...
            ['meas',num2str(r)],measNA(fstar,fstop,varargin{:}));
    end
    warning('on','MATLAB:measNAblocksxx')
    warning('on','MATLAB:measNArecog')
end


end

function minutes=minuteselapsed(time1,time2)

minutes=(datenum(time2)-datenum(time1))*24*60;
end

% %If repeated measurements desired, call measNA recursively
% if repeat>1
% 
%     for r=2:repeat 
%         newdata=measNA(fstar,fstop,varargin{:});
%         %%%Save data, append new data to previous measurements
%         data.time=[data.time;newdata.time];
%         data.min_elapsed=[data.min_elapsed,newdata.min_elapsed];
% 
%         data.F_start=[data.F_start,newdata.F_start];
%         data.F_stop=[data.F_stop,newdata.F_stop];
%         data.N_pnts=[data.N_pnts,newdata.N_pnts];
% 
%         data.freq=[data.freq,newdata.freq];
%         data.S11=[data.S11,newdata.S11];
%         data.S21=[data.S21,newdata.S21];
%         data.S12=[data.S12,newdata.S12];
%         data.S22=[data.S22,newdata.S22];
% 
%         data.gatestart=[data.gatestart,newdata.gatestart];
%         data.gatestop=[data.gatestop,newdata.gatestop];
%         data.S11_gated=[data.S11_gated,newdata.S11_gated];
%         data.S21_gated=[data.S21_gated,newdata.S21_gated];
%         data.S12_gated=[data.S12_gated,newdata.S12_gated];
%         data.S22_gated=[data.S22_gated,newdata.S22_gated];
% 
%         data.t=[data.t,newdata.t];
%         data.td_S11=[data.td_S11,newdata.td_S11];
%         data.td_S21=[data.td_S21,newdata.td_S21];
%         data.td_S12=[data.td_S12,newdata.td_S12];
%         data.td_S22=[data.td_S22,newdata.td_S22];
% 
%         data.deltaf=[data.deltaf,newdata.deltaf];
%         data.f_block=[data.f_block,newdata.f_block];
%         data.S_block=[data.S_block,newdata.S_block];
%     end
%     warning('on','MATLAB:measNAblocksxx')
%     warning('on','MATLAB:measNArecog')
% end

% if repeat>1
%     meas=data;
%     clear data
%     data{1}=meas;
%     for r=2:repeat 
%         data{r}=measNA(fstar,fstop,varargin{:});
%     end
%     warning('on','MATLAB:measNAblocksxx')
%     warning('on','MATLAB:measNArecog')
% end
